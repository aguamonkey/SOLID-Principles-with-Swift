//
//  LSPExampleApp.swift
//  LSPExample
//
//  Created by Gobias LTD on 31/12/2023.
//

import SwiftUI

@main
struct LSPExampleApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView().tabItem { Label("Score", systemImage: "music.note.list") }
                AsyncRehearsalView().tabItem { Label("Async Lab", systemImage: "checkmark.seal") }
            }.tint(RehearsalStyle.accent)
        }
    }
}
