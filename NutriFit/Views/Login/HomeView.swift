//
//  ContentView.swift
//  NutriFit
//
//  Created by Maxence Walter on 16/09/2024.
//

import SwiftUI

struct HomeView: View {
    @State private var showToast: Bool = false
    @State private var navigateToDashboard: Bool = false
    @State private var navigateToSignIn: Bool = false
    @State private var isFirstConnection: Bool = false
    init() {
        // Configuration de l'apparence de la barre de navigation
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 40 / 255, green: 40 / 255, blue: 40 / 255, alpha: 1)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
                    .ignoresSafeArea()
                
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
                    Button(action: {
                        checkIsAuth()
                    }) {
                        Text("Se connecter")
                            .font(.headline)
                            .foregroundColor(Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255))
                            .frame(width: 200, height: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 100)
                    .navigationDestination(isPresented: $navigateToDashboard) { MainApp(isFirstConnection: $isFirstConnection) }
                    .navigationDestination(isPresented: $navigateToSignIn) { SignInView() }
                    
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
    
    func checkIsAuth() {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("Token ou ID utilisateur manquant.")
            navigateToSignIn = true
            return
        }

        guard let url = URL(string: "https://nutrifitbackend-2v4o.onrender.com/api/user-info/\(userId)") else {
            print("URL invalide.")
            navigateToSignIn = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "auth-token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur lors de la requête : \(error.localizedDescription)")
                DispatchQueue.main.async {
                    navigateToSignIn = true
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    navigateToDashboard = true
                }
            } else {
                print("Échec de l'authentification. Réponse HTTP : \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                DispatchQueue.main.async {
                    navigateToSignIn = true
                }
            }
        }.resume()
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
            .padding(.bottom, 150)
    }
    .frame(maxWidth: .infinity)
    .transition(.opacity)
}
