//
//  ContentView.swift
//  TRPG Encounter
//
//  Created by Aleksei Kishinskii on 15. 6. 2025..
//

import SwiftUI
import SwiftData

struct CampaignsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Campaign.sortOrder) private var campaigns: [Campaign]
    
    @State private var selectedCampaign: Campaign?
    @State private var campaignToDelete: Campaign?
    @State private var detailPath = NavigationPath()

    var body: some View {
        NavigationSplitView {
            VStack {
                Text("Campaigns")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                Button(action: addCampaign) {
                    Label("Add New Campaign", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.borderedProminent)
                .padding([.horizontal, .bottom])

                List(selection: $selectedCampaign) {
                    ForEach(campaigns) { campaign in
                        HStack {
                            Text(campaign.name)
                            Spacer()
                            Button {
                                campaignToDelete = campaign
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                        .contentShape(Rectangle()) // Make the whole row tappable
                        .tag(campaign)
                    }
                    .onMove(perform: moveCampaigns)
                }
            }
            .navigationSplitViewColumnWidth(min: 250, ideal: 300)
            .alert("Delete Campaign?", isPresented: .init(get: { campaignToDelete != nil }, set: { if !$0 { campaignToDelete = nil } }), presenting: campaignToDelete) { campaign in
                Button("Delete", role: .destructive) {
                    deleteCampaign(campaign)
                }
            } message: { campaign in
                Text("Are you sure you want to delete \"\(campaign.name)\"? This action cannot be undone.")
            }
        } detail: {
            if let selectedCampaign {
                NavigationStack(path: $detailPath) {
                    CampaignDetailView(campaign: selectedCampaign)
                }
            } else {
                Text("Select a campaign")
                    .font(.title)
            }
        }
        .onChange(of: selectedCampaign) {
            detailPath.removeLast(detailPath.count)
        }
    }

    private func addCampaign() {
        withAnimation {
            let newCampaign = Campaign(name: "New Campaign \(campaigns.count + 1)")
            newCampaign.sortOrder = (campaigns.map(\.sortOrder).max() ?? -1) + 1
            modelContext.insert(newCampaign)
        }
    }

    private func deleteCampaign(_ campaign: Campaign) {
        withAnimation {
            if campaign.id == selectedCampaign?.id {
                selectedCampaign = nil
            }
            modelContext.delete(campaign)
            campaignToDelete = nil
        }
    }
    
    private func moveCampaigns(from source: IndexSet, to destination: Int) {
        var orderedCampaigns = campaigns
        orderedCampaigns.move(fromOffsets: source, toOffset: destination)
        
        for (index, campaign) in orderedCampaigns.enumerated() {
            campaign.sortOrder = index
        }
    }
}

#Preview {
    CampaignsView()
        .modelContainer(for: Campaign.self, inMemory: true)
}
