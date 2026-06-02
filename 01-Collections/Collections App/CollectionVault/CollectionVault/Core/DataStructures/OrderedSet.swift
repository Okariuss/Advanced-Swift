//
//  OrderedSet.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import Foundation

struct OrderedSet<T: Hashable> {
    
    private var array: [T] = []
    private var set: Set<T> = []
    
    init() {}
    
    mutating func insert(_ value: T) {
        if set.contains(value) {
            if let index = array.firstIndex(of: value) {
                array.remove(at: index)
            }
        } else {
            set.insert(value)
        }
        array.insert(value, at: 0)
    }
    
    mutating func remove(_ value: T) {
        guard set.contains(value) else { return }
        set.remove(value)
        if let index = array.firstIndex(of: value) {
            array.remove(at: index)
        }
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
