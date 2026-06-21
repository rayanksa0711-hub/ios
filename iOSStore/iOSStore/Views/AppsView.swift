//
//  AppsView.swift
//  iOSStore
//

import SwiftUI

struct AppsView: View {
    @EnvironmentObject var storeVM: StoreViewModel

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
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
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle(NSLocalizedString("Apps", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: String.self) { id in
                if let item = storeVM.item(withID: id) {
                    AppDetailView(item: item)
                }
            }
            .overlay {
                if storeVM.apps.isEmpty && !storeVM.isLoading {
                    emptyStateView
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "apps.iphone")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.appTextSecondary)

            Text(NSLocalizedString("No apps available", comment: ""))
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundColor(.appTextSecondary)
        }
    }
}

struct AppsView_Previews: PreviewProvider {
    static var previews: some View {
        AppsView()
            .environmentObject(StoreViewModel.preview)
    }
}
