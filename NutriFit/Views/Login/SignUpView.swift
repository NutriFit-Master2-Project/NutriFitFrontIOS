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
    @State private var isLoading: Bool = false
    @State private var isAccCreate: Bool = false
    
    // Page d'inscription
    var body: some View {
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

            }
            .padding(.bottom, 700)
            .padding(.top, 150)
            
            VStack {
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
                
                // Button S'inscrire
                Button(action: {
                    SignUp(name: name, email: email, password: password)
                }) {
                    Text("S'inscrire")
                        .font(.headline)
                        .foregroundColor(Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255))
                        .frame(width: 200, height: 40)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.top, 50)
            }
            .padding(.horizontal, 20)
            .padding(.top, 100)
            .navigationDestination(isPresented: $isAccCreate) { SignInView() }
            
            if isLoading {
                ProgressView("Création du compte...")
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
                    }.padding(.top, 30)
            }
        }
    }
    
    // Fonction pour inscrire l'user
    func SignUp(name : String, email: String, password: String) {
        guard let url = URL(string: "https://nutri-fit-back-576739684905.europe-west1.run.app/api/auth/sign-up") else {
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

        isLoading = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            isLoading = false
            if let error = error {
                print("Erreur lors de l'envoi de la requête : \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            
                            if httpResponse.statusCode == 200 {
                                toastText = "Inscription réussie"
                                showToastMessage()
                                isAccCreate = true
                            } else {
                                if let message = responseJSON["message"] as? String {
                                    toastText = "Erreur d'inscription : \(message)"
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
    
    // Fonction pour afficher le message "Toast"
    func showToastMessage() {
        withAnimation {
            showToast = true
        }
    }
}


