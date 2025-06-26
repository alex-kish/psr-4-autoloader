import SwiftUI
import SwiftData
import Foundation

enum Combatant {
    case adventurer(Adventurer)
    case monster(Monster)

    var name: String {
        switch self {
        case .adventurer(let a): return a.name
        case .monster(let m): return m.name
        }
    }
    
    var initiative: Int {
        switch self {
        case .adventurer(let a): return a.initiative
        case .monster(let m): return m.initiative
        }
    }
    
    var maxHP: Int {
        switch self {
        case .adventurer(let a): return a.maxHP
        case .monster(let m): return m.maxHP
        }
    }
    
    var currentHP: Int {
        get {
            switch self {
            case .adventurer(let a): return a.currentHP
            case .monster(let m): return m.currentHP
            }
        }
        set {
            switch self {
            case .adventurer(let a): a.currentHP = newValue
            case .monster(let m): m.currentHP = newValue
            }
        }
    }
    
    var armorClass: Int {
        switch self {
        case .adventurer(let a): return a.armorClass
        case .monster(let m): return m.armorClass
        }
    }

    var isAlive: Bool {
        return self.currentHP > 0
    }
    
    var id: PersistentIdentifier {
        switch self {
        case .adventurer(let a): return a.id
        case .monster(let m): return m.id
        }
    }
}

struct CombatParticipant: Identifiable {
    var id = UUID()
    var combatant: Combatant
    var diceRoll: Int = 0
    
    var baseInitiative: Int {
        combatant.initiative
    }
    
    var totalInitiative: Int {
        baseInitiative + diceRoll
    }
}

struct HPAction: Identifiable {
    let id: UUID
    let participantId: PersistentIdentifier
    let type: HPChangeType
}

enum HPChangeType {
    case damage, healing
}

struct CombatLogEntry: Identifiable {
    let id = UUID()
    let round: Int
    let actor: String
    let target: String
    let action: String
    let amount: Int
    let timestamp: Date = Date()
    
    var description: String {
        if action.contains("rolled for initiative") {
            return "\(actor) \(action)"
        } else if action.contains("Round") && action.contains("begins") {
            return action
        } else if action == "died from damage" {
            return "\(actor) \(action)"
        } else if amount == 0 {
            return "\(actor) \(action) \(target)"
        } else {
            return "\(actor) \(action) \(amount) HP to \(target)"
        }
    }
} 