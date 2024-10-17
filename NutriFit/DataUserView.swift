//
//  DataUserView.swift
//  NutriFit
//
//  Created by Maxence Walter on 16/10/2024.
//

import SwiftUI

struct DataUserView: View {
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var gender: String = "Homme"
    @State private var activity: String = "Sédentaire"
    @State private var goal: String = "Perte de poids"
    @State private var isSaveUserInfo: Bool = false
    @State private var selectedDisplayActivity: String = ""
    @State private var selectedDisplayGoal: String = ""
    @Binding var isFirstConnection: Bool

    let genders = ["Homme", "Femme"]
    let activites = ["SEDENTARY", "ACTIVE", "SPORTIVE"]
    let goals = ["WEIGHTLOSS", "WEIGHTGAIN"]
    let displayActivites = ["Sédentaire", "Actif", "Sportif"]
    let displayGoals = ["Perte de poids", "Prise de masse"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
                    .ignoresSafeArea()
                
                ScrollView(.vertical) {
                    ZStack {
                        Rectangle()
                            .fill(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                            .frame(width: 370, height: 530)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .shadow(radius: 5)
                            .padding(.top, 80)
                        
                        VStack {
                            VStack {
                                // Logo
                                Image("Icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                
                                
                                // Title Connexion
                                Text("Données personnelles")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                            }
                            .padding(.bottom, 50)
                            
                            HStack {
                                // Icon Age
                                Image("IconCalendar")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                
                                Spacer()
                                    .frame(width: 20)
                                
                                // Textfield Age
                                TextField("Entrez votre âge", text: $age)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            
                            Spacer()
                                .frame(height: 40)
                            
                            HStack {
                                // Icon Poids
                                Image("IconPoids")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                
                                Spacer()
                                    .frame(width: 20)
                                
                                // Textfield Poids
                                TextField("Entrez votre poids en kg", text: $weight)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            
                            Spacer()
                                .frame(height: 40)
                            
                            HStack {
                                // Icon Size
                                Image("IconSize")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                
                                Spacer()
                                    .frame(width: 20)
                                
                                // Textfield Taille
                                TextField("Entrez votre taille en cm", text: $height)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            
                            Spacer()
                                .frame(height: 40)
                            
                            HStack {
                                // Icon Genre
                                Image("IconGenre")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                
                                Spacer()
                                    .frame(width: 20)
                                
                                // Sélecteur Genre
                                Picker("Sélectionnez votre genre", selection: $gender) {
                                    ForEach(genders, id: \.self) { gender in
                                        Text(gender)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color.clear)
                            }
                            
                            Spacer()
                                .frame(height: 40)
                            
                            HStack {
                                // Icon Activites
                                Image("IconActivites")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                
                                Spacer()
                                    .frame(width: 20)
                                
                                // Sélecteur Activité
                                Picker("Niveau d'activité", selection: $selectedDisplayActivity) {
                                    ForEach(displayActivites, id: \.self) { activity in
                                        Text(activity)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color.clear)
                                
                            }
                            
                            Spacer()
                                .frame(height: 40)
                            
                            HStack {
                                // Icon Objectif
                                Image("IconObjective")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                
                                Spacer()
                                    .frame(width: 20)
                                
                                // Sélecteur Objectif
                                Picker("Votre objectif", selection: $selectedDisplayGoal) {
                                    ForEach(displayGoals, id: \.self) { goal in
                                        Text(goal)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color.clear)
                            }
                            
                            // Bouton enregistrement
                            Button(action: {
                                saveUserInfo()
                            }) {
                                Text("Enregistrer")
                                    .font(.headline)
                                    .foregroundColor(Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255))
                                    .frame(width: 200, height: 50)
                                    .background(Color.white)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 70)
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 20)
                        .scrollTargetLayout()
                    }
                }
                .frame(height: 710)
                .contentMargins(10, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned)
                .onAppear {
                    if !isFirstConnection {
                        fetchUserInfo()
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Terminer") {
                        hideKeyboard()
                    }
                }
            }
            .navigationDestination(isPresented: $isSaveUserInfo) { DashBoardView() }
        }
    }
    
    // Fonction pour enregistrer les données de l'user
    func saveUserInfo() {
        // Récupérer les valeurs correspondantes à partir des affichages sélectionnés
        guard let selectedActivityIndex = displayActivites.firstIndex(of: selectedDisplayActivity),
              let selectedGoalIndex = displayGoals.firstIndex(of: selectedDisplayGoal) else {
            print("Erreur lors de la récupération des valeurs sélectionnées.")
            return
        }
        let selectedActivity = activites[selectedActivityIndex]
        let selectedGoal = goals[selectedGoalIndex]
        
        // Récupérer l'id  d'authentification depuis UserDefaults
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("userId manquant.")
            return
        }
        
        // Assurer que les champs ne sont pas vides
        guard let ageInt = Double(age), let weightDouble = Double(weight), let heightDouble = Double(height) else {
            print("Veuillez remplir tous les champs correctement.")
            return
        }
        
        // Créer le corps de la requête
        let userData: [String: Any] = [
            "id": userId,
            "age": ageInt,
            "weight": weightDouble,
            "size": heightDouble,
            "genre": gender == "Homme" ? false : true,
            "activites": selectedActivity,
            "objective": selectedGoal
        ]
        
        // Récupérer le token d'authentification depuis UserDefaults
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("Token d'authentification manquant.")
            return
        }
        
        // Créer l'URL
        guard let url = URL(string: "https://nutrifitbackend-2v4o.onrender.com/api/user-info") else {
            print("URL invalide.")
            return
        }
        
        // Configurer la requête
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "auth-token")
        
        // Convertir le corps en JSON
        guard let httpBody = try? JSONSerialization.data(withJSONObject: userData, options: []) else {
            print("Erreur de conversion des données.")
            return
        }
        request.httpBody = httpBody
        
        print(userId)
        print(token)
        print(userData)
        
        // Envoyer la requête via URLSession
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Erreur : \(error.localizedDescription)")
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Code de réponse HTTP : \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    isSaveUserInfo = true
                }
            } else {
                DispatchQueue.main.async {
                    print("Échec de la mise à jour des données.")
                }
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Réponse du serveur : \(responseString)")
            }
        }.resume()
    }
    
    // Fonction pour récupérer les informations utilisateur
    func fetchUserInfo() {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("Token ou ID utilisateur manquant.")
            return
        }

        guard let url = URL(string: "https://nutrifitbackend-2v4o.onrender.com/api/user-info/\(userId)") else {
            print("URL invalide.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "auth-token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur lors de la requête : \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
               let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            showInfoUser(apiResponse: jsonResponse)
                        }
                    }
                } catch {
                    print("Erreur lors du décodage de la réponse : \(error)")
                }
            } else {
                print("Échec de la requête.")
            }
        }.resume()
    }
    
    // Fonction pour afficher à l'user les données enregistrées
    func showInfoUser(apiResponse: [String: Any]) {
        if let ageValue = apiResponse["age"] as? Double {
            age = String(Int(ageValue))
        }
        
        if let weightValue = apiResponse["weight"] as? Double {
            weight = String(weightValue)
        }
        
        if let sizeValue = apiResponse["size"] as? Double {
            height = String(sizeValue)
        }
        
        if let genderValue = apiResponse["genre"] as? Bool {
            gender = genderValue ? "Femme" : "Homme"
        }
        
        if let activityValue = apiResponse["activites"] as? String {
            if let activityIndex = activites.firstIndex(of: activityValue) {
                selectedDisplayActivity = displayActivites[activityIndex]
            }
        }
        
        if let goalValue = apiResponse["objective"] as? String {
            if let goalIndex = goals.firstIndex(of: goalValue) {
                selectedDisplayGoal = displayGoals[goalIndex]
            }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
