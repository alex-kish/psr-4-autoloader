import Foundation

/// A protocol for temporary data-holding structs used in edit/creation views.
protocol CharacterData {
    var name: String { get set }
    var initiative: Int { get set }
    var maxHP: Int { get set }
    var currentHP: Int { get set }
    var armorClass: Int { get set }
}

extension CharacterData {
    var isInvalid: Bool {
        name.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

// A temporary, non-persistent struct to hold edits for Adventurers.
struct AdventurerData: CharacterData {
    var name: String = ""
    var initiative: Int = 3
    var maxHP: Int = 10
    var currentHP: Int = 10
    var armorClass: Int = 10
    var portrait: String = AdventurerPortraits.defaultPortrait
}

// A temporary, non-persistent struct to hold edits for Monsters.
struct MonsterData: CharacterData {
    var name: String = ""
    var initiative: Int = 3
    var maxHP: Int = 10
    var currentHP: Int = 10
    var armorClass: Int = 10
}

// A temporary, non-persistent struct to hold edits for Encounters.
struct EncounterData {
    var name: String = ""

    var isInvalid: Bool {
        name.trimmingCharacters(in: .whitespaces).isEmpty
    }
} 