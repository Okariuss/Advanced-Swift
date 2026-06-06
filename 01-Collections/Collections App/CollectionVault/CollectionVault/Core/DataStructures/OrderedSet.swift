//
//  OrderedSet.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import Foundation

struct OrderedSet<T: Hashable & Codable>: Equatable, Codable {
    
    private var array: [T] = []
    private var set: Set<T> = []
    
    init() {}
    
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
    
    @discardableResult
    mutating func append(_ value: T) -> Bool {
        let result = set.insert(value)
        if result.inserted {
            array.append(value)
        }
        return result.inserted
    }
    
    mutating func remove(_ indexSet: IndexSet) {
        var rangeSet = RangeSet<Int>()
        for range in indexSet.rangeView {
            rangeSet.insert(contentsOf: range)
        }
        
        for index in indexSet where array.indices.contains(index) {
            set.remove(array[index])
        }
        array.removeSubranges(rangeSet)
    }
    
    mutating func removeAll() {
        array.removeAll()
        set.removeAll()
    }
    
    mutating func update(_ value: T) {
        guard contains(value) else { return }
        if let idx = array.firstIndex(of: value) {
            array[idx] = value
        }
        set.update(with: value)
    }
    
    func contains(_ value: T) -> Bool {
        set.contains(value)
    }
    
    var elements: [T] { array }
    var count: Int { array.count }
    var isEmpty: Bool { array.isEmpty }
}

extension OrderedSet: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: T...) {
        elements.forEach { append($0) }
    }
}
