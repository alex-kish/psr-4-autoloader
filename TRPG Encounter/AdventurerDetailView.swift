import SwiftUI

struct AdventurerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var data: AdventurerData
    @State private var showingPortraitPicker = false
    var onSave: (AdventurerData) -> Void
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    init(adventurer: Adventurer, onSave: @escaping (AdventurerData) -> Void) {
        var initialData = AdventurerData()
        initialData.name = adventurer.name
        initialData.initiative = adventurer.initiative
        initialData.maxHP = adventurer.maxHP
        initialData.currentHP = adventurer.currentHP
        initialData.armorClass = adventurer.armorClass
        initialData.portrait = adventurer.portrait
        
        _data = State(initialValue: initialData)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: $data.name)
                    
                    HStack {
                        Text("Portrait")
                        Spacer()
                        Button(action: { showingPortraitPicker = true }) {
                            HStack {
                                Image(systemName: data.portrait)
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                Text("Change")
                                    .foregroundColor(.blue)
                            }
                        }
                        .buttonStyle(.borderless)
                    }
                }
                
                Section("Stats") {
                    TextField("Initiative", value: $data.initiative, formatter: numberFormatter)
                    TextField("Max HP", value: $data.maxHP, formatter: numberFormatter)
                    TextField("Current HP", value: $data.currentHP, formatter: numberFormatter)
                    TextField("Armor Class", value: $data.armorClass, formatter: numberFormatter)
                }
            }
            .onChange(of: data.maxHP) {
                if data.currentHP > data.maxHP {
                    data.currentHP = data.maxHP
                }
            }
            .navigationTitle("Edit Adventurer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(data)
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPortraitPicker) {
                PortraitPickerSheet(selectedPortrait: $data.portrait)
            }
        }
    }
} 