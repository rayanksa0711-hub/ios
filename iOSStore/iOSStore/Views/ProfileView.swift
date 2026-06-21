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
                            .foregroundStyle(.appAccent, .appAccent.opacity(0.15))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(NSLocalizedString("LOGIC STORE", comment: ""))
                                .font(.system(size: 18, weight: .semibold, design: .default))
                                .foregroundColor(.appTextPrimary)

                            Text(NSLocalizedString("Premium Distribution", comment: ""))
                                .font(.system(size: 13, weight: .regular, design: .default))
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.appCardBackground)
                }

                Section(header: Text(NSLocalizedString("Catalog", comment: "")).foregroundColor(.appTextSecondary)) {
                    LabeledContent(
                        NSLocalizedString("Total Items", comment: ""),
                        value: "\(storeVM.items.count)"
                    )
                    .foregroundColor(.appTextPrimary)
                    LabeledContent(
                        NSLocalizedString("Games", comment: ""),
                        value: "\(storeVM.games.count)"
                    )
                    .foregroundColor(.appTextPrimary)
                    LabeledContent(
                        NSLocalizedString("Apps", comment: ""),
                        value: "\(storeVM.apps.count)"
                    )
                    .foregroundColor(.appTextPrimary)
                }
                .listRowBackground(Color.appCardBackground)

                Section(header: Text(NSLocalizedString("Actions", comment: "")).foregroundColor(.appTextSecondary)) {
                    Button(action: {
                        Task { await storeVM.loadCatalog() }
                    }) {
                        HStack {
                            Text(NSLocalizedString("Refresh Catalog", comment: ""))
                                .foregroundColor(.appTextPrimary)
                            Spacer()
                            if storeVM.isLoading {
                                ProgressView()
                                    .tint(.appAccent)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.appAccent)
                            }
                        }
                    }
                    .disabled(storeVM.isLoading)
                }
                .listRowBackground(Color.appCardBackground)

                Section(header: Text(NSLocalizedString("Installation Notes", comment: "")).foregroundColor(.appTextSecondary)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("ota_note_line1", comment: ""))
                        Text(NSLocalizedString("ota_note_line2", comment: ""))
                    }
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.appTextSecondary)
                }
                .listRowBackground(Color.appCardBackground)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle(NSLocalizedString("Profile", comment: ""))
            .tint(.appAccent)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(StoreViewModel.preview)
    }
}
