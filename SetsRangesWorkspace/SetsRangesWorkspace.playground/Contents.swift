import Foundation

/*
 NOTE: To run the OrderedSet section, you need to add the 'swift-collections' package
 to your Playground dependencies.
 GitHub: https://github.com/apple/swift-collections
*/
// For the sake of compiling without errors if the package is missing initially:
#if canImport(OrderedCollections)
import OrderedCollections
#endif

print("--- Swift Hidden Power Playground --- \n")

// MARK: - 1. Set Basics & Operations

print("// MARK: 1. Set Basics & Operations")

// Initialization and automatic duplicate removal
let numbers: Set = [1, 2, 3, 2, 1, 4]
print("Unique Set: \(numbers)") // Output: [1, 2, 3, 4] (unordered)

// Fast O(1) Membership Check
let blockedUsers: Set<String> = ["user_123", "user_456", "user_789"]
let currentUserID = "user_123"

if blockedUsers.contains(currentUserID) {
    print("Access Denied: User is blocked. (Checked in O(1) time)")
}

// Non-Mutating Form (Returns a NEW Set)
let activeUsers: Set = ["Okan", "Arda", "Deniz"]
let premiumUsers: Set = ["Deniz", "Can"]

let premiumActiveUsers = activeUsers.intersection(premiumUsers)
print("Premium Active Users (New Set): \(premiumActiveUsers)")
print("Original activeUsers remained unchanged: \(activeUsers)\n")

// Mutating Form (Modifies the original set directly - Memory Efficient)
var disconnectedDevices: Set = ["iBook", "PowerMac"]
let discontinuedIPods: Set = ["iPod mini", "iPod classic"]

disconnectedDevices.formUnion(discontinuedIPods)
print("Disconnected Devices after formUnion: \(disconnectedDevices)\n")


// MARK: - 2. OrderedSet (Requires swift-collections)

print("// MARK: 2. OrderedSet")

#if canImport(OrderedCollections)
var searchHistory = OrderedSet<String>()
searchHistory.append("Swift Architecture")
searchHistory.append("Clean Code")
searchHistory.append("Swift Architecture") // Duplicate! Will be ignored.

print("Search History (Order preserved, no duplicates): \(searchHistory)")
print("Fast lookup check: \(searchHistory.contains("Clean Code"))\n")
#else
print("OrderedSet Example: Please add the 'swift-collections' package dependency to run this section.\n")
#endif


// MARK: - 3. Range & RangeExpression

print("// MARK: 3. Range & RangeExpression")

let scores = [10, 20, 30, 40, 50]

// Using different RangeExpressions to slice a collection
let halfOpenRangeSlice = scores[1..<3]  // Range: Includes index 1 and 2
let closedRangeSlice = scores[1...3]    // ClosedRange: Includes index 1, 2, and 3
let partialFromSlice = scores[2...]     // PartialRangeFrom: Index 2 to the end
let partialUpToSlice = scores[..<2]     // PartialRangeUpTo: From start up to index 2 (exclusive)

print("Partial From Slice (2...): \(partialFromSlice)") // [30, 40, 50]

// CRITICAL: The Index Sharing Trap
let array = [10, 20, 30, 40, 50]
let slice = array[2...4] // [30, 40, 50]

print("Slice startIndex is: \(slice.startIndex)") // Output: 2 (NOT 0!)

// Safe way to access the first element of a slice
if let firstElement = slice.first {
    print("Safe access using .first: \(firstElement)")
    print("Safe access using startIndex: \(slice[slice.startIndex])")
}

// UNCOMMENTING THE LINE BELOW WILL CAUSE A CRASH:
// print(slice[0]) // Fatal error: Index out of bounds
print("\n")


// MARK: - 4. RangeSet & Batch Operations

print("// MARK: 4. RangeSet & Batch Operations")

// RangeSet automatically detects and merges contiguous ranges
var selectedIndices = RangeSet<Int>()
selectedIndices.insert(contentsOf: 1..<5)
selectedIndices.insert(contentsOf: 5..<10)

print("Merged Ranges in RangeSet: \(selectedIndices.ranges)") // Output: [1..<10]

// Real-World Scenario: Batch Deleting Elements in O(n) Time
var employees = ["Ahmet", "Mehmet", "Can", "Ece", "Ali", "Veli"]
print("Original Employees: \(employees)")

// Collect indices of names starting with "A" using a predicate closure
let indicesToDelete = employees.indices { $0.hasPrefix("A") } // Returns RangeSet<Int>

// Remove all selected elements at once efficiently
employees.removeSubranges(indicesToDelete)
print("Employees after efficient batch delete: \(employees)")
// Output: ["Mehmet", "Can", "Ece", "Veli"]
