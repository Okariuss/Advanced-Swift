//
//  AlertPresenting.swift
//  CollectionVault
//
//  Created by Okan Orkun on 4.06.2026.
//

import UIKit

protocol AlertPresenting: AnyObject {
    func presentNameAlert(
        title: String,
        message: String?,
        placeholder: String,
        confirmTitle: String,
        currentValue: String?,
        completion: @escaping (String) -> Void
    )
 
    func presentDestructiveConfirmation(
        title: String,
        message: String,
        destructiveTitle: String,
        completion: @escaping () -> Void
    )
}
 
extension AlertPresenting where Self: UIViewController {
 
    func presentNameAlert(
        title: String,
        message: String?,
        placeholder: String,
        confirmTitle: String,
        currentValue: String?,
        completion: @escaping (String) -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = placeholder
            $0.text = currentValue
            $0.clearButtonMode = .whileEditing
            $0.autocapitalizationType = .sentences
        }
        alert.addAction(UIAlertAction(title: L10N.General.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default) { _ in
            guard let text = alert.textFields?.first?.text,
                  !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            completion(text)
        })
        present(alert, animated: true) { alert.textFields?.first?.selectAll(nil) }
    }
 
    func presentDestructiveConfirmation(
        title: String,
        message: String,
        destructiveTitle: String,
        completion: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10N.General.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: destructiveTitle, style: .destructive) { _ in
            completion()
        })
        present(alert, animated: true)
    }
}
