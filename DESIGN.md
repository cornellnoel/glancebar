# Design Rationale

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

**20% is the most universal danger threshold.** Apple, Android, and most games converge on it.

### Cognitive science

- **3-4 color states is optimal** for at-a-glance indicators. Beyond 5-6 states, pre-attentive processing breaks down and users must consciously interpret the color (Healey, 1996).
- **Discrete color jumps beat gradients.** Colors must cross categorical boundaries (green → red as perceived categories) to be instantly distinguishable. A smooth gradient is harder to read at a glance.
- **Color alone isn't enough.** ~8% of men have red-green color blindness. The bar shape (growing blocks) acts as a secondary signal — you can read the meter even without color.

### Why the bar fills up (not drains down)

An earlier design showed remaining context as a draining meter. The problem: the thing you most need to notice (low context) became the smallest, least visible element on screen. Flipping it so the bar fills up means more blocks = more urgency = more visible when it matters.

### Why all-or-nothing blocks (not partial fill)

Braille characters can show partial fill (bottom-to-top dot patterns), but this creates a staircase effect that looks broken. Each partially-filled block has dots at the bottom while the previous block is full top-to-bottom. All-or-nothing blocks produce clean, instantly-readable silhouettes.

### Why 6 blocks

- **4 blocks**: Too chunky. 25% per step means 2-25% all look identical.
- **8 blocks**: Wider than needed. Adjacent states (55% vs 60%) look identical, wasting space.
- **6 blocks**: ~16.7% per step. Enough resolution for meaningful visual change, compact enough to not dominate the statusline.

## References

- Healey, C.G. (1996). "Choosing Effective Colours for Data Visualization." IEEE Visualization.
- Miller, G.A. (1956). "The Magical Number Seven, Plus or Minus Two." Psychological Review.
- Harrison, C. et al. "Faster Progress Bars: Manipulating Perceived Duration with Visual Augmentations." Carnegie Mellon University.
