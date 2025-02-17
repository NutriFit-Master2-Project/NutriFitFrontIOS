//
//  DetailsTrainingView.swift
//  NutriFit
//
//  Created by Maxence Walter on 20/01/2025.
//

import SwiftUI

struct DetailsTrainingView: View {
    let training: TrainingProgram

    let dateToday: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }()

    @State private var errorMessage: String? = nil
    @State private var isSuccess: Bool = false

    var body: some View {
        ZStack {
            Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
                .ignoresSafeArea()

            ScrollView(.vertical) {
                VStack {
                    Text(training.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    ForEach(training.exercises) { exercise in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(exercise.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 130, height: 100)
                                    .cornerRadius(8)
                                    .shadow(radius: 5)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.bottom, 4)

                                    Text(exercise.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "figure.strengthtraining.traditional")
                                        .foregroundColor(.green)
                                    Text("Muscles ciblés: \(exercise.muscles.joined(separator: ", "))")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }

                                HStack {
                                    Image(systemName: "repeat")
                                        .foregroundColor(.blue)
                                    Text("Séries: \(exercise.series)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)

                                    Image(systemName: "list.number")
                                        .foregroundColor(.blue)
                                    Text("Répétitions: \(exercise.repetitions)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)

                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.red)
                                    Text("Calories brûlées: \(exercise.calories)")
                                        .font(.footnote)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        )
                        .padding(.top, 20)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text("Erreur: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    }

                    if isSuccess {
                        Text("Séance validée avec succès!")
                            .foregroundColor(.green)
                            .padding()
                    }

                    // Bouton enregistrement
                    Button(action: {
                        validateSession()
                    }) {
                        Text("Valider la séance")
                            .font(.headline)
                            .foregroundColor(Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255))
                            .frame(width: 170, height: 40)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .padding([.top, .bottom], 30)
                }
            }
        }
        .navigationTitle("Exercices")
    }

    //Fonction pour calcul les calories de la séance et l'ajouter aux caloires brulées
    func validateSession() {
        let totalCalories = training.exercises.reduce(0) { sum, exercise in
            sum + exercise.calories
        }
        addCaloriesBurn(date: dateToday, caloriesBurnToAdd: totalCalories) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isSuccess = true
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isSuccess = false
                }
            }
        }
    }

    //Fonction pour ajouter des calories brulées
    func addCaloriesBurn(date: String, caloriesBurnToAdd: Int, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let userId = UserDefaults.standard.string(forKey: "userId") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token ou ID utilisateur manquant."])))
            return
        }

        let urlString = "https://nutrifitbackend-2v4o.onrender.com/api/daily_entries/\(userId)/entries/\(date)/add-calories-burn"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "URL invalide."])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "auth-token")

        let requestBody: [String: Any] = ["caloriesBurnToAdd": caloriesBurnToAdd]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Aucune donnée reçue."])))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Réponse inattendue."])))
                }
            } catch let jsonError {
                print("JSON parsing error: \(jsonError)")
                completion(.failure(jsonError))
            }
        }.resume()
    }

}


