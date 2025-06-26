import SwiftUI

struct AddMonsterSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (MonsterData) -> Void
    
    @State private var data = MonsterData()

    private var isSaveDisabled: Bool {
        data.isInvalid
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $data.name)
                TextField("Initiative", value: $data.initiative, formatter: numberFormatter)
                TextField("Max HP", value: $data.maxHP, formatter: numberFormatter)
                TextField("Armor Class", value: $data.armorClass, formatter: numberFormatter)
            }
            .navigationTitle("New Monster")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var finalData = data
                        finalData.currentHP = finalData.maxHP
                        onSave(finalData)
                        dismiss()
                    }
                    .disabled(isSaveDisabled)
                }
            }
        }
    }
} 