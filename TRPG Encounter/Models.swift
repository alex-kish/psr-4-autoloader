import Foundation
import SwiftData

// MARK: - Available Portrait Icons for Adventurers
struct AdventurerPortraits {
    static let availablePortraits = [
        "person.fill",
        "person.crop.circle.fill",
        "figure.walk",
        "figure.run",
        "figure.archery",
        "figure.fencing",
        "shield.fill",
        "hammer.fill",
        "bolt.fill",
        "flame.fill",
        "sparkles",
        "star.fill",
        "crown.fill",
        "diamond.fill",
        "diamond",
        "wand.and.stars",
        "wand.and.rays",
        "scroll.fill",
        "book.fill",
        "cross.fill",
        "heart.fill",
        "eye.fill",
        "hand.raised.fill",
        "moon.fill",
        "sun.max.fill",
        "tornado",
        "snowflake",
        "leaf.fill",
        "tree.fill",
        "mountain.2.fill",
        "pawprint.fill",
        "hare.fill",
        "bird.fill",
        "lizard.fill",
        "ant.fill"
    ]
    
    static let defaultPortrait = "person.fill"
}

// MARK: - Protocol for shared character validation
protocol ValidatableCharacter {
    var _maxHP: Int { get }
    func validateInitiative(_ initiative: Int) -> Int
    func validateMaxHP(_ maxHP: Int) -> Int
    func validateCurrentHP(_ currentHP: Int) -> Int
    func validateArmorClass(_ armorClass: Int) -> Int
}

extension ValidatableCharacter {
    func validateInitiative(_ initiative: Int) -> Int {
        max(-5, min(20, initiative))
    }

    func validateMaxHP(_ maxHP: Int) -> Int {
        max(1, maxHP)
    }

    func validateCurrentHP(_ currentHP: Int) -> Int {
        max(0, min(_maxHP, currentHP))
    }

    func validateArmorClass(_ armorClass: Int) -> Int {
        max(1, min(30, armorClass))
    }
}

@Model
final class Campaign {
    @Attribute(.unique) var id: UUID
    var name: String
    var creationDate: Date
    var sortOrder: Int = 0
    
    @Relationship(deleteRule: .cascade, inverse: \Adventurer.campaign)
    var adventurers: [Adventurer] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Monster.campaign)
    var monsters: [Monster] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Encounter.campaign)
    var encounters: [Encounter] = []

    init(name: String, creationDate: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.creationDate = creationDate
    }

    func copy() -> Campaign {
        let newCampaign = Campaign(name: "\(self.name) (Copy)")
        
        newCampaign.adventurers = self.adventurers.map { adventurer in
            let newAdventurer = Adventurer(name: adventurer.name, initiative: adventurer.initiative, maxHP: adventurer.maxHP, currentHP: adventurer.currentHP, armorClass: adventurer.armorClass, portrait: adventurer.portrait)
            newAdventurer.campaign = newCampaign
            return newAdventurer
        }
        
        newCampaign.monsters = self.monsters.map { monster in
            let newMonster = Monster(name: monster.name, initiative: monster.initiative, maxHP: monster.maxHP, currentHP: monster.currentHP, armorClass: monster.armorClass)
            newMonster.campaign = newCampaign
            return newMonster
        }
        
        newCampaign.encounters = self.encounters.map { encounter in
            let newEncounter = Encounter(name: encounter.name)
            newEncounter.campaign = newCampaign
            // Note: This creates new encounters, but doesn't populate them with the copied adventurers/monsters.
            // This would require a more complex copy logic to map old participants to new ones.
            // For now, encounters are copied empty.
            return newEncounter
        }
        
        return newCampaign
    }
}

@Model
final class Adventurer: ValidatableCharacter {
    var _name: String = ""
    var _initiative: Int = 0
    var _maxHP: Int = 1
    var _currentHP: Int = 1
    var _armorClass: Int = 10
    var _portrait: String = AdventurerPortraits.defaultPortrait
    
    var name: String {
        get { _name }
        set { _name = validateName(newValue) }
    }
    
    var initiative: Int {
        get { _initiative }
        set { _initiative = validateInitiative(newValue) }
    }
    
    var maxHP: Int {
        get { _maxHP }
        set { 
            _maxHP = validateMaxHP(newValue)
            if _currentHP > _maxHP { _currentHP = _maxHP }
        }
    }
    
    var currentHP: Int {
        get { _currentHP }
        set { _currentHP = validateCurrentHP(newValue) }
    }
    
    var armorClass: Int {
        get { _armorClass }
        set { _armorClass = validateArmorClass(newValue) }
    }
    
    var portrait: String {
        get { _portrait }
        set { _portrait = validatePortrait(newValue) }
    }
    
    var sortOrder: Int = 0
    
    var isAlive: Bool {
        currentHP > 0
    }
    
    var campaign: Campaign?
    
    @Relationship(inverse: \Encounter.adventurers)
    var encounters: [Encounter]?

    init(name: String, initiative: Int, maxHP: Int, currentHP: Int, armorClass: Int, portrait: String = AdventurerPortraits.defaultPortrait) {
        self._name = validateName(name)
        self._initiative = validateInitiative(initiative)
        self._maxHP = validateMaxHP(maxHP)
        self._armorClass = validateArmorClass(armorClass)
        self._currentHP = validateCurrentHP(min(currentHP, self._maxHP))
        self._portrait = validatePortrait(portrait)
    }
    
    private func validateName(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "Unnamed Adventurer" : trimmed
    }
    
    private func validatePortrait(_ portrait: String) -> String {
        return AdventurerPortraits.availablePortraits.contains(portrait) ? portrait : AdventurerPortraits.defaultPortrait
    }

    func copy(for campaign: Campaign) -> Adventurer {
        let newAdventurer = Adventurer(
            name: "\(self.name) (Copy)",
            initiative: self.initiative,
            maxHP: self.maxHP,
            currentHP: self.currentHP,
            armorClass: self.armorClass,
            portrait: self.portrait
        )
        newAdventurer.sortOrder = (campaign.adventurers.map(\.sortOrder).max() ?? -1) + 1
        return newAdventurer
    }
}

@Model
final class Monster: ValidatableCharacter {
    var _name: String = ""
    var _initiative: Int = 0
    var _maxHP: Int = 1
    var _currentHP: Int = 1
    var _armorClass: Int = 10
    
    var name: String {
        get { _name }
        set { _name = validateName(newValue) }
    }
    
    var initiative: Int {
        get { _initiative }
        set { _initiative = validateInitiative(newValue) }
    }
    
    var maxHP: Int {
        get { _maxHP }
        set { 
            _maxHP = validateMaxHP(newValue)
            if _currentHP > _maxHP { _currentHP = _maxHP }
        }
    }
    
    var currentHP: Int {
        get { _currentHP }
        set { _currentHP = validateCurrentHP(newValue) }
    }
    
    var armorClass: Int {
        get { _armorClass }
        set { _armorClass = validateArmorClass(newValue) }
    }
    
    var sortOrder: Int = 0
    
    var isAlive: Bool {
        currentHP > 0
    }
    
    var campaign: Campaign?
    
    @Relationship(inverse: \Encounter.monsters)
    var encounters: [Encounter]?

    init(name: String, initiative: Int, maxHP: Int, currentHP: Int, armorClass: Int) {
        self._name = validateName(name)
        self._initiative = validateInitiative(initiative)
        self._maxHP = validateMaxHP(maxHP)
        self._armorClass = validateArmorClass(armorClass)
        self._currentHP = validateCurrentHP(min(currentHP, self._maxHP))
    }
    
    private func validateName(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "Unnamed Monster" : trimmed
    }

    func copy(for campaign: Campaign) -> Monster {
        let newMonster = Monster(
            name: "\(self.name) (Copy)",
            initiative: self.initiative,
            maxHP: self.maxHP,
            currentHP: self.currentHP,
            armorClass: self.armorClass
        )
        newMonster.sortOrder = (campaign.monsters.map(\.sortOrder).max() ?? -1) + 1
        return newMonster
    }
}

@Model
final class Encounter {
    var name: String
    var sortOrder: Int = 0
    
    var adventurers: [Adventurer] = []
    var monsters: [Monster] = []
    
    var campaign: Campaign?

    init(name: String) {
        self.name = name
    }
    
    func copy(for campaign: Campaign) -> Encounter {
        let newEncounter = Encounter(name: "\(self.name) (Copy)")
        newEncounter.adventurers = self.adventurers
        newEncounter.monsters = self.monsters
        newEncounter.sortOrder = (campaign.encounters.map(\.sortOrder).max() ?? -1) + 1
        return newEncounter
    }
} 