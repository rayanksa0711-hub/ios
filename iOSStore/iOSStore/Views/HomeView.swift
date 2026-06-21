//
//  HomeView.swift
//  iOSStore
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var storeVM: StoreViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if !storeVM.featured.isEmpty {
                        featuredSection
                    }

                    categorySection(title: NSLocalizedString("New Games", comment: ""), items: storeVM.games.prefix(4))
                    categorySection(title: NSLocalizedString("New Apps", comment: ""), items: storeVM.apps.prefix(4))
                }
                .padding(.vertical, 16)
            }
            .appBackground()
            .navigationDestination(for: String.self) { id in
                if let item = storeVM.item(withID: id) {
                    AppDetailView(item: item)
                }
            }
            .navigationTitle(NSLocalizedString("Discover", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task { await storeVM.loadCatalog() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .imageScale(.medium)
                    }
                    .disabled(storeVM.isLoading)
                }
            }
            .overlay {
                if storeVM.isLoading && storeVM.items.isEmpty {
                    ProgressView()
                }
            }
            .alert(
                NSLocalizedString("Error", comment: ""),
                isPresented: .constant(storeVM.errorMessage != nil)
            ) {
                Button(NSLocalizedString("OK", comment: "")) {
                    storeVM.errorMessage = nil
                }
                Button(NSLocalizedString("Retry", comment: "")) {
                    storeVM.errorMessage = nil
                    Task { await storeVM.loadCatalog() }
                }
            } message: {
                Text(storeVM.errorMessage ?? "")
            }
        }
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("Featured", comment: ""))
                .font(.system(size: 22, weight: .bold, design: .default))
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(storeVM.featured) { item in
                        NavigationLink(value: item.id) {
                            FeaturedCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func categorySection(title: String, items: Array<StoreItem>.SubSequence) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .default))
                .padding(.horizontal, 16)

            LazyVStack(spacing: 10) {
                ForEach(Array(items)) { item in
                    NavigationLink(value: item.id) {
                        StoreItemCard(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Featured Card

struct FeaturedCard: View {
    let item: StoreItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: item.iconURL) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color(.tertiarySystemFill))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color(.tertiarySystemFill))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 260, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(.primary)

                Text(item.developer)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 260)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(StoreViewModel.preview)
    }
}
