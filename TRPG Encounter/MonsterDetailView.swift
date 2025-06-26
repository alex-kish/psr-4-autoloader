import SwiftUI

struct MonsterDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var data: MonsterData
    var onSave: (MonsterData) -> Void
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    init(monster: Monster, onSave: @escaping (MonsterData) -> Void) {
        var initialData = MonsterData()
        initialData.name = monster.name
        initialData.initiative = monster.initiative
        initialData.maxHP = monster.maxHP
        initialData.currentHP = monster.currentHP
        initialData.armorClass = monster.armorClass
        
        _data = State(initialValue: initialData)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $data.name)
                TextField("Initiative", value: $data.initiative, formatter: numberFormatter)
                TextField("Max HP", value: $data.maxHP, formatter: numberFormatter)
                TextField("Current HP", value: $data.currentHP, formatter: numberFormatter)
                TextField("Armor Class", value: $data.armorClass, formatter: numberFormatter)
            }
            .onChange(of: data.maxHP) {
                if data.currentHP > data.maxHP {
                    data.currentHP = data.maxHP
                }
            }
            .navigationTitle("Edit Monster")
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
        }
    }
} 