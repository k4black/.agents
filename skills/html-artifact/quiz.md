# End-of-artifact quiz

Close a teaching artifact with an interactive quiz. The reader then learns whether the main idea landed, while the page is still open.

Eligibility is in `SKILL.md` section 8.

## Questions

- Write 4 to 6 questions. Five is the default.
- Test the main idea of the artifact, not a memorable detail. One question per section at most.
- Every question carries one correct option, three or four plausible wrong options, and a feedback line per option.
- The feedback line for a wrong option states why that answer fails. "Incorrect" alone teaches nothing.
- Cover the point the reader most likely gets wrong, and the one the artifact exists to explain.
- Keep a question answerable from the page alone. Never require an outside source.

## Behaviour

- Vanilla JavaScript only. No framework, no library, no CDN script for the quiz.
- Render each option as a `<button>`, so it is focusable and operable by keyboard.
- On a click, or on `Enter` or `Space`, reveal correct or incorrect at once, with the feedback line for the chosen option.
- Announce the result in an `aria-live="polite"` region.
- Keep the score in a summary at the end of the quiz: the number correct, out of the number asked.
- Offer a reset, so the reader can try again.

## Data and order

Keep the quiz as one array of objects:

```js
const quiz = [
  {
    question: "Which rule decides the diagram size?",
    options: [
      { text: "The glance gate", correct: true,  feedback: "Right. Every visual must read in one look." },
      { text: "The node count",  correct: false, feedback: "Node count is a symptom. The gate is the one-look rule." }
    ]
  }
];
```

Shuffle the options with Fisher-Yates on every page load, so no position bias survives a refresh. Keep each feedback line attached to its own option object, never to a rendered position. Assign the A/B/C/D labels after the shuffle.

## Accessibility

- Reach and operate the whole quiz by keyboard.
- Mark the chosen option with a shape or an icon as well as a colour.
- Keep contrast at WCAG AA or better on the correct and incorrect states.
- Never hide the score or the feedback behind hover.

## Layout

Place the quiz last, under its own heading, before the sources and the footer. Mark it clearly as a comprehension check, so the reader knows it is not part of the argument.
