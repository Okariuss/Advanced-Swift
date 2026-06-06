//
//  ItemDetailSection.swift
//  CollectionVault
//
//  Created by Okan Orkun on 4.06.2026.
//

enum ItemDetailSection: Int, CaseIterable {
    case info = 0
    case actions = 1
    
    var rowCount: Int {
        switch self {
        case .info:
            ItemDetailInfoRow.allCases.count
        case .actions:
            ItemDetailActionRow.allCases.count
        }
    }
}

enum ItemDetailInfoRow: Int, CaseIterable {
    case collection = 0
    case created = 1
}

enum ItemDetailActionRow: Int, CaseIterable {
    case favorite = 0
    case rename = 1
    case delete = 2
}
