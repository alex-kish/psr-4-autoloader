import SwiftUI
import Foundation
struct CombatParticipantRow: View {
    let participant: CombatParticipant
    let index: Int
    let isCurrentTurn: Bool
    let onDamage: () -> Void
    let onHeal: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text("\(index + 1)")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    if case .adventurer(let adventurer) = participant.combatant {
                        Image(systemName: adventurer.portrait)
                            .font(.title3)
                            .foregroundColor(.yellow)
                    }
                    Text(participant.combatant.name)
                        .font(.title3).bold()
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(participant.combatant.currentHP)/\(participant.combatant.maxHP)")
                            .bold()
                    }
                    .font(.title3)
                    
                    Spacer()
                    
                    if !participant.combatant.isAlive {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("DEAD")
                        }
                        .font(.title3)
                        .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "shield.fill")
                            .foregroundColor(.secondary)
                        Text("\(participant.combatant.armorClass)")
                            .bold()
                    }
                    .font(.title3)
                    .help("Armor Class")
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                        Text("\(participant.totalInitiative)")
                            .bold()
                    }
                    .font(.title3)
                    .help("Initiative")
                }
                .font(.subheadline)

                HStack {
                    Button(action: onDamage) {
                        Label("Damage", systemImage: "bolt.fill")
                    }
                    .disabled(!participant.combatant.isAlive)
                    
                    Button(action: onHeal) {
                        Label("Heal", systemImage: "cross.fill")
                    }
                    
                    Spacer()
                    
                    Button(action: onRemove) {
                        Label("Remove", systemImage: "trash.fill")
                    }
                    .foregroundColor(.red)
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal)
        .background(isCurrentTurn ? Color.yellow.opacity(0.3) : Color.clear)
        .cornerRadius(8)
    }
}
struct CombatLogView: View {
    let combatLog: [CombatLogEntry]
    @Binding var isCollapsed: Bool
    @State private var isHovering = false
    
    private static let numberRegex = try! NSRegularExpression(pattern: "\\d+")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if isCollapsed {
                    Image(systemName: "doc.text")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .help("Combat Log")
                } else {
                    Text("Combat Log")
                        .font(.headline)
                }
                
                Spacer()
                
                Image(systemName: isCollapsed ? "chevron.left" : "chevron.right")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(isHovering ? Color.gray.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isCollapsed.toggle()
                }
            }
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovering = hovering
                }
            }
            .help(isCollapsed ? "Expand Combat Log" : "Collapse Combat Log")
            
            if !isCollapsed {
                Divider()
                
                if combatLog.isEmpty {
                    Text("No actions yet")
                        .foregroundColor(.secondary)
                        .italic()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    GeometryReader { geo in
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 8) {
                                    ForEach(combatLog) { entry in
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text("Round \(entry.round)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                                Text(entry.timestamp, style: .time)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Text(formatLogEntry(entry))
                                                .font(.body)
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                        .id(entry.id)
                                    }
                                    
                                    Color.clear
                                        .frame(width: 0, height: 0)
                                        .id("bottom_anchor")
                                }
                                .padding(.top)
                                .padding(.horizontal)
                                .frame(minHeight: geo.size.height, alignment: .bottom)
                            }
                            .onAppear {
                                if !combatLog.isEmpty {
                                    proxy.scrollTo("bottom_anchor", anchor: .bottom)
                                }
                            }
                            .onChange(of: combatLog.count) { _, _ in
                                if !isCollapsed {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        proxy.scrollTo("bottom_anchor", anchor: .bottom)
                                    }
                                }
                            }
                            .onChange(of: isCollapsed) { _, newValue in
                                if !newValue && !combatLog.isEmpty {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        proxy.scrollTo("bottom_anchor", anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color.gray.opacity(0.05))
    }
    
    private func formatLogEntry(_ entry: CombatLogEntry) -> AttributedString {
        var attributedString = AttributedString(entry.description)

        if !entry.actor.isEmpty, let range = attributedString.range(of: entry.actor) {
            attributedString[range].font = .body.bold()
        }
        
        let description = entry.description
        let range = NSRange(description.startIndex..<description.endIndex, in: description)
        
        Self.numberRegex.enumerateMatches(in: description, options: [], range: range) { match, _, _ in
            guard let matchRange = match?.range else { return }
            if let swiftRange = Range(matchRange, in: description) {
                guard let lowerBound = AttributedString.Index(swiftRange.lowerBound, within: attributedString),
                      let upperBound = AttributedString.Index(swiftRange.upperBound, within: attributedString) else {
                    return
                }
                let attrRange = lowerBound..<upperBound
                attributedString[attrRange].font = .body.bold()
            }
        }
        
        return attributedString
    }
}
struct CombatControlsView: View {
    let round: Int
    let currentTurnIndex: Int
    let canGoPrevious: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Round: \(round)")
                    .font(.headline)
                Text("Turn: \(currentTurnIndex + 1)")
                    .font(.headline)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onPrevious) {
                    Label("Previous", systemImage: "backward.fill")
                }
                .disabled(!canGoPrevious)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.orange)

                Button(action: onNext) {
                    Label("Next", systemImage: "forward.fill")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.05))
    }
} 