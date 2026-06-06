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
        static let collections = "app.collections".localized
        static let favorites = "app.favorites".localized
        static let delete = "app.delete".localized
        static let save = "app.save".localized
        static let rename = "app.rename".localized
        static let done = "app.done".localized
    }
    
    enum CollectionList {
        static let collectionListEmptyStateMessage = "collection_list.empty_state.message".localized
        static let collectionListEmptyStateDescription = "collection_list.empty_state.description".localized
        static let collectionListAlertAddTitle = "collection_list.alert.add_title".localized
        static let collectionListAlertAddTextField = "collection_list.alert.add_text_field".localized
        static func collectionListItemCount(_ count: Int) -> String {
            return "collection_list.item.count".localized(count)
        }
        static func collectionListDeleteConfirmTitle(_ text: String) -> String {
            "collection_list.delete.confirm_title".localized(text)
        }
        
        static func collectionListDeleteConfirmMessage(_ text: String) -> String {
            "collection_list.delete.confirm_message".localized(text)
        }
    }
    
    enum CollectionDetail {
        static let collectionDetailEmptyStateMessage = "collection_detail.empty_state.message".localized
        static let collectionDetailEmptyStateDescription = "collection_detail.empty_state.description".localized
        static let collectionDetailAlertAddTitle = "collection_detail.alert.add_title".localized
        static let collectionDetailAlertAddMessage = "collection_detail.alert.add_message".localized
        static let collectionDetailAlertAddTextField = "collection_detail.alert.add_text_field".localized
        static func collectionDetailItemCount(_ count: Int) -> String {
            return "collection_detail.item.count".localized(count)
        }
        static let collectionDetailCellDescription = "collection_detail.cell.description".localized
        static func collectionDetailCellDescriptionError(_ count: Int) -> String {
            return "collection_detail.cell.description.error".localized(count)
        }
        static let collectionDetailRemoveFromFavorite = "collection_detail.remove_from_favorites".localized
        static let collectionDetailAddToFavorite = "collection_detail.add_to_favorite".localized
    }
    
    enum Favorites {
        static let favoritesEmptyStateMessage = "favorites.empty_state.message".localized
        static let favoritesEmptyStateDescription = "favorites.empty_state.description".localized
        static func favoritesItemCount(_ count: Int) -> String {
            "favorites.item_count".localized(count)
        }
    }
    
    enum Search {
        static let searchTitle = "search.title".localized
        static let searchPlaceholder = "search.placeholder".localized
        static let searchResultsHeader = "search.results_header".localized
        static let searchHistoryHeader = "search.history_header".localized
        static let searchHistoryClear = "search.history_clear".localized
    }
    
    enum ItemDetail {
        static let itemDetailCollectionName = "item_detail.collection_name".localized
        static let itemDetailCreatedName = "item_detail.created_name".localized
        static let itemDetailRemoveFromFavorites = "item_detail.remove_from_favorites".localized
        static let itemDetailAddToFavorites = "item_detail.add_to_favorites".localized
        static func itemDetailDeleteConfirmTitle(_ text: String) -> String {
            "item_detail.delete.confirm_title".localized(text)
        }
        
        static func itemDetailDeleteConfirmMessage(_ text: String) -> String {
            "item_detail.delete.confirm_message".localized(text)
        }
    }
}
