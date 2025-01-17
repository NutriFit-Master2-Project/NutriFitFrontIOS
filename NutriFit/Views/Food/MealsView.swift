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
    
    let dateToday: String = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: Date())
        }()

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
                    List {
                        ForEach(meals) { meal in
                            HStack {
                                // Image du repas
                                if let url = URL(string: meal.image_url) {
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
                                    HStack(){
                                        Text("\(meal.quantity) g ou ml   - ")
                                            .font(.subheadline)
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
                    .shadow(radius: 5)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Mes Repas")
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
        
        let urlString = "https://nutrifitbackend-2v4o.onrender.com/api/daily_entries/\(userId)/entries/\(date)/meals"
        
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
        
        let urlString = "https://nutrifitbackend-2v4o.onrender.com/api/daily_entries/\(userId)/entries/\(date)/meals/\(mealToDelete.id)"
        
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
}
