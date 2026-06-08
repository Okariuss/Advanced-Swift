//: # Swift Optionals — Quick Review Playground
//: **Based on:** Advanced Swift by Chris Eidhof, Ole Begemann & Florian Kugler
//: **Swift Version:** 6.3.2
//:
//: Run each section top-to-bottom. Every example prints its output so you
//: can see exactly what's happening without opening the sidebar.

import Foundation

// =============================================================================
// MARK: - 1. WHY OPTIONALS EXIST — The Sentinel Value Problem
// =============================================================================
//
// Before Swift, "no value" was represented by magic values:
//   C       -> -1 for EOF
//   Java    -> null (causes NullPointerException)
//   ObjC    -> nil (silently does nothing, causes hard-to-find bugs)
//
// The problem: the magic value LOOKS like a real value. Nothing stops you
// from accidentally using it as one.
//
// Swift's fix: encode "no value" directly into the TYPE SYSTEM.

enum MyOptional<Wrapped> {  // This is literally how Optional is defined.
    case none               // nil
    case some(Wrapped)      // a real value
}

// Int? and Int are DIFFERENT types. The compiler stops you before you misuse one.
let maybeAge: Int? = nil
let definiteAge: Int = 26

// Uncommenting the line below would cause a COMPILE ERROR — intentional safety:
//let sum = maybeAge + definiteAge

print("--- 1. Sentinel Values ---")
print("maybeAge:", maybeAge as Any)     // Optional(nil)
print("definiteAge:", definiteAge)      // 30

// =============================================================================
// MARK: - 2. UNWRAPPING — if let / guard let / while let
// =============================================================================
 
print("\n--- 2a. if let ---")

var fruits = ["apple", "banana", "cherry"]

// Classic form (pre-Swift 5.7):
if let idx = fruits.firstIndex(of: "banana") {
    print("Found banana at index: ", idx)
}

// Chain multiple bindings — later ones can depend on earlier ones:
let urlString = "https://swift.org"
if let url = URL(string: urlString),
   let host = url.host {
    print("Host: ", host)
}

// ── Swift 5.7 Shorthand ──────────────────────────────────────────
//
// BEFORE Swift 5.7 — you had to repeat the variable name:
//   if let username = username { ... }
//   if let productListResponse = productListResponse { ... }
//
// AFTER Swift 5.7 — omit the right-hand side when shadowing:

var username: String? = "Okan"

// Old way
if let username = username {
    print("Old way: ", username.uppercased())
}

// New way (Swift 5.7+)
if let username {
    print("New way: ", username.uppercased())
}

// Works with guard let and while let too:
func greet(name: String?) {
    guard let name else { return }
    print("Hello, ", name)
}

greet(name: "Okan")
greet(name: nil)    // No prints

// ⚠️  Limitation: shorthand does NOT work for property access:
//if let username.count { }  ← This won't compile

// ── guard let ──────────────────────────────────────────────────────────────
 
print("\n--- 2b. guard let ---")

func processUser(id: String?) -> String {
    guard let id else { return "No ID provided" }
    // 'id' is a plain String from here on — no unwrapping needed
    return "Processing user: \(id.uppercased())"
}

print(processUser(id: "u_42"))
print(processUser(id: nil))

// ── while let ──────────────────────────────────────────────────────────────
 
print("\n--- 2c. while let ---")
 
// while let stops the moment the condition returns nil.
// This is exactly how for...in works under the hood.

let numbers = [10, 20, 30]
var iterator = numbers.makeIterator()
while let n = iterator.next() {
    print(" item", n)
}

// ⚠️  Boolean clause in while let TERMINATES the loop (not just skips):
var counter = 0
let values = [1, 2, 3, 4, 5]
var valIter = values.makeIterator()
while let v = valIter.next(), v < 3 {
    counter += v
}
print("Sum of values < 3 (loop stopped at 3): ", counter)

// =============================================================================
// MARK: - 3. OPTIONAL CHAINING
// =============================================================================
 
print("\n--- 3. Optional Chaining ---")

// ?.  → if nil at any point, the whole expression returns nil silently.

let str: String? = "never say never"
let upper = str?.uppercased()           // Optional("never say never")
print("upper: ", upper as Any)

// Chaining flattens automatically - no String?? here:
let lower = str?.uppercased().lowercased()
print("lower: ", lower as Any)

// When a METHOD itself returns an optional, add ? at each step:
extension Int {
    var half: Int? {
        guard self > 1 || self < -1 else { return nil }
        return self / 2
    }
}

print("20.half?.half?.half: ", 20.half?.half?.half as Any)

// Chaining works on ASSIGNMENTS too:
struct Person {
    var name: String
    var age: Int
}

var optionalLisa: Person? = Person(name: "Lisa", age: 8)

// ❌ Verbose old way:
if optionalLisa != nil {
    optionalLisa!.age += 1
}

// ✅ Optional chaining:
optionalLisa?.age += 1
print("Lisa's age:", optionalLisa?.age as Any)  // Optional(10)

// Subtle difference:
var a: Int? = 5
a? = 10                 // Assigns only because a is non-nil
print("a after a? = 10: ", a as Any)

var b: Int? = nil
b? = 5                  // Does nothing because b is nil
print("b after b? = 5: ", b as Any)

// =============================================================================
// MARK: - 4. NIL-COALESCING (??)
// =============================================================================
 
print("\n--- 4. Nil-Coalescing (??) ---")

// lhs ?? rhs  ->  lhs if non-nil, otherwise rhs
let number = Int("abc") ?? 0
print("Int(\"abc\") ?? 0: ", number)            // 0

let first = [Int]().first ?? -1
print("[].first ?? -1: ", first)                // -1

// Chain ?? for multiple fallbacks — first non-nil wins:
let i: Int? = nil
let j: Int? = nil
let k: Int? = 42

print("i ?? j ?? k ?? 0: ", i ?? j ?? k ?? 0)   // 42

// ?? uses SHORT-CIRCUIT evaluation:
// The right-hand side is NOT evaluated when left is non-nil.
func expensiveDefault() -> Int {
    print("  (expensive default called)")
    return 99
}
let fast: Int? = 7
let result = fast ?? expensiveDefault()         // expensiveDefault() never runs
print("fast ?? expensive:", result)             // 7

// =============================================================================
// MARK: - 5. MAP & FLATMAP ON OPTIONALS
// =============================================================================
 
print("\n--- 5a. map ---")

// Think of Optional as a collection of 0 or 1 values.
// map transforms the value if it exists: does nothing if nil

let chars: [Character] = ["a", "b", "c"]
let firstChar = chars.first.map { String($0) }
print("chars.first.map { String($0) }: ", firstChar as Any)             // Optional("a")

let emptyChars: [Character] = []
let noChar = emptyChars.first.map { String($0) }
print("emptyChars.first.map { String($0) }: ", noChar as Any)           // nil

// Equivalent if let pattern:
var firstCharAlt: String? = nil
if let c = chars.first {
    firstCharAlt = String(c)
}
print("Same result via if let: ", firstCharAlt as Any)                  // Optional("a")

print("\n--- 5b. flatMap ---")
 
// When your transform ALSO returns an optional, map gives you Optional(Optional(x)).
// flatMap flattens this into a single Optional.

let stringNumbers = ["1", "2", "3", "foo"]

let nested = stringNumbers.first.map { Int($0) }
let flat = stringNumbers.first.flatMap { Int($0) }

print("map result type (Int??): ", nested as Any)                       // Optional(Optional(1))
print("flatMap result type (Int?): ", flat as Any)                      // Optional(1)

// flatMap is equivalent to chained if let:
if let s = stringNumbers.first, let n = Int(s) {
    print("Chained if let: ", n)                                        // 1
}

// =============================================================================
// MARK: - 6. COMPACTMAP — Filter Nils From a Sequence
// =============================================================================
 
print("\n--- 6. compactMap ---")

// compactMap = map + remove nils + unwrap -> all in one pass.

let mixed = ["1", "two", "3", "four", "5"]

// map gives you [Int?]
let withNils = mixed.map { Int($0) }
print("map: ", withNils)

// compactMap gives you [Int], nils dropped
let clean = mixed.compactMap { Int($0) }
print("compactMap: ", clean)

let sum = clean.reduce(0, +)
print("Sum: ", sum)

// Loop only over non-nil values using case pattern matching
let maybeInts: [Int?] = [1, nil, 2, nil, 3]
print("non-nil via for case let i?:")
for case let i? in maybeInts {
    print(" ", i)
}

// =============================================================================
// MARK: - 7. STRING INTERPOLATION WITH OPTIONALS
// =============================================================================
 
print("\n--- 7. String Interpolation ---")

let bodyTemperature: Double? = 37.0
let bloodGlucose: Double? = nil
let count: Int? = nil

// ── Before Swift 6.2 — custom ??? operator ──────────────────────────────────
infix operator ???: NilCoalescingPrecedence

func ???<T>(optional: T?, defaultValue: @autoclosure () -> String) -> String {
    switch optional {
    case let value?: return String(describing: value)
    case nil: return defaultValue()
    }
}

print("Old way (custom operator):")
print("     Body temp: ", "\(bodyTemperature ??? "n/a")")           // 37.0
print("     Glucose: ", "\(bloodGlucose ??? "n/a")")                // n/a
print("     Count: ", "\(count ??? "unknown")")                     // unknown

// ── Swift 6.2+ — native default: parameter ────────────────────────────────

print("New way (Swift 6.2+)")
print("     Body temp: ", "\(bodyTemperature, default: "n/a")")           // 37.0
print("     Glucose: ", "\(bloodGlucose, default: "n/a")")                // n/a
print("     Count: ", "\(count, default: "unknown")")                     // unknown

// ── Why default: is MORE POWERFUL than ?? ────────────────────────────────────
//
// ?? requires both sides to be the SAME TYPE
// This fails to compile:
//  print("Count: \(count ?? "unknown")")
//   ERROR: Cannot convert value of type 'String' to expected argument type 'Int'
//
// defaults: accepts ANY String, regardless of the optional's type:
let score: Double? = nil
print(" Score:      ", "\(score, default: "not recorded")")             // not recorded

// When to use which??
// ??           -> logic fallback (same type, goes into further computation)
// default      -> display fallback (always String, user-facing output only )

// =============================================================================
// MARK: - 8. FORCE-UNWRAP (!) — When It's the Right Tool
// =============================================================================
 
print("\n--- 8. Force-Unwrap ---")

// RULE: Use ! only when you are so certain the value is non-nil
// that you WANT the program to crash if it ever is.

// Usage: dictionary keys come from the dictionary itself
let ages = ["Tim": 53, "Angela": 54, "Chris": 37, "John": 39]
let under50 = ages.keys.filter { ages[$0]! < 50 }.sorted()
print("under 50: ", under50)

// Better alternative without ! -> Iterate key-value pairs directly
let under50Alt = ages.filter { $0.value < 50 }.map { $0.key }.sorted()
print("under 50 alternative: ", under50Alt)

// ── Custom !! operator: crash with a useful message ──────────────────────────

infix operator !!

func !!<T>(wrapped: T?, failureText: @autoclosure () -> String) -> T {
    if let x = wrapped { return x }
    fatalError(failureText())
}

let s = "42"
let parsed = Int(s) !! "Expected Int, got \"\(s)\""
print("parsed: ", parsed)

// If s were "abc", this would be crash with:
// Fatal error: Expecting Int, got "abc"

// =============================================================================
// MARK: - 9. IMPLICITLY UNWRAPPED OPTIONALS (!)
// =============================================================================
 
print("\n--- 9. Implicitly Unwrapped Optionals ---")

// String! is still optional. It just auto-force-unwrap on every use.
//
// Two reasons this exists:
//      1. Objective-C interop -> old objc APIs return IUOs by default
//      2. Two-phase init -> IBOutlets are nil briefly, then never nil again

var greeting: String! = "Hello"

// All safe techniques still work on IUOs:
greeting?.isEmpty                           // Optional(false) - chaining works
let g = greeting ?? "Goodbye"               // "Hello" - coalescing works
if let greeting { print("if-let works") }

greeting = nil
print("After nil, greeting ?? Goodbye: ", greeting ?? "Goodbye")

// ⚠️  Pro-Tip:
// Never expose IUOs in a pure Swift API.
// In Objective-C bridged code → expected and fine.
// In native Swift return types → RED FLAG, treat as a bug.

// T! is not a non-optional type. It is an Optional that automatically force-unwraps when used. Think of it as T? with a hidden ! added by the compiler.

// =============================================================================
// MARK: - 10. DOUBLY NESTED OPTIONALS (Int??)
// =============================================================================
 
print("\n--- 10. Doubly Nested Optionals ---")

// An optional can wrap ANOTHER optional. This isn't a compiler quirk. It's intentional and necessary

let stringNums = ["1", "2", "three"]
let maybeInts2 = stringNums.map { Int($0) }                 // [Int?]
// -> [Optional(1), Optional(2), nil]

// When for...in iterates [Int?], each element is Int?
// Under the hood, next() returns Int?? (Element wrapped in another Optional)
for maybeInt in maybeInts2 {
    print("     element: ", maybeInt as Any)
}
// three -> nil (inner nil), but next() returned .some(nil) - loop didn't stop

// Loop only non-nil values
print("Non-nil only:")
for case let i? in maybeInts2 {
    print("     : ", i)         // 1, 2
}

// Loop only nil values
print("nil only")
for case nil in maybeInts2 {
    print("found a nil")        // once, for "three"
}

// =============================================================================
// MARK: - 11. EQUATING OPTIONALS
// =============================================================================
 
print("\n--- 11. Equating Optionals ---")

// Optionals conforms to Equatable when its Wrapped type does.
// nil == nil -> true
// nil == .some(_) -> false
// .some(x) == .some(y) -> x == y

let regex = "^Hello$"

// No need for isEmpty check or extra unwrapping:
if regex.first == "^" {
    print("Starts with caret")
}

// Swift promotes non-optional to optional automatically for comparisons:
// regex.first == "^"                   compiles as
// regex.first == Optional("^")         under the hood

// ── Comparison operators (<, >) were REMOVED for optionals in Swift 3 ────────
//
// Why nil < .some(_) was always true, which caused silent bugs:
//
// let temps = ["-459.67", "98.6", "0", "warm"]
// let belowFreezing = temps.filter { Double($0) < 0 }
// // "warm" -> Double("warm") = nil -> nil < 0 = true -> BUG: included
//
// Now you must unwrap first and explicitly decide how nil is handled.

print("Optional equality: nil == nil -> ", (nil as Int?) == (nil as Int?))
print("Optional equality: nil == 5 -> ", (nil as Int?) == Optional(5))
print("Optional equality: 5 == 5 -> ", Optional(5) == Optional(5))

// =============================================================================
// MARK: - QUICK REFERENCE CHEATSHEET
// =============================================================================
 
/*
 ┌─────────────────────────────────────────────────────────────────────┐
 │  TECHNIQUE       │  USE WHEN                    │  RETURNS           │
 ├─────────────────────────────────────────────────────────────────────┤
 │  if let          │  Value needed in local block  │  Non-opt in scope  │
 │  if let x (5.7)  │  Shadowing same-name variable │  Non-opt in scope  │
 │  guard let       │  Early exit on nil            │  Non-opt rest fn   │
 │  while let       │  Loop terminates on nil       │  Non-opt per iter  │
 │  ?.              │  Chain calls on optional      │  Optional          │
 │  ??              │  Same-type fallback for logic │  Non-optional      │
 │  default: (6.2)  │  String fallback for display  │  String            │
 │  map             │  Transform without unwrapping │  Optional          │
 │  flatMap         │  Transform → optional result  │  Optional          │
 │  compactMap      │  Filter nils from sequence    │  [Non-optional]    │
 │  !               │  Certain non-nil, crash ok    │  Non-opt or CRASH  │
 └─────────────────────────────────────────────────────────────────────┘
*/
