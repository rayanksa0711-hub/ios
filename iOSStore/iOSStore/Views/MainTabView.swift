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
                    Label(NSLocalizedString("Home", comment: ""), systemImage: "house.fill")
                }
                .tag(0)

            AppsView()
                .tabItem {
                    Label(NSLocalizedString("Apps", comment: ""), systemImage: "square.grid.2x2.fill")
                }
                .tag(1)

            GamesView()
                .tabItem {
                    Label(NSLocalizedString("Games", comment: ""), systemImage: "gamecontroller.fill")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label(NSLocalizedString("Profile", comment: ""), systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.appAccent)
        .themedTabBar()
        .preferredColorScheme(.dark)
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
