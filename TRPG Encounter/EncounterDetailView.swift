import SwiftUI
import SwiftData

struct EncounterDetailView: View {
    @Bindable var encounter: Encounter
    @State private var isCombatActive = false
    @State private var combatants: [CombatParticipant] = []
    @Environment(\.dismiss) private var dismiss
    @State private var showingEndCombatAlert = false
    @State private var showingAddParticipant = false
    @State private var combatLog: [CombatLogEntry] = []
    @State private var round: Int = 1
    @StateObject private var soundPlayer = SoundPlayer()
    
    // We need to get the campaign's adventurers and monsters
    // This assumes the encounter has a campaign.
    private var allAdventurers: [Adventurer] { encounter.campaign?.adventurers ?? [] }
    private var allMonsters: [Monster] { encounter.campaign?.monsters ?? [] }

    private var navigationTitle: String {
        let campaignName = encounter.campaign?.name ?? "Unknown Campaign"
        return "\(campaignName) > \(encounter.name)"
    }

    var body: some View {
        VStack {
            if isCombatActive {
                CombatView(
                    participants: $combatants,
                    onEnd: endCombat,
                    combatLog: $combatLog,
                    round: $round
                )
            } else {
                VStack {
                    Form {
                        Section(header: Text("Encounter Name")) {
                            TextField("Name", text: $encounter.name)
                        }
                    }
                    .frame(height: 100)
                    
                    HStack(alignment: .top, spacing: 20) {
                        VStack {
                            Text("Adventurers").font(.headline)

                            List {
                                ForEach(encounter.adventurers) { adventurer in
                                    HStack {
                                        Image(systemName: adventurer.portrait)
                                            .font(.title2)
                                            .foregroundColor(.yellow)
                                            .frame(width: 30)
                                        Text(adventurer.name)
                                        Spacer()
                                        Button { 
                                            encounter.adventurers.removeAll { $0.id == adventurer.id }
                                        } label: {
                                            Image(systemName: "trash").foregroundColor(.red)
                                        }
                                        .buttonStyle(.borderless)
                                    }
                                }
                                Menu("Add Adventurer") {
                                    ForEach(allAdventurers.filter { adv in 
                                        !encounter.adventurers.contains(adv) 
                                    }) { adventurer in
                                        Button(adventurer.name) { 
                                            encounter.adventurers.append(adventurer)
                                        }
                                    }
                                }
                            }
                            
                            Button("Add All") {
                                encounter.adventurers = allAdventurers
                            }
                        }
                        
                        VStack {
                            Text("Monsters").font(.headline)
                            List {
                                ForEach(encounter.monsters) { monster in
                                    HStack {
                                        Text(monster.name)
                                        Spacer()
                                        Button { 
                                            encounter.monsters.removeAll { $0.id == monster.id }
                                        } label: {
                                            Image(systemName: "trash").foregroundColor(.red)
                                        }
                                        .buttonStyle(.borderless)
                                    }
                                }
                                Menu("Add Monster") {
                                    ForEach(allMonsters.filter { mon in 
                                        !encounter.monsters.contains(mon) 
                                    }) { monster in
                                        Button(monster.name) { 
                                            encounter.monsters.append(monster)
                                        }
                                    }
                                }
                            }
                            Button("Add All") {
                                encounter.monsters = allMonsters
                            }
                        }
                    }
                    
                    Button("Start Combat") {
                        startCombat()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .controlSize(.large)
                    .padding(.vertical)
                }
                .padding([.horizontal, .bottom])
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarBackButtonHidden(isCombatActive)
        .toolbar {
            if isCombatActive {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        showingAddParticipant = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Participant")
                        }
                    }
                    .foregroundColor(.green)
                    
                    Button {
                        showingEndCombatAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "stop.circle.fill")
                            Text("Finish Combat")
                        }
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .alert("Finish the combat?", isPresented: $showingEndCombatAlert) {
            Button("Finish", role: .destructive) {
                endCombat()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to finish the combat? All progress will be lost.")
        }
        .sheet(isPresented: $showingAddParticipant) {
            AddParticipantSheet(
                availableAdventurers: availableAdventurers,
                availableMonsters: availableMonsters
            ) { combatant in
                addParticipantToCombat(combatant)
            }
        }
    }
    
    private var availableAdventurers: [Adventurer] {
        guard let campaign = encounter.campaign else { return [] }
        let currentAdventurerIDs = combatants.compactMap { participant in
            if case .adventurer(let adventurer) = participant.combatant {
                return adventurer.id
            }
            return nil
        }
        return campaign.adventurers.filter { !currentAdventurerIDs.contains($0.id) }
    }
    
    private var availableMonsters: [Monster] {
        guard let campaign = encounter.campaign else { return [] }
        let currentMonsterIDs = combatants.compactMap { participant in
            if case .monster(let monster) = participant.combatant {
                return monster.id
            }
            return nil
        }
        return campaign.monsters.filter { !currentMonsterIDs.contains($0.id) }
    }

    private func addParticipantToCombat(_ combatant: Combatant) {
        let newParticipant = CombatParticipant(
            combatant: combatant,
            diceRoll: 0
        )
        combatants.append(newParticipant)
        
        let logEntry = CombatLogEntry(
            round: round,
            actor: combatant.name,
            target: "",
            action: "joined the combat",
            amount: 0
        )
        combatLog.append(logEntry)
    }
    
    private func startCombat() {
        // First, reset monster HP outside of the map
        for monster in encounter.monsters {
            monster.currentHP = monster.maxHP
        }
        
        let allCombatants: [Combatant] = (
            encounter.adventurers.map { .adventurer($0) } +
            encounter.monsters.map { .monster($0) }
        )
        
        var participants = allCombatants.map {
            CombatParticipant(combatant: $0, diceRoll: Int.random(in: 1...20))
        }

        // Create log entries for initiative rolls
        var initialLogs: [CombatLogEntry] = participants.map { participant in
            CombatLogEntry(
                round: 1,
                actor: participant.combatant.name,
                target: "",
                action: "rolled for initiative: \(participant.totalInitiative) (\(participant.baseInitiative) base + \(participant.diceRoll) roll)",
                amount: 0
            )
        }
        
        // Add round 1 begins log
        initialLogs.append(CombatLogEntry(
            round: 1,
            actor: "",
            target: "",
            action: "Round 1 begins",
            amount: 0
        ))

        // Sort by initiative, with tie-breaking
        participants.sort {
            if $0.totalInitiative != $1.totalInitiative {
                return $0.totalInitiative > $1.totalInitiative
            }
            // Tie-breaking: higher base initiative wins, then higher dice roll
            if $0.baseInitiative != $1.baseInitiative {
                return $0.baseInitiative > $1.baseInitiative
            }
            return $0.diceRoll > $1.diceRoll
        }
        
        self.combatLog = initialLogs
        self.combatants = participants
        self.isCombatActive = true
        playSound(named: "roll", withExtension: "mp3")
    }

    private func endCombat() {
        isCombatActive = false
        combatants.removeAll()
        combatLog.removeAll()
        round = 1
    }
    
    private func addAdventurer(_ adventurer: Adventurer) {
        encounter.adventurers.append(adventurer)
    }

    private func removeAdventurer(_ adventurer: Adventurer) {
        encounter.adventurers.removeAll { $0.id == adventurer.id }
    }
    
    private func addAllAdventurers() {
        encounter.adventurers = allAdventurers
    }
    
    private func addMonster(_ monster: Monster) {
        encounter.monsters.append(monster)
    }
    
    private func removeMonster(_ monster: Monster) {
        encounter.monsters.removeAll { $0.id == monster.id }
    }
    
    private func addAllMonsters() {
        encounter.monsters = allMonsters
    }

    private func playSound(named name: String, withExtension ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Audio file '\(name).\(ext)' not found.")
            return
        }
        soundPlayer.play(url: url)
    }
} 
 
