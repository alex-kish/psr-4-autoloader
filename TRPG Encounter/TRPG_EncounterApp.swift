//
//  TRPG_EncounterApp.swift
//  TRPG Encounter
//
//  Created by Aleksei Kishinskii on 15. 6. 2025..
//

import SwiftUI
import SwiftData

@main
struct TRPG_EncounterApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Campaign.self, Adventurer.self, Monster.self, Encounter.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            CampaignsView()
        }
        .modelContainer(sharedModelContainer)
    }
}
