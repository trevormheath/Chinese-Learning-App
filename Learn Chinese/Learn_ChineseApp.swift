//
//  Learn_ChineseApp.swift
//  Learn Chinese
//
//  Created by IS 543 on 10/17/24.
//

import SwiftUI

@main
struct Learn_ChineseApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(languageViewModel: LanguageViewModel())
        }
    }
}
