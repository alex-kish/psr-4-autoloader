import SwiftUI
import Foundation

@MainActor
class CombatViewModel: ObservableObject {
    @Published var currentTurnIndex: Int = 0
    @Published var activeHPAction: HPAction?
    
    private let soundPlayer = SoundPlayer()
    
    func nextTurn(participants: [CombatParticipant], round: inout Int, combatLog: inout [CombatLogEntry]) {
        guard !participants.isEmpty else { return }
        
        currentTurnIndex += 1
        if currentTurnIndex >= participants.count {
            currentTurnIndex = 0
            round += 1
            
            let newRoundEntry = CombatLogEntry(
                round: round,
                actor: "",
                target: "",
                action: "Round \(round) begins",
                amount: 0
            )
            combatLog.append(newRoundEntry)
        }
    }
    
    func previousTurn(participants: [CombatParticipant], round: inout Int) {
        guard !participants.isEmpty else { return }
        
        currentTurnIndex -= 1
        if currentTurnIndex < 0 {
            currentTurnIndex = participants.count - 1
            round = max(1, round - 1)
        }
    }
    
    func applyHPChange(
        to participants: inout [CombatParticipant],
        index: Int,
        amount: Int,
        type: HPChangeType,
        round: Int,
        combatLog: inout [CombatLogEntry]
    ) {
        guard index < participants.count else { return }
        
        let oldHP = participants[index].combatant.currentHP
        
        switch type {
        case .damage:
            participants[index].combatant.currentHP -= amount
        case .healing:
            let maxHP = participants[index].combatant.maxHP
            participants[index].combatant.currentHP += amount
            if participants[index].combatant.currentHP > maxHP {
                participants[index].combatant.currentHP = maxHP
            }
        }
        
        let actor: String
        if currentTurnIndex < participants.count {
            actor = participants[currentTurnIndex].combatant.name
        } else {
            actor = "Unknown"
        }
        
        let target = participants[index].combatant.name
        let actionText = type == .damage ? "dealt" : "healed"
        
        let logEntry = CombatLogEntry(
            round: round,
            actor: actor,
            target: target == actor ? "themselves" : target,
            action: actionText,
            amount: amount
        )
        
        combatLog.append(logEntry)
        
        if type == .damage {
            if oldHP > 0 && participants[index].combatant.currentHP <= 0 {
                let deathEntry = CombatLogEntry(
                    round: round,
                    actor: target,
                    target: "",
                    action: "died from damage",
                    amount: 0
                )
                combatLog.append(deathEntry)
                playSound(named: "death", withExtension: "mp3")
            } else {
                playSound(named: "damage", withExtension: "mp3")
            }
        } else if type == .healing {
            playSound(named: "heal", withExtension: "mp3")
        }
    }
    
    func removeParticipant(
        from participants: inout [CombatParticipant],
        at index: Int,
        round: Int,
        combatLog: inout [CombatLogEntry]
    ) {
        guard index >= 0 && index < participants.count else { return }
        let removedCombatant = participants[index].combatant
        participants.remove(at: index)
        
        if participants.isEmpty {
            currentTurnIndex = 0
        } else if currentTurnIndex > index {
            currentTurnIndex -= 1
        } else if currentTurnIndex >= participants.count {
            currentTurnIndex = participants.count - 1
        }
        
        let logEntry = CombatLogEntry(
            round: round,
            actor: removedCombatant.name,
            target: "",
            action: "left the combat",
            amount: 0
        )
        combatLog.append(logEntry)
    }
    
    private func playSound(named name: String, withExtension ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Audio file '\(name).\(ext)' not found.")
            return
        }
        soundPlayer.play(url: url)
    }
} 