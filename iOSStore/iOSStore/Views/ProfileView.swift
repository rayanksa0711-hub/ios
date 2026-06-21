//
//  ProfileView.swift
//  iOSStore
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var storeVM: StoreViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.blue, .blue.opacity(0.15))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(NSLocalizedString("iOS Store", comment: ""))
                                .font(.system(size: 18, weight: .semibold, design: .default))

                            Text(NSLocalizedString("Beta Distribution", comment: ""))
                                .font(.system(size: 13, weight: .regular, design: .default))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text(NSLocalizedString("Catalog", comment: ""))) {
                    LabeledContent(
                        NSLocalizedString("Total Items", comment: ""),
                        value: "\(storeVM.items.count)"
                    )
                    LabeledContent(
                        NSLocalizedString("Games", comment: ""),
                        value: "\(storeVM.games.count)"
                    )
                    LabeledContent(
                        NSLocalizedString("Apps", comment: ""),
                        value: "\(storeVM.apps.count)"
                    )
                }

                Section(header: Text(NSLocalizedString("Actions", comment: ""))) {
                    Button(action: {
                        Task { await storeVM.loadCatalog() }
                    }) {
                        HStack {
                            Text(NSLocalizedString("Refresh Catalog", comment: ""))
                            Spacer()
                            if storeVM.isLoading {
                                ProgressView()
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .disabled(storeVM.isLoading)
                }

                Section(header: Text(NSLocalizedString("Installation Notes", comment: ""))) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("ota_note_line1", comment: ""))
                        Text(NSLocalizedString("ota_note_line2", comment: ""))
                    }
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.secondary)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(NSLocalizedString("Profile", comment: ""))
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(StoreViewModel.preview)
    }
}
