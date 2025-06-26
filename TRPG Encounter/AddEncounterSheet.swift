import SwiftUI

struct AddEncounterSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (EncounterData) -> Void

    @State private var data = EncounterData()

    private var isSaveDisabled: Bool {
        data.isInvalid
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Encounter Name", text: $data.name)
            }
            .navigationTitle("New Encounter")
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
                    .disabled(isSaveDisabled)
                }
            }
        }
    }
} 