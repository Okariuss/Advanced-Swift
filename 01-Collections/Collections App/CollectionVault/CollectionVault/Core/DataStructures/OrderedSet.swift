//
//  OrderedSet.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import Foundation

struct OrderedSet<T: Hashable & Codable>: Codable {
    
    private var array: [T] = []
    private var set: Set<T> = []
    
    init() {}
    
    mutating func insert(_ value: T) {
        if set.insert(value).inserted {
            array.append(value)
        }
    }
    
    mutating func remove(_ value: IndexSet) {
        for index in value {
            if array.indices.contains(index) {
                set.remove(array[index])
            }
        }
        
        let rangeSet = RangeSet(value, within: array)
        array.removeSubranges(rangeSet)
    }
    
    func contains(_ value: T) -> Bool {
        set.contains(value)
    }
    
    var elements: [T] {
        array
    }
    
    var count: Int {
        array.count
    }
    
    var isEmpty: Bool {
        array.isEmpty
    }
}

extension OrderedSet: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: T...) {
        elements.forEach { insert($0) }
    }
}
