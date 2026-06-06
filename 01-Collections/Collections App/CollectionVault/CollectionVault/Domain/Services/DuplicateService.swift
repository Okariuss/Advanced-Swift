//
//  DuplicateService.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import Foundation

struct DuplicateService {
    
    func findDuplicates(in items: [VaultItem]) -> [String: Int] {
        frequencyMap(for: items)
            .filter { $0.value > 1 }
    }
    
    func hasDuplicates(in items: [VaultItem]) -> Bool {
        let freq = frequencyMap(for: items)
        return freq.contains(where: { $0.value > 1 })
    }
    
    static func normalized(_ title: String) -> String {
        title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func frequencyMap(for items: [VaultItem]) -> [String: Int] {
        items.reduce(into: [String: Int]()) { freq, item in
            let key = DuplicateService.normalized(item.title)
            freq[key, default: 0] += 1
        }
    }
}
