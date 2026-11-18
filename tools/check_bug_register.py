"""Validate the bug index, evidence links and next review without running the game."""
from pathlib import Path
import re
import sys

STATUSES = {"Open", "Investigating", "Fixed", "Verified"}
SEVERITIES = {"Critical", "High", "Medium", "Low"}
HEADER = "| ID | Status | Severity | Area | Summary | Fixed in | Evidence |"


def check(text, root, current_version=None):
    problems = []
    if text.count(HEADER) != 1:
        problems.append("Use exactly one canonical bug-index table header.")
    rows = {}
    in_index = False
    for number, line in enumerate(text.splitlines(), 1):
        if line == "## Bug index":
            in_index = True
        elif line.startswith("## "):
            in_index = False
        if not re.match(r"^\| B\d+ \|", line):
            continue
        if not in_index:
            problems.append(f"Line {number}: bug row outside the canonical index.")
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) != 7:
            problems.append(f"Line {number}: expected seven index columns.")
            continue
        bug_id, status, severity, area, summary, fixed, evidence = cells
        if bug_id in rows:
            problems.append(f"Duplicate bug id: {bug_id}.")
        rows[bug_id] = cells
        if status not in STATUSES:
            problems.append(f"{bug_id}: invalid status {status!r}.")
        if severity not in SEVERITIES:
            problems.append(f"{bug_id}: invalid severity {severity!r}.")
        if not area or not summary or not evidence:
            problems.append(f"{bug_id}: area, summary and evidence are required.")
        if status in {"Fixed", "Verified"} and fixed in {"", "—", "-"}:
            problems.append(f"{bug_id}: fixed/verified requires a fixed version.")
        if status in {"Open", "Investigating"} and fixed not in {"", "—", "-"}:
            problems.append(f"{bug_id}: unresolved bug cannot have a fixed version.")
        if status == "Verified" and not evidence.startswith(("Automated", "User", "Graphical")):
            problems.append(f"{bug_id}: Verified requires an explicit verification type.")
    if not rows:
        problems.append("Bug index is empty or missing.")
    details = list(re.finditer(r"^### (B\d+) — .+$", text, re.M))
    seen = set()
    for i, match in enumerate(details):
        bug_id = match.group(1)
        if bug_id in seen:
            problems.append(f"Duplicate detail section: {bug_id}.")
        seen.add(bug_id)
        if bug_id not in rows:
            problems.append(f"Unindexed detail section: {bug_id}.")
        end = details[i + 1].start() if i + 1 < len(details) else len(text)
        section = text[match.end():end]
        for field in ("Found", "Reported by", "Root cause", "Regression / evidence"):
            if not re.search(rf"^- {re.escape(field)}: .+", section, re.M):
                problems.append(f"{bug_id}: missing detail field {field!r}.")
        if bug_id in rows and rows[bug_id][1] == "Verified":
            if not re.search(r"`tools/[^`]+`|https?://\S+", section):
                problems.append(f"{bug_id}: link the executable verification or recorded evidence.")
    for bug_id in rows.keys() - seen:
        problems.append(f"Missing detail section: {bug_id}.")
    for path in re.findall(r"`((?:tools|scripts)/[^`\s]+\.(?:gd|py))`", text):
        if not (root / path).is_file():
            problems.append(f"Evidence file does not exist: {path}.")
    review = re.search(r"^Next structural review: \*\*(\d+\.\d+\.\d+)\*\*", text, re.M)
    if not review:
        problems.append("Missing next structural review marker.")
    elif current_version:
        version = lambda value: tuple(map(int, value.split(".")))
        if version(review.group(1)) <= version(current_version):
            problems.append("Structural review is due: complete it and advance its marker.")
    return problems


def main():
    root = Path(__file__).resolve().parents[1]
    version = re.search(r'config/version="([^"]+)"', (root / "project.godot").read_text(encoding="utf-8")).group(1)
    problems = check((root / "docs/BUGS.md").read_text(encoding="utf-8"), root, version)
    for problem in problems:
        print("FAIL:", problem)
    print(f"Bug register: {len(problems)} problem(s)")
    return bool(problems)


if __name__ == "__main__":
    sys.exit(main())
