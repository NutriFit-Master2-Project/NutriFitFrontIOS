//
//  DayDetailView.swift
//  NutriFit
//
//  Created by Maxence Walter on 04/01/2025.
//

import SwiftUI

struct DayDetailView: View {
    let day: Date
    @State private var entry: DailyEntry? = nil
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var meals: [Meal] = []
    
    private var formattedDateAPI: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: day)
    }
    
    private var dateFr: String {
        let dateFormatterFr = DateFormatter()
        dateFormatterFr.locale = Locale(identifier: "fr_FR")
        dateFormatterFr.dateFormat = "dd-MM-yyyy"
        return dateFormatterFr.string(from: day)
    }

    // Page des informations utlisateur d'une journée
    var body: some View {
        ZStack {
            Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Chargement...")
            } else if errorMessage != nil {
                Text("Erreur : Aucune données pour ce jour")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if let entry = entry {
                ZStack {
                    VStack() {
                        VStack {
                            VStack {
                                // Date de la journée
                                VStack(alignment: .center) {
                                    Text("Détails du : ")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    
                                    Text("\(dateFr)")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                        .padding(.bottom, 20)
                                }
                                .padding()
                            }
                            
                            Spacer()
                                .frame(height: 50)
                            
                            // Information de l'user sur la journée
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "flame")
                                        .foregroundColor(.green)
                                        .font(.system(size: 25))
                                    
                                    Text("Calories : \(Int(entry.calories))")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                .padding(.bottom, 10)
                                .padding(.leading, 10)
                                
                                HStack {
                                    Image(systemName: "figure.run.treadmill")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 25))
                                    
                                    Text("Calories brûlées : \(Int(entry.caloriesBurn))")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                
                                HStack {
                                    Image("IconStep")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                    
                                    Text("Nombre de pas : \(Int(entry.steps))")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding([.bottom, .top], 5)
                            .frame(width: 370)
                            .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 0.2))
                            .shadow(radius: 5)

                            if meals.isEmpty {
                                Text("Aucun repas enregistré.")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        }
                        List(meals) { meal in
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
                        }
                        .shadow(radius: 5)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
        }
        .navigationTitle("Jour sélectionné")
        .onAppear {
            isLoading = true
            fetchDailyEntry(for: formattedDateAPI) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let entry):
                        self.entry = entry
                        self.fetchMeals(date: formattedDateAPI) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let meals):
                                    self.meals = meals
                                case .failure(let error):
                                    self.errorMessage = error.localizedDescription
                                }
                                self.isLoading = false
                            }
                        }
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                    }
                }
            }
        }
    }

    // Fonction pour retourner les informations users pour la date donnée
    func fetchDailyEntry(for date: String, completion: @escaping (Result<DailyEntry, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token non disponible"])))
            return
        }
        
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "UserId non disponible"])))
            return
        }

        guard let url = URL(string: "https://nutri-fit-back-576739684905.europe-west1.run.app/api/daily_entries/\(userId)/entries/\(date)") else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "URL non valide"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "auth-token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200, let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let entry = try decoder.decode(DailyEntry.self, from: data)
                        completion(.success(entry))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    let statusCode = httpResponse.statusCode
                    completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Erreur HTTP : \(statusCode)"])))
                }
            }
        }.resume()
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
}


