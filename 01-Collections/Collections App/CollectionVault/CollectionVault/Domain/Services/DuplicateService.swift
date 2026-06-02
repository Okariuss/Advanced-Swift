//
//  DuplicateService.swift
//  CollectionVault
//
//  Created by Okan Orkun on 2.06.2026.
//

import Foundation

struct DuplicateService {
    func findDuplicates(in items: [VaultItem]) -> [String: Int] {
        var dict: [String: Int] = [:]
        
        for item in items {
            let normalizedTitle = item.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            dict[normalizedTitle, default: 0] += 1
        }
        
        return dict.filter { $0.value > 1 }
    }
}
