import SwiftUI

struct HPChangeView: View {
    let participant: CombatParticipant
    let type: HPChangeType
    let onCommit: (Int) -> Void

    @State private var amountString: String = ""
    @Environment(\.dismiss) private var dismiss

    private var isAmountValid: Bool {
        if let amount = Int(amountString), amount > 0 {
            return true
        }
        return false
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(type == .damage ? "Deal Damage" : "Heal")
                .font(.largeTitle)
            Text(participant.combatant.name)
                .font(.title2)
                .foregroundColor(.secondary)

            TextField("Amount", text: $amountString)
                .multilineTextAlignment(.center)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                .onChange(of: amountString) {
                    let filtered = amountString.filter { "0123456789".contains($0) }
                    if filtered != amountString {
                        self.amountString = filtered
                    }
                }

            HStack(spacing: 20) {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Commit") {
                    if let amount = Int(amountString) {
                        onCommit(amount)
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isAmountValid)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(30)
        .frame(minWidth: 350)
    }
} 