# CollectionVault

A companion project for the **Advanced Swift Series** on Medium. Every data structure choice in this app is intentional — each one maps directly to a concept covered in the articles below.

> Read the articles first, then explore the code to see the same ideas applied in a real UIKit app.

---

## 📖 Article Series

| # | Article | Core Topic |
|---|---------|------------|
| 1 | [Swift Arrays: Hidden Performance Traps Most Developers Miss](https://medium.com/icommunity/swift-arrays-hidden-performance-traps-most-developers-miss-77b1a11fc0c9) | CoW, `reduce(into:)`, `contains(where:)`, `ArraySlice` |
| 2 | [Advanced Dictionaries: Performance and Hidden Traps](https://medium.com/icommunity/advanced-dictionaries-performance-and-hidden-traps-01921daaa164) | `mapValues`, frequency maps, stale indices, `Hashable` |
| 3 | [Swift's Performance Weapons: Set, OrderedSet, Range and RangeSet](https://medium.com/icommunity/swifts-performance-weapons-set-orderedset-range-and-rangeset-c0ce078411f0) | `Set`, custom `OrderedSet`, `RangeSet`, bulk removal |

---

## 🗂 Where Each Concept Lives in the Code

### Article 1 — Arrays

**`reduce(into:)` instead of `reduce()`**

The article shows that `reduce()` creates a full copy of the accumulator on every iteration (O(n²) for dictionary accumulation), while `reduce(into:)` mutates in place. `DuplicateService` builds its frequency map using the correct form:

```swift
// DuplicateService.swift
private func frequencyMap(for items: [VaultItem]) -> [String: Int] {
    items.reduce(into: [String: Int]()) { freq, item in
        let key = DuplicateService.normalized(item.title)
        freq[key, default: 0] += 1
    }
}
```

**`contains(where:)` instead of `filter().count > 0`**

The article explains that `.filter()` traverses the entire array and allocates a new one in memory, while `.contains(where:)` stops at the first match with O(1) extra memory. In `DuplicateService`, we check for duplicates without allocating intermediate arrays:

```swift
// DuplicateService.swift
func findDuplicates(in items: [VaultItem]) -> [String: Int] {
    frequencyMap(for: items)
        .filter { $0.value > 1 }
}
```

**Copy-on-Write (CoW) awareness**

`CollectionDetailViewModel` fetches all collections into a local `var` and mutates only that local copy before saving. This avoids triggering unnecessary CoW copies on the shared storage:

```swift
// CollectionDetailViewModel.swift
func addItem(title: String) {
    // allCollections is a local var — CoW copy happens here once,
    // not on every element access.
    allCollections[index].items.append(newItem)
    save()
}
```

---

### Article 2 — Dictionaries

**Frequency map for duplicate detection**

The article's "Counting Elements" section shows `Dictionary(pairs, uniquingKeysWith: +)`. We apply the same idea in `DuplicateService` using `reduce(into:)` with `default:` subscript, then pass the result to `CollectionDetailViewController` for cell-level duplicate badges:

```swift
// DuplicateService.swift
freq[key, default: 0] += 1
```

```swift
// CollectionDetailViewController.swift — cellForRowAt
let normalized = DuplicateService.normalized(item.title)
let isDuplicate = (viewModel.duplicates[normalized] ?? 0) > 1
```

**Key-based access only — never storing indices**

The article's "Invalid Index" section warns that dictionary indices become stale after any mutation. Throughout the app, all dictionary access uses string or UUID keys, never a stored `Dictionary.Index`:

```swift
// FavoritesStore.swift
func isFavorite(_ id: UUID) -> Bool {
    favorites.contains(id)   // key lookup, not index
}
```

**`mapValues` pattern awareness**

`CollectionDetailViewModel.refreshDuplicates()` re-computes the frequency map only when the collection changes (inside `save()` → `load()`), not on every read. This avoids the expensive "destroy + re-hash" pattern the article warns about.

---

### Article 3 — Set, OrderedSet, Range & RangeSet

**`Set<UUID>` for O(1) favorites lookup**

The article's core message: if order doesn't matter and you only need membership checks, `Set` beats `Array` by giving O(1) instead of O(n). `FavoritesStore` uses exactly this:

```swift
// FavoritesStore.swift
private(set) var favorites: Set<UUID> = []

func isFavorite(_ id: UUID) -> Bool {
    favorites.contains(id)   // O(1) — no matter how many favorites
}

func toggle(_ id: UUID) {
    if favorites.contains(id) {
        favorites.remove(id)
    } else {
        favorites.insert(id)
    }
}
```

With an `Array<UUID>`, checking 1000 favorites would scan all 1000 elements on every cell render. With `Set`, it's instant.

**Custom `OrderedSet` — dependency-free alternative**

The article presents two options: Apple's `swift-collections` package (SPM dependency) and a custom struct using `array + set` dual storage. CollectionVault uses the custom approach to stay dependency-free, exactly as described:

```swift
// OrderedSet.swift
struct OrderedSet<T: Hashable & Codable>: Codable {
    private var array: [T] = []
    private var set: Set<T> = []

    // O(1) lookup — delegates to Set
    func contains(_ value: T) -> Bool {
        set.contains(value)
    }

    // MRU insert: moves existing value to front in O(n),
    // or inserts new value in O(1).
    // Trade-off: O(n) reorder is acceptable for small collections
    // (search history, vault items). For large sets, prefer swift-collections.
    mutating func insert(_ value: T) {
        if set.contains(value) {
            if let idx = array.firstIndex(of: value) {
                array.remove(at: idx)
            }
        } else {
            set.insert(value)
        }
        array.insert(value, at: 0)
    }
}
```

`OrderedSet` is used in two places:
- `Collection.items` — vault items stay unique and maintain insertion order
- `globalSearchHistory` — search terms are unique and ordered by recency (MRU)

**Search History — the full `OrderedSet` flow in action**

This is the clearest end-to-end example of why `OrderedSet` was chosen over a plain `Array` or `Set` alone.

The problem: search history must be **unique** (no repeated terms) and **ordered by recency** (most recent at the top). An `Array` would allow duplicates. A `Set` would lose order. `OrderedSet` solves both.

```
User types "Swift" → taps Search  →  OrderedSet: ["Swift"]
User types "iOS"   → taps Search  →  OrderedSet: ["iOS", "Swift"]
User types "Swift" → taps Search  →  OrderedSet: ["Swift", "iOS"]
                                       ↑ duplicate moved to front, not added twice
```

The flow through the layers:

```swift
// 1. SearchViewController — user taps the Search keyboard button
func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text, !query.isEmpty else { return }
    viewModel.commitSearchHistory(query: query)
}

// 2. SearchViewModel — trims and delegates to repository
func commitSearchHistory(query: String) {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    repository.globalSearchHistory.insert(trimmed)  // OrderedSet.insert — MRU
    onUpdate?()
}

// 3. UserDefaultsCollectionRepository — cached write to disk
var globalSearchHistory: OrderedSet<String> {
    get {
        if let cached = cachedHistory { return cached }        // no decode if cache is warm
        // ... decode from UserDefaults, cache, return
    }
    set {
        cachedHistory = newValue                               // update cache
        UserDefaults.standard.set(encoded, forKey: historyKey) // persist
    }
}

// 4. SearchViewController — renders history in the table
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let query = viewModel.searchHistory.elements[indexPath.row]
    // .elements preserves insertion order → most recent is always index 0
    config.text = query
}
```

Tapping a history row re-runs the search **and** moves that term back to the top:

```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let query = viewModel.searchHistory.elements[indexPath.row]
    searchController.searchBar.text = query
    viewModel.filterResults(with: query)
    viewModel.commitSearchHistory(query: query)  // re-insert → moves to front
}
```

The cache matters here: `searchHistory` is read on every keystroke via `filterResults` → `onUpdate`. Without the in-memory `cachedHistory`, each keystroke would trigger a `JSONDecoder` call on the main thread.

**`RangeSet` for efficient bulk removal**

The article explains that `RangeSet` stores thousands of separate indices as a few integer ranges in memory, enabling O(1) bulk removal with `removeSubranges`. `OrderedSet.remove(_:)` uses this directly:

```swift
// OrderedSet.swift
mutating func remove(_ indexSet: IndexSet) {
    // 1. Convert IndexSet → RangeSet using rangeView.
    //    rangeView gives contiguous ranges (e.g. {2..<5, 8..<9}) instead of
    //    individual integers, so RangeSet can store them compactly.
    var rangeSet = RangeSet<Int>()
    for range in indexSet.rangeView {
        rangeSet.insert(contentsOf: range)
    }

    // 2. Remove from Set *before* mutating the array, while indices are still valid.
    for index in indexSet where array.indices.contains(index) {
        set.remove(array[index])
    }

    // 3. Remove from array in one O(n) sweep.
    //    A naive loop with array.remove(at:) would shift elements on every
    //    deletion — O(n²) for multiple items. removeSubranges avoids that.
    array.removeSubranges(rangeSet)
}
```

This is called from `CollectionDetailViewModel.deleteItems(at:)` whenever the user swipes to delete one or more vault items.

---

## ✍️ Author

**Okan Orkun** — [Medium](https://medium.com/@orkunokann) · [iCommunity](https://medium.com/icommunity)
