//
//  SignInView.swift
//  NutriFit
//
//  Created by Maxence Walter on 17/09/2024.
//

import SwiftUI

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showToast: Bool = false
    @State private var toastText: String = ""
    @State private var isLoading: Bool = false
    @State private var isFirstConnection: Bool = false
    @State private var isNotFirstConnection: Bool = false

    // Page de Connexion
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
                
                
                // Title Connexion
                Text("Connexion")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
            }
            .padding(.bottom, 600)
            .padding(.top, 150)
            
            VStack {
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
                
                Button(action: {
                    SignIn(email: email, password: password)
                }) {
                    Text("Se connecter")
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
            .navigationDestination(isPresented: $isFirstConnection) { MainApp(isFirstConnection: $isFirstConnection) }
            .navigationDestination(isPresented: $isNotFirstConnection) { MainApp(isFirstConnection: $isFirstConnection) }
            
            if isLoading {
                ProgressView("Connexion...")
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
    
    // Fonction pour vérifier les informations de connexion
    func SignIn(email: String, password: String) {
        guard let url = URL(string: "https://nutrifitbackend-2v4o.onrender.com/api/auth/sign-in") else {
            print("SignIn - URL invalide")
            return
        }

        let parameters: [String: String] = ["email": email, "password": password]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("SignIn - Erreur de conversion des données en JSON")
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
                print("SignIn - Erreur lors de l'envoi de la requête : \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        
                        if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           
                           let token = responseJSON["token"] as? String {
                            UserDefaults.standard.set(token, forKey: "authToken")
                            if let decodedPayload = decodeJWT(token: token),
                               let userId = decodedPayload["userId"] as? String {
                                UserDefaults.standard.set(userId, forKey: "userId")
                                fetchUserInfo(userId: userId) { jsonResponse in
                                    if let apiResponse = jsonResponse {
                                        if checkFirstConnection(apiResponse: apiResponse) {
                                            isFirstConnection = true
                                        } else {
                                            isNotFirstConnection = true
                                        }
                                    }
                                }
                                toastText = "Connexion réussie"
                                showToastMessage()
                            }
                        }
                    } else {
                        print("SignIn - Échec de la connexion")
                        toastText = "Échec de la connexion"
                        showToastMessage()
                    }
                } catch {
                    print("SignIn - Erreur de décodage de la réponse : \(error)")
                }
            }
        }.resume()
    }
    
    // Fonction pour afficher un message "Toast"
    func showToastMessage() {
        withAnimation {
            showToast = true
        }
    }
    
    // Fonction pour la création du token de l'user
    func decodeJWT(token: String) -> [String: Any]? {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else {
            print("decodeJWT - Le token JWT est invalide")
            return nil
        }
        
        let payloadSegment = String(segments[1])
        
        var base64Payload = payloadSegment
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        while base64Payload.count % 4 != 0 {
            base64Payload += "="
        }
        
        guard let decodedData = Data(base64Encoded: base64Payload),
              let decodedPayload = String(data: decodedData, encoding: .utf8) else {
            print("decodeJWT - Échec du décodage du payload")
            return nil
        }

        guard let data = decodedPayload.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let payload = jsonObject as? [String: Any] else {
            print("decodeJWT - Échec de la conversion en JSON")
            return nil
        }
        return payload
    }
    
    // Fonction pour récupérer les données personelles de l'user
    func fetchUserInfo(userId: String, completion: @escaping ([String: Any]?) -> Void) {
        let urlString = "https://nutrifitbackend-2v4o.onrender.com/api/user-info/\(userId)"
        guard let url = URL(string: urlString) else {
            print("fetchUserInfo - URL invalide")
            completion(nil)
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("fetchUserInfo - Aucun token trouvé")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "auth-token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("fetchUserInfo - Erreur lors de la requête user-info : \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        completion(jsonResponse)
                    }
                } catch {
                    print("fetchUserInfo - Erreur de décodage de la réponse : \(error)")
                    completion(nil)
                    return
                }
            }
        }.resume()
    }
    
    // Fcontion pour vérifier si l'user se connecte pour la première fois
    func checkFirstConnection(apiResponse: [String: Any]) -> Bool {
        if apiResponse["activites"] is String {
            return false
        } else {
            return true
        }
    }
}

