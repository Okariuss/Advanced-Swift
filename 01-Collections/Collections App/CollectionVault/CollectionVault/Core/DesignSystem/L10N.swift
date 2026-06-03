//
//  L10N.swift
//  CollectionVault
//
//  Created by Okan Orkun on 3.06.2026.
//

enum L10N {
    
    enum General {
        static let appName = "app.name".localized
        static let cancel = "app.cancel".localized
        static let add = "app.add".localized
    }
    
    enum CollectionList {
        static let collectionListEmptyStateMessage = "collection_list.empty_state.message".localized
        static let collectionListEmptyStateDescription = "collection_list.empty_state.description".localized
        static let collectionListAlertAddTitle = "collection_list.alert.add_title".localized
        static let collectionListAlertAddTextField = "collection_list.alert.add_text_field".localized
        static func collectionListItemCount(_ count: Int) -> String {
            return "collection_list.item.count".localized(count)
        }
    }
}
