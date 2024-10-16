//
//  ContentView.swift
//  NutriFit
//
//  Created by Maxence Walter on 16/09/2024.
//

import SwiftUI

struct HomeView: View {
    @State private var showToast: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
                    .ignoresSafeArea()
                
                // Contenu principal
                VStack {
                    // Logo
                    Image("Icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(.top, 10)
                    
                    // Title
                    Text("Bienvenue dans NutriFit")
                        .customTitle1()
                        .padding(.top, 20)

                    // Description
                    Text("Ton application de fitness et nutrition")
                        .customTitle2()
                        .padding(.bottom, 50)
                        .padding(.top, 5)
                        .multilineTextAlignment(.center)

                    // Sign In Button
                    NavigationLink(destination: SignInView()) {
                        Text("Se connecter")
                            .font(.headline)
                            .foregroundColor(Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255))
                            .frame(width: 200, height: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 100)
                    
                    HStack {
                        // Title inscription
                        Text("Vous n'avez pas de compte ?")
                            .customSmallText()
                        
                        // Sign Up Button
                        NavigationLink(destination: SignUpView()) {
                            Text("Inscrivez-vous")
                                .customSmallUnderlined()
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
}

func toastView(message: String) -> some View {
    VStack {
        Spacer()
        Text(message)
            .font(.headline)
            .padding()
            .background(Color.gray.opacity(0.4))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.bottom, 50)
    }
    .frame(maxWidth: .infinity)
    .transition(.opacity)
}


