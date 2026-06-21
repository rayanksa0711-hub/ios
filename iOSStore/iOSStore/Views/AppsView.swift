//
//  AppsView.swift
//  iOSStore
//

import SwiftUI

struct AppsView: View {
    @EnvironmentObject var storeVM: StoreViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(storeVM.apps) { item in
                        NavigationLink(value: item.id) {
                            StoreItemCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .appBackground()
            .navigationDestination(for: String.self) { id in
                if let item = storeVM.item(withID: id) {
                    AppDetailView(item: item)
                }
            }
            .navigationTitle(NSLocalizedString("Apps", comment: ""))
            .overlay {
                if storeVM.apps.isEmpty && !storeVM.isLoading {
                    emptyStateView
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "apps.iphone")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(.secondary)

            Text(NSLocalizedString("No apps available", comment: ""))
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundColor(.secondary)
        }
    }
}

struct AppsView_Previews: PreviewProvider {
    static var previews: some View {
        AppsView()
            .environmentObject(StoreViewModel.preview)
    }
}
