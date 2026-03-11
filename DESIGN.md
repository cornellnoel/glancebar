# Design Rationale

We did some light research on HCI, cognitive science, and platform conventions to inform the design decisions in Glancebar. This document captures what we found and why it led to the choices we made.

## Why these color thresholds?

The 4-zone system (green → yellow → orange → red) is based on research into pre-attentive processing and real-world platform conventions.

### Platform conventions

| Platform | Normal | Warning | Critical |
|----------|--------|---------|----------|
| Apple iOS/macOS battery | Green/white | — | Red at 20% |
| Android battery | Normal | — | Red at 20% |
| Windows 11 battery | Green | Orange (30%) | Red (~6%) |
| Windows disk space | Blue | — | Red at ~10% free |
| Game health bars | Green | Yellow (~50%) | Red (~20%) |

**20% is the most universal danger threshold.** Apple, Android, and most games converge on it. We use 10% for red (context is more precious than battery — by 10% remaining, you really need to know) and 20% for orange as the "wrap it up" signal.

### Pre-attentive processing

Pre-attentive processing happens in under 200-500 milliseconds — before conscious attention kicks in. Color is one of the strongest pre-attentive features: a red element among green ones "pops out" without scanning.

> "Only 5-7 colors can be identified rapidly and accurately in pre-attentive visual search. Beyond that, accuracy drops significantly."
> — Healey, C.G. (1996). *Choosing Effective Colours for Data Visualization*. [Paper](https://www.csc2.ncsu.edu/faculty/healey/download/viz.96.pdf) · [Perception in Visualization](https://www.csc2.ncsu.edu/faculty/healey/PP/)

This is why we use 4 color states, not 6 or 8. Four is safely within the range where your brain processes the color instantly without thinking.

### Discrete jumps vs. gradients

Colors must cross categorical boundaries to be instantly distinguishable. A smooth gradient from green to red is actually harder to read at a glance than discrete color jumps.

> "Colors that cross categorical boundaries (e.g., from 'green' to 'red' as perceived categories) are instantly distinguishable. Within-category variations are not."
> — Healey, C.G. on color category effects in visual search

This is why we use hard color transitions (green → yellow → orange → red) rather than a smooth gradient.

### Cognitive load

> "The Magical Number Seven, Plus or Minus Two: Some Limits on Our Capacity for Processing Information"
> — Miller, G.A. (1956). *Psychological Review*. [Laws of UX summary](https://lawsofux.com/millers-law/)

While Miller's Law is about working memory (not status indicators specifically), the core insight applies: keep the number of states well below 7. For a single peripheral indicator you glance at while working, 3-4 states is the sweet spot — enough to be informative, few enough to be instant.

### The color-blindness problem

> "Approximately 8% of men and 0.5% of women have some form of red-green color deficiency."
> — [Color Pre-attentive Processing in HCI](https://www.sciencedirect.com/science/article/abs/pii/S0169814107002211)

Color alone isn't enough. That's why the bar shape (growing blocks) acts as a secondary signal — you can read the meter's urgency from its size even without color. This principle of redundant encoding is a basic accessibility requirement for any color-coded system.

### A surprising finding about green

> "Green elements actually attract more visual attention than red ones on screen (due to luminance properties), which is the opposite of the desired effect."
> — [Green is Not Always Good - UX Planet](https://uxplanet.org/green-is-not-always-good-136e1b1df018)

Red is meant to signal danger, but green draws the eye first. This is another reason why supplementing color with a growing bar shape matters — at critical levels, the bar is nearly full, creating a large colored mass that's impossible to miss regardless of hue.

## Design decisions

### Why the bar fills up (not drains down)

An earlier design showed remaining context as a draining meter. The problem: the thing you most need to notice (low context) became the smallest, least visible element on screen. Flipping it so the bar fills up means more blocks = more urgency = more visible when it matters.

### Why all-or-nothing blocks (not partial fill)

Braille characters can show partial fill (bottom-to-top dot patterns), but this creates a staircase effect that looks broken. Each partially-filled block has dots at the bottom while the previous block is full top-to-bottom. We tested three approaches side-by-side:

- **All-or-nothing**: Clean, distinct silhouettes at every state
- **Left-to-right column fill** (⡇ as half step): Subtle difference between half and full blocks, hard to distinguish at a glance
- **Horizontal block characters** (▏▎▍▌▋▊▉█): Smooth but loses the dot/braille aesthetic

All-or-nothing won on discriminability — the job of this bar is "glance and know," not precision. The percentage number provides precision; the bar provides the gestalt.

### Why 6 blocks

- **4 blocks**: Too chunky. 25% per step means 2-25% all look identical — that's a quarter of your session with zero visual feedback.
- **8 blocks**: Wider than needed. Adjacent states (55% vs 60%) are visually identical, so the extra width adds no information.
- **6 blocks**: ~16.7% per step. Enough resolution for meaningful visual change at each stage, compact enough to not dominate the statusline.

### Progress bar perception research

> "Bars that decelerate feel slower. Bars with ribbed textures moving backward feel faster."
> — Harrison, C. et al. *Faster Progress Bars: Manipulating Perceived Duration with Visual Augmentations*. Carnegie Mellon University. [Paper](https://www.chrisharrison.net/projects/progressbars2/ProgressBarsHarrison.pdf)

While this research is about perceived duration rather than status indicators, it reinforces that visual design of progress bars meaningfully affects user experience — it's worth getting right.

## References

- Healey, C.G. (1996). "Choosing Effective Colours for Data Visualization." IEEE Visualization. [PDF](https://www.csc2.ncsu.edu/faculty/healey/download/viz.96.pdf)
- Healey, C.G. "Perception in Visualization." NC State University. [Site](https://www.csc2.ncsu.edu/faculty/healey/PP/)
- Miller, G.A. (1956). "The Magical Number Seven, Plus or Minus Two." *Psychological Review*. [Laws of UX](https://lawsofux.com/millers-law/)
- Harrison, C. et al. "Faster Progress Bars: Manipulating Perceived Duration with Visual Augmentations." Carnegie Mellon University. [PDF](https://www.chrisharrison.net/projects/progressbars2/ProgressBarsHarrison.pdf)
- Nielsen Norman Group. "Progress Indicators Make a Slow System Less Insufferable." [Article](https://www.nngroup.com/articles/progress-indicators/)
- Carbon Design System. "Status Indicator Pattern." [Docs](https://carbondesignsystem.com/patterns/status-indicator-pattern/)
- UX Planet. "Green is Not Always Good." [Article](https://uxplanet.org/green-is-not-always-good-136e1b1df018)
- UX Planet. "Preattentive Processing and Design." [Article](https://uxplanet.org/preattentive-processing-and-design-e59eba74373e)
- UX Planet. "Progress Bar Design Best Practices." [Article](https://uxplanet.org/progress-bar-design-best-practices-526f4d0a3c30)
- Bernard Marr. "How to Use Traffic Light Colours and RAG Ratings in Dashboards." [Article](https://bernardmarr.com/performance-reporting-how-to-use-traffic-light-colours-and-rag-ratings-in-dashboards/)
