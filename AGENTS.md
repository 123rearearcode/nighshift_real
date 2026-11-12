# For any AI agent or tool working in this project

Read, in this order: `HANDOFF.md`, `DEVELOPMENT.md`, the newest entry of `CHANGELOG.md`, then the
scripts you will touch. Do not start from this file alone.

Four rules that matter most:
1. Log every change in `CHANGELOG.md` with a new version number (steps in `HANDOFF.md`, section 4).
2. Never say code works unless it was actually run in Godot 4.7.2 (the user's real version). Say exactly what you did run.
3. Do not build anything listed in `docs/DESIGN_PROPOSALS.md` unless the user has asked for it.
4. Sign every edit with your model: name, model name and exact model id (changelog Author line,
   HANDOFF signature, commit messages). Example: `Claude (Opus 5.5, model id claude-opus-5-5)`.

Every handoff ZIP must include docs/PROJECT_BRIEF.md, docs/DESIGN.md, docs/ROADMAP.md, docs/DECISIONS.md and docs/CURRENT_STATE.md. Read STABILISATION.md for the current milestone. Latest explicit user decisions and the reconciled core docs take precedence over stale OPEN labels in local proposal notes.
