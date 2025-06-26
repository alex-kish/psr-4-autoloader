import SwiftUI

struct AddAdventurerSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (AdventurerData) -> Void
    
    @State private var data = AdventurerData()
    @State private var showingPortraitPicker = false

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
                                Text("Choose")
                                    .foregroundColor(.blue)
                            }
                        }
                        .buttonStyle(.borderless)
                    }
                }
                
                Section("Stats") {
                    TextField("Initiative", value: $data.initiative, formatter: numberFormatter)
                    TextField("Max HP", value: $data.maxHP, formatter: numberFormatter)
                    TextField("Armor Class", value: $data.armorClass, formatter: numberFormatter)
                }
            }
            .navigationTitle("New Adventurer")
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
            .sheet(isPresented: $showingPortraitPicker) {
                PortraitPickerSheet(selectedPortrait: $data.portrait)
            }
        }
    }
}

struct PortraitPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPortrait: String
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 6)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(AdventurerPortraits.availablePortraits, id: \.self) { portrait in
                        Button(action: {
                            selectedPortrait = portrait
                            dismiss()
                        }) {
                            VStack {
                                Image(systemName: portrait)
                                    .font(.largeTitle)
                                    .foregroundColor(selectedPortrait == portrait ? .white : .primary)
                                    .frame(width: 60, height: 60)
                                    .background(
                                        Circle()
                                            .fill(selectedPortrait == portrait ? Color.blue : Color.gray.opacity(0.2))
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(selectedPortrait == portrait ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Portrait")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 