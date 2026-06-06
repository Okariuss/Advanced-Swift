# Advanced Swift Series

Companion repository for the **Advanced Swift Series** published on [iCommunity](https://medium.com/icommunity).

Each chapter covers a specific area of Swift performance. Every concept is backed by a playground to experiment with, and where it makes sense, a real UIKit app that applies the same ideas in a production context.

---

## Chapters

### [01 — Collections](./01-Collections)

How Swift's collection types actually work under the hood — and how to choose the right one.

| Playground | Article |
|------------|---------|
| [Arrays](./01-Collections/Arrays.playground) | [Swift Arrays: Hidden Performance Traps Most Developers Miss](https://medium.com/icommunity/swift-arrays-hidden-performance-traps-most-developers-miss-77b1a11fc0c9) |
| [Dictionaries](./01-Collections/Dictionaries.playground) | [Advanced Dictionaries: Performance and Hidden Traps](https://medium.com/icommunity/advanced-dictionaries-performance-and-hidden-traps-01921daaa164) |
| [Sets & Ranges](./01-Collections/SetsRangesWorkspace) | [Swift's Performance Weapons: Set, OrderedSet, Range and RangeSet](https://medium.com/icommunity/swifts-performance-weapons-set-orderedset-range-and-rangeset-c0ce078411f0) |

**[CollectionVault](./01-Collections/Collections%20App)** — a UIKit app built alongside the articles. `Set<UUID>` for O(1) favorites lookup, a custom `OrderedSet` for search history with MRU behaviour, `RangeSet` for efficient bulk deletion, and `reduce(into:)` for duplicate detection. Every choice is documented with the reasoning behind it. → [See the full article ↔ code mapping](./01-Collections/Collections%20App/README.md)

---

> More chapters coming soon.

---

## Author

**Okan Orkun** — [Medium](https://medium.com/@orkunokann) · [iCommunity](https://medium.com/icommunity)
