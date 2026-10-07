"""Regression fixtures for the checks: broken study routes must fail CI."""
from pathlib import Path
import tempfile
import unittest

from check_docs import anchors, check_document
from test_lessons import select_simulator, validate_result


class DocumentationChecks(unittest.TestCase):
    def check(self, text, files=None):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            source = root / "README.md"
            source.write_text(text)
            for name, content in (files or {}).items():
                (root / name).write_text(content)
            return check_document(source, root)

    def test_encoded_paths_and_html_images(self):
        self.assertEqual(self.check('[Lesson](My%20Lesson.md#exercise)\n<img src="screen.png">',
                                    {"My Lesson.md": "# Exercise", "screen.png": "image"}), [])

    def test_missing_source_and_image_are_reported(self):
        self.assertEqual(len(self.check('[Source](missing.swift)\n<img src="missing.png">')), 2)

    def test_heading_fragment_is_checked(self):
        self.assertEqual(len(self.check('[Exercise](lesson.md#wrong)', {"lesson.md": "# Exercise"})), 1)

    def test_examples_and_external_urls_are_ignored(self):
        self.assertEqual(self.check('```md\n[Example](missing.md)\n```\n[Swift](https://swift.org)'), [])

    def test_duplicate_headings(self):
        self.assertEqual(anchors('# Try it!\n## Try it!'), {"try-it", "try-it-1"})

    def test_paths_outside_repository_fail(self):
        self.assertEqual(len(self.check('[Outside](../outside.md)')), 1)


class SimulatorChecks(unittest.TestCase):
    def test_prefers_available_booted_device(self):
        devices = {"com.apple.CoreSimulator.SimRuntime.iOS-26-2": [
            {"name": "iPhone 17", "isAvailable": False, "udid": "missing", "state": "Booted"},
            {"name": "iPhone 17", "isAvailable": True, "udid": "cold", "state": "Shutdown"},
            {"name": "iPhone 17", "isAvailable": True, "udid": "ready", "state": "Booted"}]}
        self.assertEqual(select_simulator(devices, "iPhone 17", "26.2"), "ready")

    def test_missing_runtime_has_actionable_failure(self):
        with self.assertRaisesRegex(ValueError, 'Install the runtime'):
            select_simulator({}, "iPhone 17", "26.2")


class ResultChecks(unittest.TestCase):
    def test_zero_tests_cannot_be_success(self):
        with self.assertRaisesRegex(ValueError, "No tests passed"):
            validate_result({"totalTestCount": 0, "passedTests": 0, "result": "Passed"})

    def test_failure_cannot_be_success(self):
        with self.assertRaises(ValueError):
            validate_result({"totalTestCount": 2, "passedTests": 1, "failedTests": 1, "result": "Failed"})

    def test_real_passing_result_is_accepted(self):
        validate_result({"totalTestCount": 14, "passedTests": 14, "failedTests": 0, "result": "Passed"})


if __name__ == "__main__":
    unittest.main()
