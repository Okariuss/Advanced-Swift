//: # Advanced Arrays in Swift
//: **Learn how Arrays really work in Swift**
//: Based on objc.io "Advanced Swift" + practical iOS usage

import Foundation

// MARK: - 1. let vs var & Value Semantics

print("===========================================")
print("1. let vs var & Value Semantics")
print("===========================================")

// `let` means the array cannot change
let fibs = [0, 1, 1, 2, 3, 5]

// fibs.append(8)  ❌ Not allowed (compile error)
// This is good because it makes code safer

// `var` means the array can change
var mutableFibs = [0, 1, 1, 2, 3, 5]
mutableFibs.append(8)
mutableFibs.append(contentsOf: [13, 21])

print("mutableFibs:", mutableFibs)

// Swift arrays use VALUE SEMANTICS
// This means: when you assign an array, it is copied logically (not immediately in memory)

var x = [1, 2, 3]
var y = x   // No real copy happens here (Copy-on-Write)

y.append(4) // Now Swift creates a real copy only for y

print("x:", x)  // [1, 2, 3]
print("y:", y)  // [1, 2, 3, 4]

// WHY THIS MATTERS:
// This makes arrays fast and memory efficient in most cases


// MARK: - 2. Safe Array Operations

print("\n===========================================")
print("2. Safe Array Operations")
print("===========================================")

let numbers = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]

// Prefer working with safe high-level methods instead of manual indexing

for num in numbers {
    // simple iteration (safe and clean)
}

for num in numbers.dropFirst() {
    // skip first element safely
}

for num in numbers.dropLast(3) {
    // skip last 3 elements safely
}

for (index, element) in numbers.enumerated() {
    // gives both index and value safely
}

if let idx = numbers.firstIndex(where: { $0 > 50 }) {
    print("First number > 50 is at index:", idx)
}

// WHY THIS MATTERS:
// Manual index math can easily cause crashes


// MARK: - 3. map() and Custom map

print("\n===========================================")
print("3. map() - Transform Arrays")
print("===========================================")

// map transforms each element into a new value

let squares = fibs.map { $0 * $0 }
print("Squares:", squares)

// Custom map (for learning how it works internally)
extension Array {
    func myMap<T>(_ transform: (Element) -> T) -> [T] {
        var result: [T] = []

        // Performance improvement:
        // We pre-allocate memory to avoid repeated resizing
        result.reserveCapacity(count)

        for item in self {
            result.append(transform(item))
        }

        return result
    }
}

let mySquares = fibs.myMap { $0 * $0 }
print("myMap result:", mySquares)

// WHY THIS MATTERS:
// map is not magic - it's just a loop with transformations


// MARK: - 4. filter vs contains(where:)

print("\n===========================================")
print("4. filter() vs contains(where:)")
print("===========================================")

let largeArray = Array(1...100_000)

// ❌ BAD: This creates a new array in memory
let hasBigNumberSlow = largeArray.filter { $0 > 99999 }.count > 0

// It checks ALL elements and allocates memory

// ✅ GOOD: stops early when it finds a match
let hasBigNumberFast = largeArray.contains(where: { $0 > 99999 })

print("Result:", hasBigNumberFast)

// Lazy chains (use only when needed)
let processed = (1..<10)
    .lazy
    .map { $0 * 2 }
    .filter { $0 % 3 == 0 }

print("Lazy result:", Array(processed))

// WHY THIS MATTERS:
// Small differences become big when data is large


// MARK: - 5. reduce vs reduce(into:)

print("\n===========================================")
print("5. reduce vs reduce(into:)")
print("===========================================")

let words = ["Swift", "iOS", "SwiftUI", "UIKit", "Swift", "Xcode"]

// ❌ BAD: creates a new dictionary every step
let slowCount = words.reduce([String: Int]()) { current, word in
    var copy = current
    copy[word, default: 0] += 1
    return copy
}

// Each iteration creates a new copy → slow for big data

// ✅ GOOD: modifies same dictionary
let fastCount = words.reduce(into: [String: Int]()) { result, word in
    result[word, default: 0] += 1
}

print("Word counts:", fastCount)

// WHY THIS MATTERS:
// reduce(into:) avoids unnecessary copying


// MARK: - 6. flatMap

print("\n===========================================")
print("6. flatMap")
print("===========================================")

let suits = ["♠", "♥", "♣", "♦"]
let ranks = ["J", "Q", "K", "A"]

// Creates combinations of suits and ranks
let allCards = suits.flatMap { suit in
    ranks.map { rank in (suit, rank) }
}

print("Total cards:", allCards.count)

// WHY THIS MATTERS:
// flatMap helps flatten nested arrays


// MARK: - 7. ArraySlice - Important Concept

print("\n===========================================")
print("7. ArraySlice")
print("===========================================")

let slice = fibs[2...]

print("Slice as Array:", Array(slice))
print("Slice type:", type(of: slice))
print("Slice startIndex:", slice.startIndex)

// ⚠️ IMPORTANT:
// ArraySlice does NOT start from index 0

// slice[0] ❌ can crash

// Safe ways:
print("First element:", slice.first ?? -1)
print("Using startIndex:", slice[slice.startIndex])

// You can convert it back to normal array
let converted = Array(slice)
print("Converted:", converted)

// WHY THIS MATTERS:
// Slice is a "view", not a new array


// MARK: - 8. forEach vs for loop

print("\n===========================================")
print("8. forEach vs for loop")
print("===========================================")

// forEach is simple but has limitations

(1..<10).forEach { number in
    print(number)

    if number > 5 {
        // This does NOT break the loop
        return
    }
}

// Better: use normal for loop when logic is complex
for number in 1..<10 {
    print(number)

    if number > 5 {
        break // works correctly
    }
}

// WHY THIS MATTERS:
// for loops give more control


// MARK: - SUMMARY

print("\n===========================================")
print("SUMMARY")
print("===========================================")

print("""
- Use let when possible (safer code)
- Arrays use Copy-on-Write (efficient memory usage)
- Prefer contains(where:) instead of filter().count > 0
- reduce(into:) is better for performance
- ArraySlice is NOT a normal array
- Use lazy for large chains when needed
- map, filter, reduce are just optimized loops
- Always think about memory + performance in real apps
""")
