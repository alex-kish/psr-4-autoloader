import SwiftUI

struct CombatView: View {
    @Binding var participants: [CombatParticipant]
    var onEnd: () -> Void
    @Binding var combatLog: [CombatLogEntry]
    @Binding var round: Int

    @StateObject private var viewModel = CombatViewModel()
    @State private var isLogCollapsed = false
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    CombatControlsView(
                        round: round,
                        currentTurnIndex: viewModel.currentTurnIndex,
                        canGoPrevious: round > 1 || viewModel.currentTurnIndex > 0
                    ) {
                        viewModel.previousTurn(participants: participants, round: &round)
                    } onNext: {
                        viewModel.nextTurn(participants: participants, round: &round, combatLog: &combatLog)
                    }

                    List {
                        ForEach(participants.indices, id: \.self) { index in
                            CombatParticipantRow(
                                participant: participants[index],
                                index: index,
                                isCurrentTurn: viewModel.currentTurnIndex == index
                            ) {
                                viewModel.activeHPAction = HPAction(
                                    id: UUID(),
                                    participantId: participants[index].combatant.id,
                                    type: .damage
                                )
                            } onHeal: {
                                viewModel.activeHPAction = HPAction(
                                    id: UUID(),
                                    participantId: participants[index].combatant.id,
                                    type: .healing
                                )
                            } onRemove: {
                                viewModel.removeParticipant(
                                    from: &participants,
                                    at: index,
                                    round: round,
                                    combatLog: &combatLog
                                )
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(maxHeight: .infinity)
                }
                .frame(width: isLogCollapsed ? geometry.size.width * 0.95 : geometry.size.width * 0.7)
                .animation(.easeInOut(duration: 0.3), value: isLogCollapsed)
                
                Divider()
                
                CombatLogView(combatLog: combatLog, isCollapsed: $isLogCollapsed)
                    .frame(width: isLogCollapsed ? geometry.size.width * 0.05 : geometry.size.width * 0.3)
                    .animation(.easeInOut(duration: 0.3), value: isLogCollapsed)
            }
        }
        .sheet(item: $viewModel.activeHPAction) { action in
            if let index = participants.firstIndex(where: { $0.combatant.id == action.participantId }) {
                let participant = participants[index]
                HPChangeView(participant: participant, type: action.type) { amount in
                    viewModel.applyHPChange(
                        to: &participants,
                        index: index,
                        amount: amount,
                        type: action.type,
                        round: round,
                        combatLog: &combatLog
                    )
                    viewModel.activeHPAction = nil
                }
            }
        }
    }
} 