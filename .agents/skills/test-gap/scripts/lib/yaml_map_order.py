#!/usr/bin/env python3
"""Check or fix alphabetical map key order in GitHub Actions YAML (ORD-01)."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

MAP_HEADERS = frozenset(
    {
        "with:",
        "inputs:",
        "outputs:",
        "env:",
        "permissions:",
        "secrets:",
    }
)
KEY_RE = re.compile(r"^(\s+)([A-Za-z0-9_-]+):\s*(.*)$")


def parse_block(
    lines: list[str], start: int, header_indent: int
) -> tuple[list[tuple[str, list[str]]], int]:
    key_indent = header_indent + 2
    entries: list[tuple[str, list[str]]] = []
    pending_prefix: list[str] = []
    i = start
    n = len(lines)

    while i < n:
        line = lines[i]
        if not line.strip():
            pending_prefix.append(line)
            i += 1
            continue

        current_indent = len(line) - len(line.lstrip(" "))
        if current_indent < key_indent:
            break

        if current_indent > key_indent:
            if entries:
                entries[-1][1].extend(pending_prefix)
                pending_prefix = []
                entries[-1][1].append(line)
            else:
                pending_prefix.append(line)
            i += 1
            continue

        stripped = line.strip()
        if stripped.startswith("#"):
            pending_prefix.append(line)
            i += 1
            continue

        match = KEY_RE.match(line.rstrip("\n"))
        if not match:
            break

        key = match.group(2)
        entry_lines = pending_prefix + [line]
        pending_prefix = []
        i += 1

        while i < n:
            nxt = lines[i]
            if not nxt.strip():
                entry_lines.append(nxt)
                i += 1
                continue

            nxt_indent = len(nxt) - len(nxt.lstrip(" "))
            if nxt_indent < key_indent:
                break

            if nxt_indent == key_indent:
                nxt_stripped = nxt.strip()
                if nxt_stripped.startswith("#"):
                    break
                if KEY_RE.match(nxt.rstrip("\n")):
                    break

            entry_lines.append(nxt)
            i += 1

        entries.append((key, entry_lines))

    if pending_prefix and entries:
        entries[-1][1].extend(pending_prefix)
    elif pending_prefix:
        entries.insert(0, ("", pending_prefix))

    return entries, i


def sort_maps_in_text(text: str) -> str:
    lines = text.splitlines(keepends=True)
    out: list[str] = []
    i = 0
    n = len(lines)

    while i < n:
        line = lines[i]
        stripped = line.strip()
        indent = len(line) - len(line.lstrip())
        header = stripped if stripped.endswith(":") else f"{stripped}:"

        if header in MAP_HEADERS:
            out.append(line)
            entries, next_i = parse_block(lines, i + 1, indent)
            for key, entry_lines in sorted(entries, key=lambda item: item[0]):
                out.extend(entry_lines)
            i = next_i
            continue

        out.append(line)
        i += 1

    return "".join(out)


def check_maps_in_text(text: str, path: str) -> list[str]:
    lines = text.splitlines(keepends=True)
    errors: list[str] = []
    i = 0
    n = len(lines)

    while i < n:
        line = lines[i]
        stripped = line.strip()
        indent = len(line) - len(line.lstrip())
        header = stripped if stripped.endswith(":") else f"{stripped}:"

        if header in MAP_HEADERS:
            header_line = i + 1
            entries, next_i = parse_block(lines, i + 1, indent)
            keys = [key for key, _ in entries if key]
            if len(keys) > 1 and keys != sorted(keys):
                errors.append(
                    f"{path}:{header_line}: {header.rstrip(':')} block keys not alphabetically ordered"
                )
            i = next_i
            continue

        i += 1

    return errors


def iter_yaml_targets(path: Path) -> list[Path]:
    if path.is_file():
        return [path]
    if not path.is_dir():
        return []

    if path.name == "actions" or "actions" in path.parts:
        targets: list[Path] = []
        for pattern in ("action.yml", "action.yaml"):
            targets.extend(path.rglob(pattern))
        return sorted(targets)

    targets = list(path.rglob("*.yml")) + list(path.rglob("*.yaml"))
    return sorted(targets)


def expand_targets(paths: list[str]) -> list[Path]:
    expanded: list[Path] = []
    seen: set[Path] = set()
    for raw in paths:
        for candidate in iter_yaml_targets(Path(raw)):
            resolved = candidate.resolve()
            if resolved in seen:
                continue
            seen.add(resolved)
            expanded.append(candidate)
    return expanded


def check_file(path: Path) -> list[str]:
    return check_maps_in_text(path.read_text(encoding="utf-8"), str(path))


def fix_file(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    updated = sort_maps_in_text(original)
    if updated == original:
        return False
    path.write_text(updated, encoding="utf-8")
    return True


def cmd_check(paths: list[str]) -> int:
    failed = False
    for path in expand_targets(paths):
        for error in check_file(path):
            print(error, file=sys.stderr)
            failed = True
    return 1 if failed else 0


def cmd_fix(paths: list[str]) -> int:
    changed = 0
    for path in expand_targets(paths):
        if fix_file(path):
            changed += 1
            print(f"sorted: {path}")
    print(f"done ({changed} files changed)")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Check or fix alphabetical map key order in GitHub Actions YAML (ORD-01)."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    check_parser = subparsers.add_parser("check", help="Verify map key order")
    check_parser.add_argument("paths", nargs="+", help="YAML files or directories to scan")

    fix_parser = subparsers.add_parser("fix", help="Rewrite files with sorted map keys")
    fix_parser.add_argument("paths", nargs="+", help="YAML files or directories to fix")

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if args.command == "check":
        return cmd_check(args.paths)
    if args.command == "fix":
        return cmd_fix(args.paths)
    parser.error(f"unknown command: {args.command}")
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
