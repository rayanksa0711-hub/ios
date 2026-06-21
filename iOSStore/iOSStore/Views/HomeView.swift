//
//  HomeView.swift
//  iOSStore
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var storeVM: StoreViewModel
    @State private var searchText = ""

    var filteredItems: [StoreItem] {
        if searchText.isEmpty { return storeVM.items }
        return storeVM.items.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.developer.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    searchBar
                    categoryPills

                    if !storeVM.featured.isEmpty {
                        featuredBanner
                    }

                    topAppsGrid
                    newAppsSection
                }
                .padding(.vertical, 16)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationDestination(for: String.self) { id in
                if let item = storeVM.item(withID: id) {
                    AppDetailView(item: item)
                }
            }
            .overlay {
                if storeVM.isLoading && storeVM.items.isEmpty {
                    ProgressView()
                        .tint(.appAccent)
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

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString("Discover", comment: ""))
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.appTextPrimary)

                Text(NSLocalizedString("Premium apps & games", comment: ""))
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.appTextSecondary)
            }

            Spacer()

            Button(action: {
                Task { await storeVM.loadCatalog() }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appAccent)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.appCardBackground)
                            .overlay(Circle().stroke(Color.appBorder, lineWidth: 1))
                    )
            }
            .disabled(storeVM.isLoading)
        }
        .padding(.horizontal, 16)
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.appTextSecondary)

            TextField(NSLocalizedString("Search in premium products...", comment: ""), text: $searchText)
                .foregroundColor(.appTextPrimary)

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }

    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                PillButton(title: NSLocalizedString("All", comment: ""), isSelected: true)
                PillButton(title: NSLocalizedString("Games", comment: ""), isSelected: false)
                PillButton(title: NSLocalizedString("Apps", comment: ""), isSelected: false)
                PillButton(title: NSLocalizedString("Updated", comment: ""), isSelected: false)
            }
            .padding(.horizontal, 16)
        }
    }

    private var featuredBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(NSLocalizedString("Featured", comment: ""))
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(.appTextPrimary)

                Spacer()

                Text(NSLocalizedString("See all", comment: ""))
                    .font(.system(size: 13, weight: .semibold, design: .default))
                    .foregroundColor(.appAccent)
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(storeVM.featured.prefix(5)) { item in
                        NavigationLink(value: item.id) {
                            FeaturedBannerCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var topAppsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("Top Apps", comment: ""))
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.appTextPrimary)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(storeVM.apps.prefix(8)) { item in
                        NavigationLink(value: item.id) {
                            GridAppCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var newAppsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("New & Updated", comment: ""))
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.appTextPrimary)
                .padding(.horizontal, 16)

            LazyVStack(spacing: 10) {
                ForEach(filteredItems.prefix(10)) { item in
                    NavigationLink(value: item.id) {
                        StoreItemCard(item: item)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

struct PillButton: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold, design: .default))
            .foregroundColor(isSelected ? .white : .appTextSecondary)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? LinearGradient.appAccentGradient : Color.appCardBackground)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.appBorder, lineWidth: 1)
            )
    }
}

struct FeaturedBannerCard: View {
    let item: StoreItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: item.iconURL) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.appSurface)
                        .overlay(ProgressView().tint(.appAccent))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.appSurface)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 300, height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.8), .clear]),
                startPoint: .bottom,
                endPoint: .top
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(.white)

                Text(item.developer)
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(16)
        }
        .frame(width: 300, height: 170)
    }
}

struct GridAppCard: View {
    let item: StoreItem

    var body: some View {
        VStack(spacing: 10) {
            AsyncImage(url: item.iconURL) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.appSurface)
                        .overlay(ProgressView().tint(.appAccent))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.appSurface)
                        .overlay(Image(systemName: "app").foregroundColor(.appTextSecondary))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)

            Text(item.name)
                .font(.system(size: 12, weight: .semibold, design: .default))
                .foregroundColor(.appTextPrimary)
                .lineLimit(1)
                .frame(width: 90)

            Text(item.formattedSize)
                .font(.system(size: 10, weight: .medium, design: .default))
                .foregroundColor(.appTextSecondary)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(StoreViewModel.preview)
    }
}
