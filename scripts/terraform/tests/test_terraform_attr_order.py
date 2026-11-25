#!/usr/bin/env python3
"""Tests for terraform_attr_order.py. Run: python3 -m unittest discover -s scripts/terraform/tests"""

from __future__ import annotations

import os
import sys
import tempfile
import unittest
from unittest import mock
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import terraform_attr_order as tao  # noqa: E402


def run(text: str) -> tuple[str, list[str], list[str]]:
    return tao.process_text(text)


class ResourceOrderTest(unittest.TestCase):
    def test_sorts_arguments_and_keeps_region_first(self) -> None:
        src = 'resource "a" "b" {\n  zeta = 1\n  region = "r"\n  alpha = 2\n  tags = {}\n  mid = 3\n}\n'
        out, changed, _ = run(src)
        self.assertEqual(
            out,
            'resource "a" "b" {\n  region = "r"\n  alpha = 2\n  mid = 3\n  zeta = 1\n\n  tags = {}\n}\n',
        )
        self.assertEqual(len(changed), 1)

    def test_already_sorted_is_untouched(self) -> None:
        src = 'resource "a" "b" {\n  region = "r"\n  alpha = 2\n  zeta = 1\n\n  tags = {}\n}\n'
        out, changed, skipped = run(src)
        self.assertEqual(out, src)
        self.assertEqual((changed, skipped), ([], []))

    def test_nested_blocks_keep_order_and_follow_arguments(self) -> None:
        src = (
            'resource "a" "b" {\n  provisioner "local-exec" {\n    command = "x"\n  }\n  zeta = 1\n'
            '  lifecycle {\n    ignore_changes = [a]\n  }\n  alpha = 2\n}\n'
        )
        out, _, _ = run(src)
        self.assertEqual(
            out,
            'resource "a" "b" {\n  alpha = 2\n  zeta = 1\n\n  provisioner "local-exec" {\n    command = "x"\n  }\n'
            '  lifecycle {\n    ignore_changes = [a]\n  }\n}\n',
        )

    def test_depends_on_and_tags_go_last(self) -> None:
        src = 'resource "a" "b" {\n  depends_on = [x]\n  tags = {}\n  alpha = 1\n}\n'
        out, _, _ = run(src)
        self.assertTrue(out.index("alpha") < out.index("tags") < out.index("depends_on"))

    def test_leading_comment_travels_with_argument(self) -> None:
        src = 'resource "a" "b" {\n  zeta = 1\n  # about alpha\n  alpha = 2\n}\n'
        out, _, _ = run(src)
        self.assertEqual(out, 'resource "a" "b" {\n  # about alpha\n  alpha = 2\n  zeta = 1\n}\n')

    def test_section_comment_block_is_skipped(self) -> None:
        src = 'resource "a" "b" {\n  # --- group ---\n\n  zeta = 1\n  alpha = 2\n}\n'
        out, changed, skipped = run(src)
        self.assertEqual(out, src)
        self.assertEqual(changed, [])
        self.assertEqual(len(skipped), 1)

    def test_duplicate_argument_block_is_skipped(self) -> None:
        src = 'resource "a" "b" {\n  zeta = 1\n  alpha = 2\n  zeta = 3\n}\n'
        out, changed, skipped = run(src)
        self.assertEqual(out, src)
        self.assertEqual(changed, [])
        self.assertEqual(len(skipped), 1)

    def test_other_block_types_are_untouched(self) -> None:
        src = 'locals {\n  zeta = 1\n  alpha = 2\n}\nvariable "v" {\n  type = string\n  description = "d"\n}\n'
        out, changed, _ = run(src)
        self.assertEqual(out, src)
        self.assertEqual(changed, [])


class ModuleLayoutTest(unittest.TestCase):
    def test_module_layout(self) -> None:
        src = (
            'module "m" {\n  zeta = 1\n  region = "r"\n  version = "1"\n  source = "s"\n  is_enabled = true\n'
            "  alpha = 2\n  for_each = x\n}\n"
        )
        out, _, _ = run(src)
        self.assertEqual(
            out,
            'module "m" {\n  for_each = x\n\n  source = "s"\n  version = "1"\n\n  is_enabled = true\n  region = "r"\n\n'
            "  alpha = 2\n  zeta = 1\n}\n",
        )


class ParsingTest(unittest.TestCase):
    def test_braces_in_strings_and_interpolation(self) -> None:
        src = 'resource "a" "b" {\n  zeta = "{ ${var.x} }"\n  alpha = "}"\n  mid = { a = "${b}" }\n}\n'
        out, _, _ = run(src)
        self.assertEqual(
            out, 'resource "a" "b" {\n  alpha = "}"\n  mid = { a = "${b}" }\n  zeta = "{ ${var.x} }"\n}\n'
        )

    def test_escaped_interpolation_does_not_open_interpolation(self) -> None:
        src = 'resource "a" "b" {\n  zeta = "$${literal"\n  alpha = 1\n}\nresource "c" "d" {\n  y = 1\n  x = 2\n}\n'
        out, changed, _ = run(src)
        self.assertEqual(len(changed), 2)
        self.assertIn('resource "c" "d" {\n  x = 2\n  y = 1\n}', out)

    def test_heredoc_body_is_opaque(self) -> None:
        src = (
            'resource "a" "b" {\n  zeta = <<-EOT\n    { not = "a block" }\n    alpha = 1\n  EOT\n  alpha = 2\n}\n'
        )
        out, _, _ = run(src)
        self.assertEqual(
            out,
            'resource "a" "b" {\n  alpha = 2\n  zeta = <<-EOT\n    { not = "a block" }\n    alpha = 1\n  EOT\n}\n',
        )

    def test_multiline_values_move_as_a_unit(self) -> None:
        src = 'resource "a" "b" {\n  zeta = [\n    1,\n    2,\n  ]\n  alpha = {\n    k = "v"\n  }\n}\n'
        out, _, _ = run(src)
        self.assertEqual(
            out,
            'resource "a" "b" {\n  alpha = {\n    k = "v"\n  }\n  zeta = [\n    1,\n    2,\n  ]\n}\n',
        )

    def test_comment_containing_braces(self) -> None:
        src = 'resource "a" "b" {\n  zeta = 1 # {\n  alpha = 2 // }\n}\n'
        out, _, _ = run(src)
        self.assertEqual(out, 'resource "a" "b" {\n  alpha = 2 // }\n  zeta = 1 # {\n}\n')

    def test_crlf_preserved(self) -> None:
        src = 'resource "a" "b" {\r\n  zeta = 1\r\n  alpha = 2\r\n}\r\n'
        out, _, _ = run(src)
        self.assertEqual(out, 'resource "a" "b" {\r\n  alpha = 2\r\n  zeta = 1\r\n}\r\n')

    def test_condition_operators_are_not_attributes(self) -> None:
        src = 'resource "a" "b" {\n  zeta = a == b ? 1 : 2\n  alpha = c\n}\n'
        out, _, _ = run(src)
        self.assertEqual(out, 'resource "a" "b" {\n  alpha = c\n  zeta = a == b ? 1 : 2\n}\n')


class VerifyAndCliTest(unittest.TestCase):
    def test_rewrite_is_idempotent(self) -> None:
        src = 'module "m" {\n  zeta = 1\n  source = "s"\n  alpha = 2\n  depends_on = [x]\n}\n'
        once, _, _ = run(src)
        twice, changed, _ = run(once)
        self.assertEqual(once, twice)
        self.assertEqual(changed, [])
        self.assertIsNone(tao.verify(src, once))

    def test_verify_detects_lost_line(self) -> None:
        self.assertIsNotNone(tao.verify("a = 1\nb = 2\n", "a = 1\n"))

    def test_cli_check_and_fix(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "main.tf"
            target.write_text('resource "a" "b" {\n  zeta = 1\n  alpha = 2\n}\n', encoding="utf-8")
            self.assertEqual(tao.main([str(target)]), 1)
            self.assertIn("zeta = 1\n  alpha", target.read_text(encoding="utf-8"))
            self.assertEqual(tao.main([str(target), "--fix"]), 0)
            self.assertEqual(
                target.read_text(encoding="utf-8"), 'resource "a" "b" {\n  alpha = 2\n  zeta = 1\n}\n'
            )
            self.assertEqual(tao.main([str(target)]), 0)

    def test_cli_skips_terraform_cache_dir(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            cached = Path(tmp) / ".terraform" / "modules" / "x"
            cached.mkdir(parents=True)
            (cached / "main.tf").write_text('resource "a" "b" {\n  z = 1\n  a = 2\n}\n', encoding="utf-8")
            self.assertEqual(tao.main([tmp]), 0)


class AtomicWriteTest(unittest.TestCase):
    def test_fix_keeps_file_mode_and_leaves_no_temporary_files(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "main.tf"
            target.write_text('resource "a" "b" {\n  zeta = 1\n  alpha = 2\n}\n', encoding="utf-8")
            target.chmod(0o640)
            self.assertEqual(tao.main([str(target), "--fix"]), 0)
            self.assertEqual(target.stat().st_mode & 0o777, 0o640)
            self.assertEqual([entry.name for entry in Path(tmp).iterdir()], ["main.tf"])

    def test_failed_write_leaves_original_untouched_and_cleans_up(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "main.tf"
            original = 'resource "a" "b" {\n  zeta = 1\n  alpha = 2\n}\n'
            target.write_text(original, encoding="utf-8")
            with mock.patch.object(os, "replace", side_effect=OSError("disk full")):
                with self.assertRaises(OSError):
                    tao.write_atomically(target, "rewritten\n")
            self.assertEqual(target.read_text(encoding="utf-8"), original)
            self.assertEqual([entry.name for entry in Path(tmp).iterdir()], ["main.tf"])


if __name__ == "__main__":
    unittest.main()
