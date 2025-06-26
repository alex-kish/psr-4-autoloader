import SwiftUI

struct AddParticipantSheet: View {
    @Environment(\.dismiss) private var dismiss
    let availableAdventurers: [Adventurer]
    let availableMonsters: [Monster]
    let onAdd: (Combatant) -> Void
    
    @State private var selectedCombatant: Combatant?
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if !availableAdventurers.isEmpty {
                        Section("Adventurers") {
                            ForEach(availableAdventurers) { adventurer in
                                HStack {
                                    Image(systemName: adventurer.portrait)
                                        .font(.title2)
                                        .foregroundColor(.yellow)
                                        .frame(width: 30)
                                    VStack(alignment: .leading) {
                                        Text(adventurer.name)
                                            .font(.headline)
                                        Text("HP: \(adventurer.currentHP)/\(adventurer.maxHP) • AC: \(adventurer.armorClass) • Init: \(adventurer.initiative)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if case .adventurer(let selected) = selectedCombatant, selected.id == adventurer.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedCombatant = .adventurer(adventurer)
                                }
                            }
                        }
                    }
                    
                    Section("Monsters") {
                        ForEach(availableMonsters) { monster in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(monster.name)
                                        .font(.headline)
                                    Text("HP: \(monster.currentHP)/\(monster.maxHP) • AC: \(monster.armorClass) • Init: \(monster.initiative)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if case .monster(let selected) = selectedCombatant, selected.id == monster.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedCombatant = .monster(monster)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Participant")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let combatant = selectedCombatant {
                            onAdd(combatant)
                            dismiss()
                        }
                    }
                    .disabled(selectedCombatant == nil)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
} 