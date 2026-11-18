"""Malformed-register fixtures: keep the ledger's guard effective as it grows."""
from pathlib import Path
import tempfile
import unittest

from check_bug_register import check, HEADER


class BugRegisterTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "tools").mkdir()
        (self.root / "tools/test_example.gd").write_text("extends SceneTree\n")
        self.text = "\n".join([
            "# Register", "Next structural review: **0.50.0**", "## Bug index", HEADER,
            "| --- | --- | --- | --- | --- | --- | --- |",
            "| B1 | Verified | High | Save | Missing key | 0.47.1 | Automated |",
            "## Bug details", "### B1 — Missing key", "- Found: 0.47.0",
            "- Reported by: fixture", "- Root cause: absent key",
            "- Regression / evidence: `tools/test_example.gd`", "",
        ])

    def errors(self, text):
        return check(text, self.root, "0.47.1")

    def test_valid_verified_record(self):
        self.assertEqual([], self.errors(self.text))

    def test_user_verification_can_link_a_recording(self):
        text = self.text.replace("Automated", "User").replace("`tools/test_example.gd`", "https://example.com/reproduction.mp4")
        self.assertEqual([], self.errors(text))

    def test_open_record_needs_no_fixed_version(self):
        text = self.text.replace("Verified", "Open").replace("0.47.1 |", "— |")
        self.assertEqual([], self.errors(text))

    def test_unresolved_with_fixed_version(self):
        self.assertTrue(self.errors(self.text.replace("Verified", "Investigating")))

    def test_duplicate_id(self):
        row = "| B1 | Fixed | High | Save | Duplicate | 0.47.1 | Historical |\n"
        self.assertTrue(self.errors(self.text.replace("## Bug details", row + "## Bug details")))

    def test_detached_row(self):
        self.assertTrue(self.errors(self.text + "| B2 | Open | Low | UI | Detached | — | Pending |\n"))

    def test_missing_details(self):
        self.assertTrue(self.errors(self.text.replace("### B1 —", "### B2 —")))

    def test_missing_root_cause(self):
        self.assertTrue(self.errors(self.text.replace("- Root cause:", "- Cause:")))

    def test_verification_without_evidence(self):
        self.assertTrue(self.errors(self.text.replace("Automated", "Historical")))

    def test_broken_evidence_path(self):
        self.assertTrue(self.errors(self.text.replace("test_example.gd", "missing.gd")))

    def test_due_review(self):
        self.assertTrue(self.errors(self.text.replace("0.50.0", "0.40.0")))

    def test_bad_status_and_severity(self):
        self.assertTrue(self.errors(self.text.replace("Verified | High", "Done | Urgent")))


if __name__ == "__main__":
    unittest.main()
