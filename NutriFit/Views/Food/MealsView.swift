//
//  MealsView.swift
//  NutriFit
//
//  Created by Maxence Walter on 05/01/2025.
//

import SwiftUI

struct MealsView: View {
    @State private var meals: [Meal] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @State private var selectedMeal: Meal? = nil
    @State private var showingAddMealAlert = false
    @State private var newMealName: String = ""
    @State private var newMealQuantity: String = ""

    let dateToday: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }()

    // Page des repas de la journée
    var body: some View {
        ZStack {
            Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
                .ignoresSafeArea()
            VStack {
                if isLoading {
                    ProgressView("Chargement des repas...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.gray)
                        .padding()
                } else if meals.isEmpty {
                    Text("Aucun repas enregistré.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // Liste des repas de la journée
                    List {
                        Section(header: Text("Mes repas")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        ) {
                            ForEach(meals) { meal in
                                HStack {
                                    // Image du repas
                                    if meal.image_url == "plateIA" {
                                        // Afficher l'image locale
                                        Image("plateIA")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(5)
                                    } else if let url = URL(string: meal.image_url) {
                                        // Afficher l'image distante
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                                .cornerRadius(5)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                    
                                    // Info du repas
                                    VStack(alignment: .leading) {
                                        Text(meal.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        HStack {
                                            Text("\(meal.quantity) g ou ml")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            Text(" - ")
                                                .foregroundColor(.gray)
                                            Text("\(Int(meal.calories)) Cal")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .contentShape(Rectangle())
                                .foregroundColor(.clear)
                                .listRowBackground(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                                .padding(.vertical, 10)
                                .onTapGesture {
                                    selectedMeal = meal
                                }
                            }
                            .onDelete { offsets in
                                deleteMeal(date: dateToday, at: offsets)
                            }
                        }
                    }
                    .shadow(radius: 5)
                    .scrollContentBackground(.hidden)
                }

                Spacer()

                Button(action: {
                    showingAddMealAlert = true
                }) {
                    Text("Ajouter un repas")
                        .font(.headline)
                        .foregroundColor(Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255))
                        .frame(width: 180, height: 40)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding()
                // Fenetre pour ajouter un repas à la main (si pas de code barre produit)
                .sheet(isPresented: $showingAddMealAlert) {
                    VStack(spacing: 10) {
                        Text("Ajouter un repas")
                            .font(.headline)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        TextField("Nom du repas", text: $newMealName)
                            .padding([.top, .bottom, .leading], 5)
                            .keyboardType(.default)
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .padding(.bottom, 10)

                        TextField("Quantité (g ou ml)", text: $newMealQuantity)
                            .padding([.top, .bottom, .leading], 5)
                            .keyboardType(.numberPad)
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .padding(.bottom, 10)
                        HStack {
                            Button("Valider") {
                                infoMealIA()
                            }
                            .padding()
                            .font(.headline)
                            .foregroundColor(Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255))
                            .frame(width: 120, height: 40)
                            .background(Color.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .presentationDetents([.height(250)])
                }
            }
            .navigationTitle("Nutrition")
            .onAppear {
                fetchMeals(date: dateToday) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let meals):
                            self.meals = meals
                            self.isLoading = false
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                            self.isLoading = false
                        }
                    }
                }
            }
        }
    }

    // Fonction pour récupérer les repas d'une journée
    func fetchMeals(date: String, completion: @escaping (Result<[Meal], Error>) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Utilisateur non authentifié."])))
            return
        }

        let urlString = "https://nutri-fit-back-576739684905.europe-west1.run.app/api/daily_entries/\(userId)/entries/\(date)/meals"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "URL non valide"])))
            return
        }
        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "auth-token non disponible"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(authToken, forHTTPHeaderField: "auth-token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Données manquantes"])))
                    return
                }

                do {
                    let meals = try JSONDecoder().decode([Meal].self, from: data)
                    completion(.success(meals))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Erreur lors de la récupération des repas."])))
            }
        }.resume()
    }

    // Fonction pour supprimer un repas de la journée
    func deleteMeal(date: String, at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let mealToDelete = meals[index]

        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            self.errorMessage = "Utilisateur non authentifié."
            return
        }
        
        guard let mealId = mealToDelete.id else { return }

        let urlString = "https://nutri-fit-back-576739684905.europe-west1.run.app/api/daily_entries/\(userId)/entries/\(date)/meals/\(mealId)"
        

        guard let url = URL(string: urlString) else {
            self.errorMessage = "URL non valide."
            return
        }
        
        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            self.errorMessage = "auth-token non disponible."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue(authToken, forHTTPHeaderField: "auth-token")

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Erreur : \(error.localizedDescription)"
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.meals.remove(atOffsets: offsets)
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Erreur lors de la suppression du repas."
                }
            }
        }.resume()
    }

    // Fonction pour ajouter un repas avec l'IA
    func infoMealIA() {
        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            self.errorMessage = "auth-token non disponible."
            return
        }

        guard let quantity = Int(newMealQuantity) else {
            self.errorMessage = "Quantité invalide."
            return
        }

        let mealData: [String: Any] = [
            "Food": newMealName,
            "Quantity": quantity
        ]

        guard let url = URL(string: "https://nutri-fit-back-576739684905.europe-west1.run.app/api/calories-food") else {
            self.errorMessage = "URL non valide."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authToken, forHTTPHeaderField: "auth-token")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: mealData, options: [])
        } catch {
            self.errorMessage = "Erreur lors de la sérialisation des données."
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Erreur : \(error.localizedDescription)"
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Données manquantes."
                    }
                    return
                }

                do {
                    var newMeal = try JSONDecoder().decode(MealIA.self, from: data)
                    newMeal.image_url = "plateIA"
                    
                    saveMealIA(date: self.dateToday, meal: newMeal) { result in
                        switch result {
                        case .success(_):
                            self.fetchMeals(date: self.dateToday) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success(let meals):
                                        self.meals = meals
                                        self.showingAddMealAlert = false
                                        self.newMealName = ""
                                        self.newMealQuantity = ""
                                    case .failure(let error):
                                        self.errorMessage = "Erreur lors du rechargement des repas : \(error.localizedDescription)"
                                    }
                                }
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                self.errorMessage = "Erreur lors de l'enregistrement du repas : \(error.localizedDescription)"
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Erreur saisie incorrecte, Veuillez réessayer."
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Erreur saisie incorrecte, Veuillez réessayer."
                }
            }
        }.resume()
    }
    
    // Fonction pour enregistrer en base le repas généré par l'IA
    func saveMealIA(date: String, meal: MealIA, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Utilisateur non authentifié."])))
            return
        }

        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "auth-token non disponible."])))
            return
        }

        guard let url = URL(string: "https://nutri-fit-back-576739684905.europe-west1.run.app/api/daily_entries/\(userId)/entries/\(date)/meals") else {
            completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "URL invalide."])))
            return
        }

        let requestBody: [String: Any] = [
            "name": meal.name,
            "calories": meal.calories,
            "quantity": String(meal.quantity),
            "image_url": meal.image_url ?? ""
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(authToken, forHTTPHeaderField: "auth-token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "Erreur lors de l'encodage des données."])))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -5, userInfo: [NSLocalizedDescriptionKey: "Réponse du serveur non valide."])))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Erreur HTTP : \(httpResponse.statusCode)."])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -6, userInfo: [NSLocalizedDescriptionKey: "Aucune donnée reçue du serveur."])))
                return
            }

            do {
                struct ApiResponse: Decodable {
                    let message: String
                }

                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                completion(.success(apiResponse.message))
            } catch {
                completion(.failure(NSError(domain: "", code: -7, userInfo: [NSLocalizedDescriptionKey: "Erreur lors du décodage de la réponse."])))
            }
        }.resume()
    }
}
