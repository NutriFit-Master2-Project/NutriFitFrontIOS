//
//  MainApp.swift
//  NutriFit
//
//  Created by Maxence Walter on 16/01/2025.
//

import SwiftUI

struct MainApp: View {
    @State private var selection = 3
    @Binding var isFirstConnection: Bool
    
    var body: some View {
        TabView(selection:$selection) {
            // View de la page Sport
            NavigationView {
                MainSportView()
                    .navigationTitle("Sport")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Sport", systemImage: "dumbbell")
            }
            .tag(1)
            
            // View de la page Frigo
            NavigationView {
                FridgeView()
                    .navigationTitle("Frigo")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Frigo", systemImage: "refrigerator")
            }
            .tag(2)
            
            // View de la page d'acceuil
            NavigationView {
                DashBoardView()
                    .navigationTitle("Acceuil")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Acceuil", systemImage: "house")
            }
            .tag(3)
            
            // View de la page du scanner code barre
            NavigationView {
                ScanBarCodeView()
                    .navigationTitle("Acceuil")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Scanner", systemImage: "barcode.viewfinder")
            }
            .tag(4)
            
            // View de la page données personelles
            NavigationView {
                DataUserView(isFirstConnection: $isFirstConnection)
                    .navigationTitle("Données personnelles")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Paramètres", systemImage: "gearshape")
            }
            .tag(5)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if isFirstConnection {
                selection = 5
            } else {
                selection = 3
            }
        }
    }
}
