//
//  SignUpView.swift
//  NutriFit
//
//  Created by Maxence Walter on 17/09/2024.
//

import SwiftUI

struct SignUpView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showToast: Bool = false
    @State private var toastText: String = "Toast Default"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
                    .ignoresSafeArea()
                
                VStack {
                    // Logo
                    Image("Icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    // Title Inscription
                    Text("Inscription")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                }.padding(.bottom, 600)
                
                VStack {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        HStack{
                            // Icon Person
                            Image("IconPerson")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                            
                            Spacer()
                                    .frame(width: 20)
                            
                            // Textfield Nom
                            TextField("Entrez votre nom", text: $name)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        
                        Spacer()
                            .frame(height: 40)
                        
                        HStack{
                            // Icon Email
                            Image("IconEmail")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                            
                            Spacer()
                                    .frame(width: 20)
                            
                            // Textfield Email
                            TextField("Entrez votre email", text: $email)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        
                        Spacer()
                            .frame(height: 40)
                        
                        HStack{
                            // Icon Password
                            Image("IconPassword")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                            
                            Spacer()
                                    .frame(width: 20)
                            
                            // Textfield Password
                            SecureField("Entrez votre mot de passe", text: $password)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 100)

                    // Button S'inscrire
                    Button(action: {
                        SignUp(name: name, email: email, password: password)
                    }) {
                        Text("S'inscrire")
                            .font(.headline)
                            .foregroundColor(Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255))
                            .frame(width: 200, height: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 70)
                }
                if showToast {
                    toastView(message: toastText)
                        .transition(.slide)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showToast = false
                                }
                            }
                        }
                }
            }
        }
    }
    
    func SignUp(name : String, email: String, password: String) {
        print(name)
        print(email)
        print(password)

        guard let url = URL(string: "https://nutrifitbackend-2v4o.onrender.com/api/auth/sign-up") else {
            print("URL invalide")
            return
        }

        let parameters: [String: String] = ["name" : name,"email": email, "password": password]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("Erreur de conversion des données en JSON")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        // Envoyer la requête via URLSession
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur lors de l'envoi de la requête : \(error.localizedDescription)")
                return
            }

            // Gérer les données de la réponse
            if let data = data {
                do {
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Statut HTTP : \(httpResponse.statusCode)")
                        
                        if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            print("Réponse de l'API : \(responseJSON)")
                            
                            // Vérifier les statuts de réussite ou d'échec
                            if httpResponse.statusCode == 200 {
                                toastText = "Inscription réussie"
                                showToastMessage()
                            } else {
                                if let message = responseJSON["message"] as? String {
                                    toastText = "Erreur de connexion : \(message)"
                                    showToastMessage()
                                }
                            }
                        }
                    }
                } catch {
                    print("Erreur de décodage de la réponse : \(error)")
                }
            }
        }.resume()
    }
    
    func showToastMessage() {
        withAnimation {
            showToast = true
        }
    }
}


