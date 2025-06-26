import SwiftUI
import SwiftData

struct CampaignDetailView: View {
    @Bindable var campaign: Campaign
    
    @State private var isAddingAdventurer = false
    @State private var newAdventurerData: AdventurerData?
    @State private var isAddingMonster = false
    @State private var newMonsterData: MonsterData?
    @State private var isAddingEncounter = false
    @State private var newEncounterData: EncounterData?
    
    @State private var editingAdventurer: Adventurer?
    @State private var adventurerToSave: Adventurer?
    @State private var pendingAdventurerData: AdventurerData?

    @State private var editingMonster: Monster?
    @State private var monsterToSave: Monster?
    @State private var pendingMonsterData: MonsterData?

    @State private var encounterToDelete: Encounter?
    @State private var adventurerToDelete: Adventurer?
    @State private var monsterToDelete: Monster?

    private var sortedEncounters: [Encounter] {
        campaign.encounters.sorted { $0.sortOrder < $1.sortOrder }
    }
    private var sortedAdventurers: [Adventurer] {
        campaign.adventurers.sorted { $0.sortOrder < $1.sortOrder }
    }
    private var sortedMonsters: [Monster] {
        campaign.monsters.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        VStack {
            VStack {
                TextField("Campaign Name", text: $campaign.name)
                    .font(.title2)
                    .textFieldStyle(.roundedBorder)
                    .padding()
            }
            .padding()

            List {
                Section(header: Text("Encounters")) {
                    Button(action: { isAddingEncounter = true }) {
                        Label("Add Encounter", systemImage: "plus")
                    }
                    ForEach(sortedEncounters) { encounter in
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            Text(encounter.name)
                                .font(.title3)
                            Spacer()
                            NavigationLink(value: encounter) {
                                Image(systemName: "figure.fencing")
                                    .font(.title3)
                            }
                            .buttonStyle(.borderless)
                            .help("Start Encounter")
                            
                            Button { copyEncounter(encounter) } label: { Image(systemName: "doc.on.doc") }.buttonStyle(.borderless).help("Copy")
                            Button {
                                encounterToDelete = encounter
                            } label: { Image(systemName: "trash").foregroundColor(.red) }.buttonStyle(.borderless).help("Delete")
                        }
                    }
                    .onMove(perform: moveEncounter)
                }
                
                Section(header: Text("Adventurers")) {
                    Button(action: { isAddingAdventurer = true }) {
                        Label("Add Adventurer", systemImage: "plus")
                    }
                    ForEach(sortedAdventurers) { adventurer in
                        HStack {
                            Image(systemName: adventurer.portrait)
                                .font(.title2)
                                .foregroundColor(.yellow)
                                .frame(width: 30)
                            Text(adventurer.name)
                            Spacer()
                            Button { editingAdventurer = adventurer } label: { Image(systemName: "pencil") }.buttonStyle(.borderless)
                            Button { copyAdventurer(adventurer) } label: { Image(systemName: "doc.on.doc") }.buttonStyle(.borderless)
                            Button {
                                adventurerToDelete = adventurer
                            } label: { Image(systemName: "trash").foregroundColor(.red) }.buttonStyle(.borderless)
                        }
                    }
                    .onMove(perform: moveAdventurer)
                }
                
                Section(header: Text("Monsters")) {
                    Button(action: { isAddingMonster = true }) {
                        Label("Add Monster", systemImage: "plus")
                    }
                    ForEach(sortedMonsters) { monster in
                        HStack {
                            Text(monster.name)
                            Spacer()
                            Button { editingMonster = monster } label: { Image(systemName: "pencil") }.buttonStyle(.borderless)
                            Button { copyMonster(monster) } label: { Image(systemName: "doc.on.doc") }.buttonStyle(.borderless)
                            Button {
                                monsterToDelete = monster
                            } label: { Image(systemName: "trash").foregroundColor(.red) }.buttonStyle(.borderless)
                        }
                    }
                    .onMove(perform: moveMonster)
                }
            }
        }
        .navigationTitle("Campaign Details")
        .sheet(isPresented: $isAddingAdventurer) {
            AddAdventurerSheet { data in
                self.newAdventurerData = data
            }
        }
        .sheet(isPresented: $isAddingMonster) {
            AddMonsterSheet { data in
                self.newMonsterData = data
            }
        }
        .sheet(isPresented: $isAddingEncounter) {
            AddEncounterSheet { data in
                self.newEncounterData = data
            }
        }
        .sheet(item: $editingAdventurer) { adventurer in
            AdventurerDetailView(adventurer: adventurer) { data in
                self.pendingAdventurerData = data
                self.adventurerToSave = adventurer
            }
        }
        .sheet(item: $editingMonster) { monster in
            MonsterDetailView(monster: monster) { data in
                self.pendingMonsterData = data
                self.monsterToSave = monster
            }
        }
        .onChange(of: isAddingAdventurer) { if !isAddingAdventurer { addAdventurer() } }
        .onChange(of: isAddingMonster) { if !isAddingMonster { addMonster() } }
        .onChange(of: isAddingEncounter) { if !isAddingEncounter { addEncounter() } }
        .onChange(of: editingAdventurer) { if editingAdventurer == nil { saveAdventurerChanges() } }
        .onChange(of: editingMonster) { if editingMonster == nil { saveMonsterChanges() } }
        .alert("Delete Encounter?", isPresented: .init(get: { encounterToDelete != nil }, set: { if !$0 { encounterToDelete = nil } }), presenting: encounterToDelete) { encounter in
            Button("Delete", role: .destructive) { deleteEncounter(encounter) }
        } message: { encounter in
            Text("Are you sure you want to delete \"\(encounter.name)\"? This action cannot be undone.")
        }
        .alert("Delete Adventurer?", isPresented: .init(get: { adventurerToDelete != nil }, set: { if !$0 { adventurerToDelete = nil } }), presenting: adventurerToDelete) { adventurer in
            Button("Delete", role: .destructive) { deleteAdventurer(adventurer) }
        } message: { adventurer in
            Text("Are you sure you want to delete \"\(adventurer.name)\"? This action cannot be undone.")
        }
        .alert("Delete Monster?", isPresented: .init(get: { monsterToDelete != nil }, set: { if !$0 { monsterToDelete = nil } }), presenting: monsterToDelete) { monster in
            Button("Delete", role: .destructive) { deleteMonster(monster) }
        } message: { monster in
            Text("Are you sure you want to delete \"\(monster.name)\"? This action cannot be undone.")
        }
        .navigationDestination(for: Encounter.self) { encounter in
            EncounterDetailView(encounter: encounter)
        }
    }
    
    // Encounter Methods
    private func addEncounter() {
        guard let data = newEncounterData, !data.name.trimmingCharacters(in: .whitespaces).isEmpty else { 
            return 
        }
        self.newEncounterData = nil

        let newEncounter = Encounter(name: data.name.trimmingCharacters(in: .whitespaces))
        newEncounter.sortOrder = (campaign.encounters.map(\.sortOrder).max() ?? -1) + 1
        campaign.encounters.append(newEncounter)
    }

    private func moveEncounter(from source: IndexSet, to destination: Int) {
        var ordered = campaign.encounters.sorted { $0.sortOrder < $1.sortOrder }
        ordered.move(fromOffsets: source, toOffset: destination)
        for (index, item) in ordered.enumerated() { item.sortOrder = index }
    }
    
    private func deleteEncounter(_ encounter: Encounter) {
        if let index = campaign.encounters.firstIndex(of: encounter) {
            campaign.encounters.remove(at: index)
        }
        encounterToDelete = nil
    }
    
    private func copyEncounter(_ encounter: Encounter) {
        let newEncounter = encounter.copy(for: campaign)
        campaign.encounters.append(newEncounter)
    }

    // Adventurer Methods
    private func addAdventurer() {
        guard let data = newAdventurerData, !data.name.trimmingCharacters(in: .whitespaces).isEmpty else { 
            return 
        }
        self.newAdventurerData = nil

        let newAdventurer = Adventurer(
            name: data.name.trimmingCharacters(in: .whitespaces),
            initiative: data.initiative,
            maxHP: data.maxHP,
            currentHP: data.maxHP,
            armorClass: data.armorClass,
            portrait: data.portrait
        )
        newAdventurer.sortOrder = (campaign.adventurers.map(\.sortOrder).max() ?? -1) + 1
        campaign.adventurers.append(newAdventurer)
    }

    private func moveAdventurer(from source: IndexSet, to destination: Int) {
        var ordered = campaign.adventurers.sorted { $0.sortOrder < $1.sortOrder }
        ordered.move(fromOffsets: source, toOffset: destination)
        for (index, item) in ordered.enumerated() { item.sortOrder = index }
    }

    private func deleteAdventurer(_ adventurer: Adventurer) {
        if let index = campaign.adventurers.firstIndex(of: adventurer) {
            campaign.adventurers.remove(at: index)
        }
        adventurerToDelete = nil
    }
    
    private func copyAdventurer(_ adventurer: Adventurer) {
        let newCopy = adventurer.copy(for: campaign)
        campaign.adventurers.append(newCopy)
    }
    
    private func saveAdventurerChanges() {
        guard let data = pendingAdventurerData, 
              let adventurer = adventurerToSave,
              !data.name.trimmingCharacters(in: .whitespaces).isEmpty else { 
            return 
        }
        self.pendingAdventurerData = nil
        self.adventurerToSave = nil

        adventurer.name = data.name.trimmingCharacters(in: .whitespaces)
        adventurer.initiative = data.initiative
        adventurer.maxHP = data.maxHP
        adventurer.currentHP = data.currentHP
        adventurer.armorClass = data.armorClass
        adventurer.portrait = data.portrait
    }

    // Monster Methods
    private func addMonster() {
        guard let data = newMonsterData, !data.name.trimmingCharacters(in: .whitespaces).isEmpty else { 
            return 
        }
        self.newMonsterData = nil

        let newMonster = Monster(
            name: data.name.trimmingCharacters(in: .whitespaces),
            initiative: data.initiative,
            maxHP: data.maxHP,
            currentHP: data.maxHP,
            armorClass: data.armorClass
        )
        newMonster.sortOrder = (campaign.monsters.map(\.sortOrder).max() ?? -1) + 1
        campaign.monsters.append(newMonster)
    }

    private func moveMonster(from source: IndexSet, to destination: Int) {
        var ordered = campaign.monsters.sorted { $0.sortOrder < $1.sortOrder }
        ordered.move(fromOffsets: source, toOffset: destination)
        for (index, item) in ordered.enumerated() { item.sortOrder = index }
    }

    private func deleteMonster(_ monster: Monster) {
        if let index = campaign.monsters.firstIndex(of: monster) {
            campaign.monsters.remove(at: index)
        }
        monsterToDelete = nil
    }
    
    private func copyMonster(_ monster: Monster) {
        let newCopy = monster.copy(for: campaign)
        campaign.monsters.append(newCopy)
    }
    
    private func saveMonsterChanges() {
        guard let data = pendingMonsterData, 
              let monster = monsterToSave,
              !data.name.trimmingCharacters(in: .whitespaces).isEmpty else { 
            return 
        }
        self.pendingMonsterData = nil
        self.monsterToSave = nil

        monster.name = data.name.trimmingCharacters(in: .whitespaces)
        monster.initiative = data.initiative
        monster.maxHP = data.maxHP
        monster.currentHP = data.currentHP
        monster.armorClass = data.armorClass
    }
} 
