#!/usr/bin/env python3
"""Check or fix alphabetical argument order in Terraform blocks (ORD-01).

Scope: top-level arguments of ``resource``, ``data`` and ``module`` blocks.
``locals``, ``variable``, ``output``, ``provider``, ``terraform`` blocks and the
contents of nested blocks / object literals are left untouched.

Layout of a rewritten block:

  1. count, for_each            (module only: followed by a blank line)
  2. source, version            (module only: followed by a blank line)
  3. create, is_enabled, region (module only: followed by a blank line)
  4. every other argument, alphabetical
  5. nested blocks, original relative order (provisioner order matters)
  6. tags, depends_on

Comment lines directly above an argument travel with it. A block that contains a
comment separated from the following argument by a blank line (a section comment)
is reported as skipped and never rewritten, because moving arguments would
orphan that comment.

Safety net: before a file is written the rewritten text must contain exactly the
same non-blank lines (whitespace-normalized) as the original and must be stable
when processed again. A file failing either check is not written and is reported
as an error.

Exit status: 0 = nothing to do / fixed, 1 = violations found (check mode),
2 = internal error or unreadable file.
"""

from __future__ import annotations

import argparse
import collections
import os
import re
import sys
import tempfile
from pathlib import Path

HEAD_KEYS = ("count", "for_each", "source", "version")
META_KEYS = ("create", "is_enabled", "region")
TAIL_KEYS = ("tags", "depends_on")

BLOCK_RE = re.compile(r'^(resource|data|module)\s+"[^"]+"(\s+"[^"]+")?\s*\{\s*$')
ATTR_RE = re.compile(r"^\s*([A-Za-z_][\w-]*)\s*=(?!=)")
NESTED_RE = re.compile(r'^\s*([A-Za-z_][\w-]*)(\s+("[^"]*"|[\w-]+))*\s*\{')
HEREDOC_RE = re.compile(r"<<-?\s*([A-Za-z_]\w*)\s*$")

EXCLUDED_DIRS = frozenset({".terraform", ".git", "apm_modules", "node_modules", "tmp"})
HEREDOC_DEPTH = 99


class Item:
    """One top-level argument or nested block together with its leading comments."""

    def __init__(self, kind: str, name: str, lines: list[str]) -> None:
        self.kind = kind
        self.name = name
        self.lines = lines


def line_depths(lines: list[str]) -> list[int]:
    """Return the bracket depth at the start of each line.

    Strings, ``${}`` / ``%{}`` interpolations, comments and heredocs are tracked so
    that braces inside them do not change the depth. Heredoc bodies get HEREDOC_DEPTH.
    """
    depths: list[int] = []
    depth = 0
    stack: list[list] = []  # ["S"] string, ["I", open_brace_count] interpolation
    heredoc: str | None = None
    in_block_comment = False

    for line in lines:
        depths.append(depth)
        if heredoc is not None:
            depths[-1] = HEREDOC_DEPTH
            if line.strip() == heredoc:
                heredoc = None
            continue

        i = 0
        n = len(line)
        while i < n:
            c = line[i]
            if in_block_comment:
                if line.startswith("*/", i):
                    in_block_comment = False
                    i += 2
                else:
                    i += 1
                continue

            top = stack[-1][0] if stack else "C"
            if top == "S":
                if c == "\\":
                    i += 2
                elif c == '"':
                    stack.pop()
                    i += 1
                elif c in "$%" and line.startswith(c + c + "{", i):  # escaped $${ / %%{
                    i += 3
                elif c in "$%" and line.startswith(c + "{", i):
                    stack.append(["I", 0])
                    i += 2
                else:
                    i += 1
                continue

            # code or interpolation expression
            if c == '"':
                stack.append(["S"])
            elif c == "#" or line.startswith("//", i):
                break
            elif line.startswith("/*", i):
                in_block_comment = True
                i += 2
                continue
            elif top == "I":
                if c == "{":
                    stack[-1][1] += 1
                elif c == "}":
                    if stack[-1][1] == 0:
                        stack.pop()
                    else:
                        stack[-1][1] -= 1
            elif c in "{[(":
                depth += 1
            elif c in "}])":
                depth -= 1
            elif c == "<" and line.startswith("<<", i):
                match = HEREDOC_RE.match(line[i:].rstrip("\r\n"))
                if match:
                    heredoc = match.group(1)
                    break
            i += 1

        # A quoted string never spans lines; drop a dangling one (malformed input).
        while stack and stack[-1][0] == "S":
            stack.pop()
    return depths


def split_items(
    lines: list[str], depths: list[int], indexes: list[int]
) -> tuple[list[Item], list[str], bool] | None:
    """Split a block body into items.

    Returns (items, trailing_comments, has_section_comment) or None when the body
    contains something this tool does not understand.
    """
    items: list[Item] = []
    pending: list[str] = []
    current: Item | None = None
    has_section_comment = False

    for k in indexes:
        line = lines[k]
        if depths[k] > 1:
            if current is None:
                return None
            current.lines.append(line)
            continue

        current = None
        stripped = line.strip()
        if stripped == "":
            if any(p.strip() for p in pending):
                has_section_comment = True
            pending.append(line)
            continue
        if stripped.startswith("#") or stripped.startswith("//") or stripped.startswith("/*"):
            pending.append(line)
            continue

        attr = ATTR_RE.match(line)
        nested = NESTED_RE.match(line)
        if attr:
            current = Item("attr", attr.group(1), pending + [line])
        elif nested:
            current = Item("block", nested.group(1), pending + [line])
        else:
            return None
        pending = []
        items.append(current)

    trailing = [p for p in pending if p.strip()]
    return items, trailing, has_section_comment


def reorder_body(
    lines: list[str], depths: list[int], indexes: list[int], is_module: bool
) -> tuple[list[str] | None, str]:
    """Return (new_body, status). new_body is None when nothing changes."""
    parsed = split_items(lines, depths, indexes)
    if parsed is None:
        return None, "unsupported"
    items, trailing, has_section_comment = parsed

    attrs = [it for it in items if it.kind == "attr"]
    blocks = [it for it in items if it.kind == "block"]
    names = [a.name for a in attrs]
    if len(set(names)) != len(names):
        return None, "duplicate"

    def pick(keys: tuple[str, ...]) -> list[Item]:
        return [a for key in keys for a in attrs if a.name == key]

    head, meta, tail = pick(HEAD_KEYS), pick(META_KEYS), pick(TAIL_KEYS)
    placed = {id(a) for a in head + meta + tail}
    rest = sorted((a for a in attrs if id(a) not in placed), key=lambda a: a.name)

    desired = head + meta + rest + blocks + tail
    if [id(x) for x in desired] == [id(x) for x in items]:
        return None, "ok"
    if has_section_comment:
        return None, "section-comment"

    out: list[str] = []

    def emit(group: list[Item], blank_before: bool) -> None:
        if not group:
            return
        if blank_before and out:
            out.append("")
        for it in group:
            body = list(it.lines)
            while body and not body[0].strip():
                body.pop(0)
            out.extend(body)

    if is_module:
        emit([a for a in head if a.name in ("count", "for_each")], False)
        emit([a for a in head if a.name in ("source", "version")], True)
        emit(meta, True)
        emit(rest, True)
    else:
        emit(head, False)
        emit(meta + rest, True)
    emit(blocks, True)
    emit(tail, True)
    out.extend(trailing)
    return out, "changed"


def process_text(text: str) -> tuple[str, list[str], list[str]]:
    """Rewrite text. Returns (new_text, changed_block_headers, skipped_descriptions)."""
    lines = text.split("\n")
    depths = line_depths(lines)
    out: list[str] = []
    changed: list[str] = []
    skipped: list[str] = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if depths[i] != 0 or not BLOCK_RE.match(line):
            out.append(line)
            i += 1
            continue

        end = i + 1
        while end < len(lines) and not (depths[end] == 1 and lines[end].strip() == "}"):
            end += 1
        if end >= len(lines):
            out.extend(lines[i:])
            skipped.append(f"{line.strip()} (line {i + 1}): unterminated block")
            break

        indexes = list(range(i + 1, end))
        is_module = line.lstrip().startswith("module ")
        body, status = reorder_body(lines, depths, indexes, is_module)
        if body is None:
            out.extend(lines[i : end + 1])
            if status in ("unsupported", "duplicate", "section-comment"):
                skipped.append(f"{line.strip()} (line {i + 1}): {status}")
        else:
            out.append(line)
            out.extend(body)
            out.append(lines[end])
            changed.append(f"{line.strip()} (line {i + 1})")
        i = end + 1
    return "\n".join(out), changed, skipped


def normalized(text: str) -> collections.Counter:
    return collections.Counter(re.sub(r"\s+", " ", x.strip()) for x in text.split("\n") if x.strip())


def verify(original: str, rewritten: str) -> str | None:
    """Return an error description when the rewrite is unsafe, else None."""
    if normalized(original) != normalized(rewritten):
        return "rewritten text does not contain the same lines as the original"
    again, changed, _ = process_text(rewritten)
    if changed or again != rewritten:
        return "rewrite is not stable (second pass changes the file)"
    return None


def collect_files(paths: list[str]) -> list[Path]:
    files: list[Path] = []
    for raw in paths:
        path = Path(raw)
        if path.is_dir():
            for found in sorted(path.rglob("*.tf")):
                if not EXCLUDED_DIRS.intersection(found.relative_to(path).parts):
                    files.append(found)
        elif path.suffix == ".tf" and path.is_file():
            files.append(path)
        else:
            print(f"WARN: skipped (not a .tf file or directory): {raw}", file=sys.stderr)
    return files


def write_atomically(path: Path, text: str) -> None:
    """Replace ``path`` with ``text`` so an interrupt never leaves a truncated file.

    The text goes to a temporary file in the same directory (same filesystem, so the
    final ``os.replace`` is atomic) and the original file mode is carried over.
    """
    directory = path.parent if str(path.parent) else Path(".")
    handle = tempfile.NamedTemporaryFile(
        "w", encoding="utf-8", newline="", dir=directory, prefix=f".{path.name}.", delete=False
    )
    try:
        with handle:
            handle.write(text)
        os.chmod(handle.name, path.stat().st_mode & 0o7777)
        os.replace(handle.name, path)
    except BaseException:
        try:
            os.unlink(handle.name)
        except OSError:
            pass
        raise


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Check or fix alphabetical argument order in Terraform blocks (ORD-01)."
    )
    parser.add_argument("paths", nargs="+", help="Terraform files or directories (searched recursively)")
    parser.add_argument("--fix", action="store_true", help="rewrite files in place (default: check only)")
    args = parser.parse_args(argv)

    violations = 0
    errors = 0
    for path in collect_files(args.paths):
        try:
            with open(path, encoding="utf-8", newline="") as handle:
                original = handle.read()
        except (OSError, UnicodeDecodeError) as exc:
            print(f"ERROR: cannot read {path}: {exc}", file=sys.stderr)
            errors += 1
            continue

        rewritten, changed, skipped = process_text(original)
        for item in skipped:
            print(f"SKIP {path}: {item}", file=sys.stderr)
        if not changed:
            continue

        problem = verify(original, rewritten)
        if problem:
            print(f"ERROR: {path}: {problem}; file left unchanged", file=sys.stderr)
            errors += 1
            continue

        if args.fix:
            write_atomically(path, rewritten)
            print(f"FIXED {path} ({len(changed)} block(s))")
        else:
            violations += 1
            print(f"ORD-01 {path}:")
            for item in changed:
                print(f"  arguments not in alphabetical order: {item}")

    if errors:
        return 2
    return 1 if violations else 0


if __name__ == "__main__":
    sys.exit(main())
