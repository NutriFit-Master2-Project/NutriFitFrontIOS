//
//  DashBoard.swift
//  NutriFit
//
//  Created by Maxence Walter on 16/10/2024.
//

import SwiftUI

struct DashBoardView: View {
    @State private var isLogout: Bool = false
    @State private var isFirstConnection: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
                    .ignoresSafeArea()
                
                VStack {
                    Image("Icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    Text("DashBoard")
                        .font(.largeTitle)
                        .padding(.bottom, 50)
                    
                    Button(action: {
                        logout()
                    }) {
                        Text("Se déconnecter")
                            .font(.headline)
                            .foregroundColor(Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255))
                            .frame(width: 200, height: 50)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: DataUserView(isFirstConnection: $isFirstConnection)) {
                        Image("IconSetting")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                }
            }
            .navigationDestination(isPresented: $isLogout) { HomeView().navigationBarBackButtonHidden(true) }
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        isLogout = true
    }
}
