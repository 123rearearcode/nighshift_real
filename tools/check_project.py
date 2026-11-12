#!/usr/bin/env python3
"""Consistency checks for the Nightshift Godot project.

This does NOT run Godot and does NOT prove the game works. It catches the mistakes
that waste a contributor's time: version numbers that disagree, a changelog entry
missing its required sections or an AI author's model signature, broken res:// paths, tab indentation, unbalanced
brackets, and files missing from the file map in DEVELOPMENT.md.

Usage (from anywhere):
    python3 -I tools/check_project.py [path/to/project/folder]

Exit code 0 = all checks passed, 1 = at least one problem.
"""
import pathlib
import re
import sys

REQUIRED_SECTIONS = ("### Execution status", "### Files changed", "### Checks performed")
SEMVER = re.compile(r"^\d+\.\d+\.\d+$")


def read(path):
    return path.read_text(encoding="utf-8")


def project_version(root, problems):
    text = read(root / "project.godot")
    match = re.search(r'^config/version="([^"]*)"', text, re.MULTILINE)
    if not match:
        problems.append("project.godot has no config/version line.")
        return None
    version = match.group(1)
    if not SEMVER.match(version):
        problems.append("config/version %r is not MAJOR.MINOR.PATCH." % version)
    return version


def changelog_top(root, problems):
    """Return (version, block_text) of the newest numbered changelog entry."""
    text = read(root / "CHANGELOG.md")
    heads = list(re.finditer(r"^## (\d+\.\d+\.\d+)\b.*$", text, re.MULTILINE))
    if not heads:
        problems.append("CHANGELOG.md has no '## X.Y.Z - date - title' entry.")
        return None, ""
    start = heads[0].start()
    nxt = re.search(r"^## ", text[heads[0].end():], re.MULTILINE)
    end = heads[0].end() + nxt.start() if nxt else len(text)
    return heads[0].group(1), text[start:end]


def check_versions(root, problems, notes):
    version = project_version(root, problems)
    log_version, block = changelog_top(root, problems)
    if version and log_version and version != log_version:
        problems.append("Version mismatch: project.godot says %s but the newest CHANGELOG entry is %s." % (version, log_version))
    for heading in REQUIRED_SECTIONS:
        if block and heading not in block:
            problems.append("Newest CHANGELOG entry (%s) is missing the section '%s'." % (log_version, heading))
    author = re.search(r"^- Author:(.*)$", block, re.MULTILINE) if block else None
    if block and not author:
        problems.append("Newest CHANGELOG entry (%s) has no '- Author:' line." % log_version)
    elif author and "human" not in author.group(1).lower() and "model id " not in author.group(1):
        problems.append("Newest CHANGELOG entry (%s): an AI author must sign with its model, e.g. "
                        "'- Author: Claude (Opus 5.5, model id claude-opus-5-5) ...'. A person writes '(human)'." % log_version)
    if block and "CHECKS_PLACEHOLDER" in block:
        problems.append("Newest CHANGELOG entry still contains CHECKS_PLACEHOLDER; record the checks actually run.")
    readme = read(root / "README.md")
    first = readme.splitlines()[0] if readme else ""
    if version and ("(v%s)" % version) not in first:
        problems.append("README.md first line should contain '(v%s)': %r" % (version, first))
    if version:
        notes.append("project.godot version is %s" % version)


def scan_brackets(path, problems):
    """Check bracket balance in a .gd file, ignoring strings and # comments."""
    pairs = {")": "(", "]": "[", "}": "{"}
    stack = []
    for lineno, line in enumerate(read(path).splitlines(), 1):
        quote = None
        i = 0
        while i < len(line):
            ch = line[i]
            if quote:
                if ch == "\\":
                    i += 1
                elif ch == quote:
                    quote = None
            elif ch in "\"'":
                quote = ch
            elif ch == "#":
                break
            elif ch in "([{":
                stack.append((ch, lineno))
            elif ch in ")]}":
                if not stack or stack[-1][0] != pairs[ch]:
                    problems.append("%s:%d unmatched %r" % (path.name, lineno, ch))
                    return
                stack.pop()
            i += 1
    if stack:
        problems.append("%s:%d bracket %r is never closed" % (path.name, stack[-1][1], stack[-1][0]))


def check_scripts(root, problems, notes):
    scripts = sorted(root.rglob("*.gd"))
    for path in scripts:
        if ".godot" in path.parts:
            continue
        text = read(path)
        if "\t" in text:
            problems.append("%s contains tab characters (this project indents with 4 spaces)." % path.relative_to(root))
        scan_brackets(path, problems)
        if not re.search(r"^extends\s", text, re.MULTILINE):
            problems.append("%s has no 'extends' line." % path.relative_to(root))
    notes.append("%d .gd scripts scanned (tabs, brackets, extends)" % len(scripts))


def check_res_paths(root, problems, notes):
    count = 0
    files = [root / "project.godot"] + sorted(root.rglob("*.tscn")) + sorted(root.rglob("*.gd"))
    for path in files:
        if ".godot" in path.parts:
            continue
        for ref in re.findall(r"res://[A-Za-z0-9_./-]+", read(path)):
            ref = ref.rstrip(".")
            count += 1
            if not (root / ref[len("res://"):]).is_file():
                problems.append("%s refers to %s, which does not exist." % (path.relative_to(root), ref))
    notes.append("%d res:// references resolved" % count)


def check_file_map(root, problems, notes):
    dev = read(root / "DEVELOPMENT.md")
    tracked = [p for p in sorted(root.rglob("*")) if p.is_file() and ".godot" not in p.parts
               and p.suffix in (".gd", ".tscn", ".md", ".py", ".godot")]
    tracked.append(root / "tools" / ".gdignore")
    for path in tracked:
        rel = path.relative_to(root).as_posix()
        if "`%s`" % rel not in dev:
            problems.append("DEVELOPMENT.md file map does not list `%s`." % rel)
    for ref in set(re.findall(r"`([A-Za-z0-9_./-]+\.(?:gd|tscn|py|md))`", dev)):
        if "/" in ref and not (root / ref).is_file():
            problems.append("DEVELOPMENT.md mentions `%s`, which does not exist." % ref)
    notes.append("file map covers %d files" % len(tracked))


def check_core_documents(root, problems, notes):
    required = ("PROJECT_BRIEF.md", "DESIGN.md", "ROADMAP.md", "DECISIONS.md", "CURRENT_STATE.md")
    for name in required:
        path = root / "docs" / name
        if not path.is_file() or not path.read_text(encoding="utf-8").strip():
            problems.append("Required core document missing or empty: docs/%s" % name)
    notes.append("five required core documents checked")


def main(argv):
    root = pathlib.Path(argv[1]).resolve() if len(argv) > 1 else pathlib.Path(__file__).resolve().parent.parent
    if not (root / "project.godot").is_file():
        print("No project.godot in %s" % root)
        return 1
    problems, notes = [], []
    check_versions(root, problems, notes)
    check_scripts(root, problems, notes)
    check_res_paths(root, problems, notes)
    check_file_map(root, problems, notes)
    check_core_documents(root, problems, notes)
    for note in notes:
        print("info  " + note)
    for problem in problems:
        print("FAIL  " + problem)
    print("%s: %d problem(s)" % ("PASSED" if not problems else "FAILED", len(problems)))
    print("(This does not run Godot. Open the project in Godot 4.7.2 and press F5 to test it.)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
