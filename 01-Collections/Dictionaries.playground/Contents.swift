import Foundation

/*:
 # Advanced Dictionaries: Cheat Sheet
 Dictionaries are simple and useful. They give us fast O(1) lookup time.
 But they have some hidden rules inside.
 If you don't learn these rules, you will see slow code or strange bugs.

 Let's look at the most common mistakes and fix them!
 */


// ==========================================
// MARK: - 1. LOOKUPS ALWAYS RETURN OPTIONAL
// ==========================================
/*:
 ### 1. Why Do Lookups Always Return an Optional?

 **Arrays are closed:** An array knows exactly how many items it has.
 If you ask for `array[4]` but the array only has 2 items, your code has a bug.
 Swift crashes your app on purpose to warn you.

 **Dictionaries are open:** Keys usually come from outside your app.
 For example: a user types something, or your app gets data from an API.
 A missing key is not a bug — it is normal.
 So Swift returns `nil` instead of crashing.
 */

let array = ["Apple", "Banana"]
// let crashMe = array[4] // CRASH: index out of range

let settings: [String: String] = ["Theme": "Dark", "Font": "Helvetica"]
let missingValue = settings["Sound"] // Safe: returns nil, no crash

if let theme = settings["Theme"] {
    print("Theme is \(theme)")
}

// You can also give a default value when a key is missing
let fontSize = settings["FontSize", default: "16"]
print("Font size:", fontSize)


// ==========================================
// MARK: - 2. THE HASHABLE RULE
// ==========================================
/*:
 ### 2. Why Must Keys Be Hashable?

 A dictionary is a **hash table** — a hidden array of memory slots called *buckets*.
 When you write `dict[key] = value`, Swift does not search one by one.
 It sends your key to a *hash function*, gets a number, and goes directly to the right slot.
 This is why lookups are O(1) — fast!

 **The rule:** If `a == b`, then `a.hashValue` must equal `b.hashValue`.
 If this rule breaks, Swift saves an item in one slot but looks for it in a different slot.
 You can never find that item again.
 */

// Structs are safe — Swift writes Hashable for you automatically
struct UserID: Hashable {
    let name: String
    let number: Int
}

var profiles: [UserID: String] = [:]
let id = UserID(name: "alice", number: 42)
profiles[id] = "Alice in Wonderland"

let sameID = UserID(name: "alice", number: 42)
print("Found:", profiles[sameID] ?? "not found") // Works correctly


// ==========================================
// MARK: - 3. THE MAPVALUES TRICK
// ==========================================
/*:
 ### 3. Performance: Use mapValues, Not map

 Imagine you want to change all values in a dictionary into Strings.
 The bad way destroys the old dictionary, makes a temporary array, and builds a new dictionary.
 Swift has to calculate a new hash for every key. This wastes CPU time.

 The good way uses `mapValues`. Swift keeps the same keys and the same memory structure.
 No new hashing happens. It is faster and cleaner.
 */

enum Setting {
    case text(String)
    case int(Int)
    case bool(Bool)
}

let userSettings: [String: Setting] = [
    "Airplane Mode": .bool(false),
    "Name": .text("Okan's iPhone")
]

// Bad: destroy → temp array → rebuild → rehash every key
let badTransform = Dictionary(
    uniqueKeysWithValues: userSettings.map { ($0.key, String(describing: $0.value)) }
)

// Good: same keys, same slots, zero rehashing
let optimizedDict = userSettings.mapValues { String(describing: $0) }
print(optimizedDict)


// ==========================================
// MARK: - 4. COMBINING & COUNTING
// ==========================================
/*:
 ### 4. Combining Dictionaries and Counting Items

 When you combine two dictionaries, some keys may exist in both.
 You must write a small rule to decide which value wins.
 */

// A. Merge — choose which value wins when keys overlap
var mergedSettings = userSettings
let newSettings: [String: Setting] = ["Name": .text("Jane's iPhone")]

// Use the incoming value — it overwrites the old one
mergedSettings.merge(newSettings) { _, incoming in incoming }

// B. Count how many times each item appears
extension Sequence where Element: Hashable {
    var frequencies: [Element: Int] {
        let pairs = self.map { ($0, 1) }
        return Dictionary(pairs, uniquingKeysWith: +) // adds 1 each time it sees the same key
    }
}

let counts = "hello".frequencies
print(counts) // ["h": 1, "e": 1, "l": 2, "o": 1]


// ==========================================
// MARK: - 5. DICTIONARY INDEX DANGER
// ==========================================
/*:
 ### 5. Key Lookups vs. Dictionary Index — A Dangerous Trap

 `Dictionary.Index` is not like an array index.
 When you add or remove items, Swift changes the dictionary's internal structure.
 It also changes a hidden counter called `_age`.

 If you saved an old index before the change, that index is now *stale* — it points to the wrong place.
 Using a stale index causes a **fatal crash at runtime**. The compiler does not warn you!
 */

class SettingsManager {
    var userSettings: [String: String] = ["Theme": "Dark", "Font": "Helvetica"]

    func getThemeIndex() -> Dictionary<String, String>.Index? {
        return userSettings.index(forKey: "Theme")
    }

    func removeFontSetting() {
        userSettings.removeValue(forKey: "Font") // internal structure changes here
    }
}

let manager = SettingsManager()

if let themeIndex = manager.getThemeIndex() {
    manager.removeFontSetting() // _age changes — index is now stale

    // CRASH AT RUNTIME — the compiler does not catch this:
    // print(manager.userSettings[themeIndex])
}

/*:
 **How to stay safe:**
 - Always use keys: `settings["Theme"]` — this always returns nil if the key is missing.
 - If you must use an index, use it immediately. Never mutate the dictionary between getting and using an index.
 - Never store or pass a dictionary index to another function or async task.
 */


// ==========================================
// MARK: - 6. MUTABLE CLASS KEY DISASTER
// ==========================================
/*:
 ### 6. Never Use a Mutable Class as a Dictionary Key

 Swift makes `struct` and `enum` types safe automatically.
 But if you use a `class` as a key and then change its properties, you break the hashing rule.
 The item gets lost inside the dictionary and you can never delete it.
 This is a **permanent memory leak**.
 */

class CustomToken: Hashable {
    var id: String
    init(id: String) { self.id = id }

    static func == (lhs: CustomToken, rhs: CustomToken) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

var cache = [CustomToken: String]()
let token = CustomToken(id: "auth_123")
cache[token] = "Session_Data_Here" // saved in the slot for "auth_123"

token.id = "auth_999" // hash changes — the rule is now broken

print(cache[token] as Any) // nil — looks in "auth_999" slot, finds nothing
print("Items in cache:", cache.count) // 1 — data is trapped in "auth_123" slot forever

/*:
 **What happened?**
 The object is still equal to itself (`token == token`).
 But because `id` changed, the hash is now different.
 Swift looks in a new slot and finds nothing.
 The old data is stuck and can never be found or removed.

 **Simple rule:** Use `struct` or `enum` for dictionary keys.
 If you must use a `class`, make the properties used in `==` and `hash` constants (`let`).
 */

// The safe version — a struct with 'let' properties
struct SafeToken: Hashable {
    let id: String // 'let' means it can never change — the rule always holds
}

var safeCache = [SafeToken: String]()
let safeToken = SafeToken(id: "auth_123")
safeCache[safeToken] = "Session_Data_Here"
print(safeCache[safeToken] ?? "not found") // always works correctly


// ==========================================
// MARK: - 7. RANDOMIZED HASH SEEDING
// ==========================================
/*:
 ### 7. Why Does the Loop Order Change Every Time?

 When you loop over a dictionary, the order is different every time you run your app.
 This is not a bug. It is a **security feature** called *Randomized Hash Seeding*.

 **The problem without it:**
 If the hash function always worked the same way, an attacker could study your app.
 They could create thousands of keys that all produce the same hash number.
 This fills the same bucket and forces Swift to search one by one — O(n) instead of O(1).
 Your CPU gets stuck and your app freezes. This is called a *Hash-Flooding Attack (DoS)*.

 **The fix:**
 Swift adds a random number (a *seed*) to the hash function every time your app starts.
 The same key produces a different hash number each run.
 An attacker cannot predict where keys land in memory, so the attack does not work.

 **Testing tip:** If your unit tests fail because they need the same order every time,
 add this to your Xcode Scheme → Environment Variables:
 `SWIFT_DETERMINISTIC_HASHING = 1`
 Never use this in a real app. It removes the protection.
 */

let palette: [String: String] = [
    "primary":   "#007AFF",
    "secondary": "#5856D6",
    "success":   "#34C759",
    "warning":   "#FF9500",
    "danger":    "#FF3B30"
]

print("--- Loop order (changes every launch) ---")
for (name, hex) in palette {
    print("  \(name): \(hex)")
}
