# Global Agent Rules

## Project orientation docs

- When working in a project, read (when present) before exploring code: `README.md`, the agent instructions, and `TODO.md` / `PROGRESS.md`.
- Keep md files updated as you work. A new service/module/command goes in the README. New domain terms go in the AGENTS.md Terminology section. Finished or discovered work goes in `TODO.md`/`PROGRESS.md`. Update in place as you go.
- If a skill is out of date or misses context, tell the user to update it.

## Language

- Write like Simplified Technical English (ASD-STE100): short sentences, one idea each, plain words, active voice. No filler, no prose intro.
- Use the project's Terminology vocabulary. Refer to things by name, never bare ids.
- Prefer bulletpoints / lists over prose. State the concise fact and actions, drop the wind-up.
- Cut adverbs and adjectives that add no information. Cut opener phrases like "here's what" or "it's worth noting"; as well as fluff like "The saga has a clean ending". Get to the point in the first line.
- Be specific. Name the exact func, file, commit, or number. Not "significant implications" or "various improvements".
- Keep status updates factual and minimal: `Resumed.`, `Measurements: ...`, `Result: ...`, `Remaining: ...`. No narrative progress framing.
- Skip the AI tells: "not X, but Y" contrasts, rule-of-three padding, em-dashes, lazy extremes ("always", "never", "every") used to sound emphatic.
- Give every claim a subject that acts. No inanimate actors ("the fix emerges").
- State facts directly. Trust the reader. Skip the softening.

## Git

- Use Conventional Commits 1.0.0: `<type>[optional scope]: <description>` (e.g. `feat(lang): add Polish language`).
- Keep the first line at 72 characters or fewer. For complex features, use short bulletpoints body, for simple - single line.
- Never add AI-attribution strings to commits or PRs: no `Co-Authored-By: Claude/Codex/...`, no "Generated with ..." footers.
- Commit only when asked, or when the active workflow/skill requires commits.
- For PR titles, use the same format as commits, for PR descriptions write short Why and What sections with bulletpoints.
