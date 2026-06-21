//
//  MainTabView.swift
//  iOSStore
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var storeVM: StoreViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(NSLocalizedString("Home", comment: ""), systemImage: "square.grid.2x2.fill")
                }
                .tag(0)

            GamesView()
                .tabItem {
                    Label(NSLocalizedString("Games", comment: ""), systemImage: "gamecontroller.fill")
                }
                .tag(1)

            AppsView()
                .tabItem {
                    Label(NSLocalizedString("Apps", comment: ""), systemImage: "apps.iphone")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label(NSLocalizedString("Updates", comment: ""), systemImage: "arrow.clockwise.circle.fill")
                }
                .tag(3)
        }
        .tint(.blue)
        .frostedTabBar()
        .task {
            if storeVM.items.isEmpty {
                await storeVM.loadCatalog()
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(StoreViewModel.preview)
    }
}
