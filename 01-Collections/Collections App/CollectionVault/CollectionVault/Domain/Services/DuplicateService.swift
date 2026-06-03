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
    
    func duplicateLabels(in items: [VaultItem]) -> [String: String] {
        findDuplicates(in: items)
            .mapValues { count in
                "\(count)x duplicate"
            }
    }
    
    private func frequencyMap(for items: [VaultItem]) -> [String: Int] {
        var freq = [String: Int]()
        
        for item in items {
            let key = item.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            freq[key, default: 0] += 1
        }
        
        return freq
    }
}
