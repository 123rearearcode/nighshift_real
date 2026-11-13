"""Choose CI work conservatively. Only Markdown + a version-only bump may skip Godot."""
from pathlib import Path
import argparse
import os
import re
import subprocess


def git(root, *args):
    return subprocess.check_output(["git", "-C", str(root), *args], text=True, stderr=subprocess.DEVNULL)


def scope(root, base, head="HEAD", force_full=False, manual=False):
    if manual:
        return {"runtime": True, "full": force_full}
    try:
        if not base or set(base) == {"0"}:
            raise ValueError("no trustworthy base")
        paths = git(root, "diff", "--no-renames", "--name-only", base, head).splitlines()
        runtime = False
        full = force_full
        for path in paths:
            if path.endswith(".md"):
                continue
            if path == "project.godot":
                diff = git(root, "diff", "--unified=0", base, head, "--", path)
                changes = [line[1:] for line in diff.splitlines()
                           if line[:1] in ["+", "-"] and not line.startswith(("+++", "---"))]
                if changes and all(re.fullmatch(r'config/version="\d+\.\d+\.\d+"', line) for line in changes):
                    continue
            runtime = True
            if (path.startswith(("scripts/bench/", "scripts/data/"))
                    or path in ["scripts/view/bench_view.gd", "scripts/view/part_motion.gd", "tools/playtest_bench.gd"]):
                full = True
        return {"runtime": runtime or full, "full": full}
    except (subprocess.CalledProcessError, ValueError):
        # Unknown history must never silently skip verification.
        return {"runtime": True, "full": True}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", default=os.environ.get("CI_BASE_SHA", ""))
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--head", default="HEAD")
    args = parser.parse_args()
    result = scope(args.root, args.base, args.head, os.environ.get("CI_FORCE_FULL", "false").lower() == "true",
                   os.environ.get("CI_MANUAL", "false").lower() == "true")
    lines = [f"runtime={str(result['runtime']).lower()}", f"full={str(result['full']).lower()}"]
    print("CI scope: " + ", ".join(lines))
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as output:
            output.write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
