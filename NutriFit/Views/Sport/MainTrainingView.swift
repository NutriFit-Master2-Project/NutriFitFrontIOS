//
//  MainTrainingView.swift
//  NutriFit
//
//  Created by Maxence Walter on 16/01/2025.
//

import SwiftUI

struct MainTrainingView: View {
    @State private var objective: String = ""
    @State private var trainings: [TrainingProgram] = []
    @State private var errorMessage: String? = nil
    @State private var selectedTraining: TrainingProgram? = nil

    var body: some View {
        ZStack {
            Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
                .ignoresSafeArea()
            VStack {
                if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("Mes Entraînements")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    List(trainings) { training in
                        Button(action: {
                            selectedTraining = training
                        }) {
                            HStack {
                                Image(training.name)
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                VStack(alignment: .leading) {
                                    Text(training.name)
                                        .font(.headline)
                                    Text(training.description)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .listRowBackground(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .onAppear {
                fetchUserObjectiveAndTrainings()
            }
            .sheet(item: $selectedTraining) { training in
                DetailsTrainingView(training: training)
            }
        }
    }

    func fetchUserObjectiveAndTrainings() {
        fetchUserObjective { result in
            switch result {
            case .success(let fetchedObjective):
                self.objective = fetchedObjective
                fetchTrainingsByType(type: fetchedObjective)
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func fetchUserObjective(completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let userId = UserDefaults.standard.string(forKey: "userId") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token ou ID utilisateur manquant."])))
            return
        }

        let urlString = "https://nutrifitbackend-2v4o.onrender.com/api/user-info/\(userId)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "URL invalide."])))
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

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Aucune donnée reçue."])))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let objective = json["objective"] as? String {
                    completion(.success(objective))
                } else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Le champ 'objective' est introuvable."])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchTrainingsByType(type: String) {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            self.errorMessage = "Token d'authentification manquant."
            return
        }

        let urlString = "https://nutrifitbackend-2v4o.onrender.com/api/trainings/type/\(type)"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "URL invalide."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "auth-token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Erreur de requête : \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Aucune donnée reçue."
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let decodedTrainings = try decoder.decode([TrainingProgram].self, from: data)

                DispatchQueue.main.async {
                    self.trainings = decodedTrainings
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Erreur de parsing JSON : \(error.localizedDescription)"
                }
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
}

