//
//  String+Extensions.swift
//  CollectionVault
//
//  Created by Okan Orkun on 3.06.2026.
//

import Foundation

extension String {
    
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func localized(_ args: CVarArg...) -> String {
        let format = NSLocalizedString(self, comment: "")
        return String.localizedStringWithFormat(format, args)
    }
}
