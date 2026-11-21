"""Exercise actual Git diffs so docs/version filtering cannot hide runtime changes."""
import tempfile
import unittest
from pathlib import Path
from ci_scope import git, scope


class ScopeTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        git(self.root, "init", "-q")
        git(self.root, "config", "user.name", "CI scope fixture")
        git(self.root, "config", "user.email", "fixture@example.invalid")
        self.write("project.godot", 'config/version="0.20.0"\nother=true\n')
        self.write("README.md", "old\n")
        self.write("scripts/bench/dust_sim.gd", "original\n")
        self.commit()
        self.base = git(self.root, "rev-parse", "HEAD").strip()

    def tearDown(self):
        self.tmp.cleanup()

    def write(self, path, content):
        target = self.root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")

    def commit(self):
        git(self.root, "add", "-A")
        git(self.root, "commit", "-qm", "fixture")

    def result(self, **kwargs):
        self.commit()
        return scope(self.root, self.base, **kwargs)

    def test_docs_plus_version_skip_runtime(self):
        self.write("README.md", "new\n")
        self.write("docs/new.md", "proposal\n")
        self.write("project.godot", 'config/version="0.20.1"\nother=true\n')
        self.assertEqual(self.result(), {"runtime": False, "full": False})

    def test_other_project_setting_never_skips(self):
        self.write("project.godot", 'config/version="0.20.1"\nother=false\n')
        self.assertEqual(self.result(), {"runtime": True, "full": False})

    def test_bench_change_runs_full(self):
        self.write("scripts/bench/dust_sim.gd", "changed\n")
        self.assertEqual(self.result(), {"runtime": True, "full": True})

    def test_deleted_physics_file_runs_full(self):
        (self.root / "scripts/bench/dust_sim.gd").unlink()
        self.assertEqual(self.result(), {"runtime": True, "full": True})

    def test_test_or_workflow_change_runs_runtime(self):
        self.write(".github/workflows/tests.yml", "changed\n")
        self.write("tools/test_regressions.gd", "changed\n")
        self.assertEqual(self.result(), {"runtime": True, "full": False})

    def test_renaming_code_to_markdown_does_not_skip(self):
        (self.root / "scripts/bench/dust_sim.gd").rename(self.root / "removed-code.md")
        self.assertEqual(self.result(), {"runtime": True, "full": True})

    def test_manual_default_runs_suites_and_smoke(self):
        self.assertEqual(scope(self.root, "", manual=True), {"runtime": True, "full": False})
        self.assertEqual(scope(self.root, "", manual=True, force_full=True), {"runtime": True, "full": True})

    def test_manual_full_overrides_docs(self):
        self.write("README.md", "new\n")
        self.assertEqual(self.result(force_full=True), {"runtime": True, "full": True})

    def test_unknown_base_fails_open_to_full_verification(self):
        self.assertEqual(scope(self.root, "0" * 40), {"runtime": True, "full": True})
        self.assertEqual(scope(self.root, "missing-ref"), {"runtime": True, "full": True})


if __name__ == "__main__":
    unittest.main()
