//
//  NilSafeOperators.swift
//  NilSafeProfile
//
//  Created by Okan Orkun on 9.06.2026.
//

import Foundation

// This operator is global because many features might need safe asset loading.
infix operator !!
func !!<T>(wrapped: T?, failureText: @autoclosure () -> String) -> T {
    if let x = wrapped { return x }
    fatalError(failureText()) // Crash the app on purpose with our helpful message
}
