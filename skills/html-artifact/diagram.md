# Diagram

Build the smallest visual model that makes the relationship easier to understand than prose alone. Do not force every topic into the same boxes and arrows.

## Pick the grammar from the question

Name the question the reader must answer, then pick the grammar. Do not bend one picture to answer two questions. Use a second diagram instead.

| Question | Grammar |
|---|---|
| What exists, and how is it connected? | Topology or system map |
| What happens over time? | Sequence, timeline, or request trace |
| What decisions or transformations occur? | Process flow |
| How can something change? | State diagram |
| What contains or owns what? | Hierarchy or nested boundary map |
| How do alternatives compare? | Matrix or aligned comparison |
| How much, how often, or how fast? | Chart — see the chart section below |

## Pick the renderer from the information

| Renderer | Use it for |
|---|---|
| HTML and CSS | Labelled regions, aligned comparisons, grids, timelines, text that must reflow |
| Inline SVG | Crisp relational diagrams, custom paths, annotations, interactive vector scenes |
| Mermaid (CDN) | Graph-shaped relations the layout engine handles better than you will |
| Canvas or WebGL | Dense, frequently changing, or generative graphics. Reserve it, and justify the cost |

Prefer SVG over Mermaid for anything editorial. Mermaid output looks generic. Prefer SVG over ASCII art in every case.

Style SVG elements through CSS classes and the artifact's tokens, so the scene stays coherent across themes.

## The glance gate

The gate lives in `SKILL.md` section 7. Two additions for diagrams: align to a grid (a diagonal is noise unless it carries meaning), and split into zoom levels (an overview, then one diagram per area) instead of cramming.

## Size the boxes, because SVG text does not wrap

Text that bleeds past its box is the most common SVG failure.

- **Default: put the label in a `<foreignObject>`.** Real HTML inside wraps to the box.

```html
<foreignObject x="100" y="60" width="180" height="60">
  <div xmlns="http://www.w3.org/1999/xhtml"
       style="width:100%;height:100%;padding:8px 12px;box-sizing:border-box;
              display:flex;align-items:center;justify-content:center;
              font:14px/1.3 system-ui;text-align:center;
              overflow-wrap:anywhere;">
    Order processing queue (high priority)
  </div>
</foreignObject>
```

- **For a short, known label, plain `<text>` is fine.** Size the box from the label, not the other way around: width ≥ `label.length × 8px + 32px` at 14px.
- Keep at least 8px of padding between the text and the edge of the shape.
- Keep at least 40px between adjacent nodes, so labels never collide.
- Put a background rect behind an edge label. A label over a crossing path is unreadable.
- A label longer than about 32 characters is not a single line. Shorten it, or wrap it.
- Test with the longest real value, not the value from the prompt.

## Charts and data

Start with the comparison the reader must make. Pick the chart from that question, not from visual novelty.

| Question | Chart |
|---|---|
| Change over time | Line, area, or aligned small multiples |
| Ranked magnitude | Ordered bars, or a table with visual emphasis |
| Part to whole | Stacked bars, when the denominator means something |
| Distribution | Histogram, dot plot, or box plot |
| Relationship | Scatter plot with meaningful axes |
| Flow with magnitude | Sankey, and only when the path magnitude is the point |

Use a table when the exact value matters more than the shape. A chart and a compact table can sit together when they serve different reading needs.

Make the data honest:

- Label the units, the time range, the source, and the active filters.
- Make truncation and a non-linear scale explicit.
- Separate measured values, estimates, targets, and forecasts. Mark an illustrative value as illustrative.
- Never invent a data point to fill the picture.
- Keep category colours consistent, and distinguish categories by shape or label as well as colour.
- Keep status colours (good, warning, critical) in their own lane, apart from the accent hue.
- Use `font-variant-numeric: tabular-nums` wherever numerals stack into columns.

Add a tooltip only to add precision. Essential values and the conclusion stay visible without hover. Add a filter or a zoom only when it answers a real follow-up question, and show the active state with a reset.

Use animation to explain a change between states. Never make the bars perform on arrival.

## Sequence and interaction

Expose causality, not a flash of elements.

- Give each step a durable label and a visible current state.
- Let the reader play, pause, step, and choose a path when the sequence is more than a short animation.
- Keep the whole system understandable while the animation is stopped.
- Respect `prefers-reduced-motion` with a step-based alternative.
- Make a selected node obvious. A floating panel must dismiss and reopen from its node, and the reader must reach it by keyboard.

## Pan and zoom, only when needed

A diagram that fits does not need to become a map application. Add pan and zoom when the information genuinely exceeds the viewport.

For an SVG stage:

- Transform one containing `<g>`, not every node.
- Keep the pointer, pan, and zoom math in one coordinate system. Keep the point under the cursor fixed while zooming.
- Suppress the click after a drag, with a small movement threshold.
- Give `grab` and `grabbing` feedback, a visible zoom level, and a reset control.

## Verify the picture

Inspect the default view, every interactive state, and both ends of a sequence. Check that no connector crosses a label, every arrow terminates cleanly, no text is clipped, and a narrow screen has a deliberate fallback. Re-read the glance gate list before you report.
