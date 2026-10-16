# Global Agent Rules

## Project orientation docs

- When working in a project, read (when present) before exploring code: `README.md`, the agent instructions, and `TODO.md` / `PROGRESS.md`.
- Keep md files updated as you work. A new service/module/command goes in the README. New domain terms go in the AGENTS.md Terminology section. Finished or discovered work goes in `TODO.md`/`PROGRESS.md`. Update in place as you go.
- If a skill is out of date or misses context, tell the user to update it.

## Language

- Write in Simplified Technical English (ASD-STE100), about 90% of the way. The reader is tired, under time pressure, and reads English as a second language. A sentence that needs a second pass is a defect.
- One idea per sentence. 20 words maximum for an instruction, 25 for an explanation. Active voice with a named subject. Simple tenses. `can`, `will` and `must` are the only modals. No contraction, no semicolon, no trailing `-ing` clause, no em-dash.
- Never delete a fact, an article, or the word `that` to fit a limit. Split the sentence. Never invent a number to replace a vague adjective. Drop the adjective.
- Code blocks, identifiers, commands, flags, paths, config keys, product names, and quoted error or log lines are exempt. Reproduce them exactly.
- Use the project's Terminology vocabulary. Refer to things by name, never bare ids.
- Prefer lists over prose. Get to the point in the first line. Cut opener phrases ("here's what", "it's worth noting"), filler, adverbs and adjectives that add no information, and AI tells ("not X, but Y", rule-of-three padding, emphatic "always"/"never").
- Be specific. Name the exact function, file, commit, or number.
- Status updates are factual and minimal: `Resumed.`, `Result: ...`, `Remaining: ...`.
- Scan every draft against these rules before you send it. The scan is part of writing.

## Git

- Use Conventional Commits 1.0.0: `<type>[optional scope]: <description>` (e.g. `feat(lang): add Polish language`).
- Keep the first line at 72 characters or fewer. For complex features, use short bulletpoints body, for simple - single line.
- Never add AI-attribution strings to commits or PRs: no `Co-Authored-By: Claude/Codex/...`, no "Generated with ..." footers.
- Commit only when asked, or when the active workflow/skill requires commits.
- For PR titles, use the same format as commits, for PR descriptions write short Why and What sections with bulletpoints.
