//
//  DashBoardView.swift
//  NutriFit
//
//  Created by Maxence Walter on 16/10/2024.
//

import SwiftUI
import HealthKit
import Foundation

struct DashBoardView: View {
    @State private var isLogout: Bool = false
    @State private var isFirstConnection: Bool = false
    @State private var viewScanBarcode: Bool = false
    @State private var caloriesUserMax: Double = 0
    @State private var caloriesUsed: Double = 0
    @State private var stepCount: Double = 0
    @State private var stepDiff: Double = 0
    @State private var caloriesBurned: Double = 0
    @State private var caloriesBurnMax: Double = 2000
    
    let healthStore = HKHealthStore()
    
    var caloriesStep: Double { stepCount * 0.05 }
    
    var caloriesRemainingMeal: Double { max(0, caloriesUserMax - caloriesUsed) }
    var caloriesRemainingBurn: Double { max(0, caloriesBurnMax - caloriesBurned) }
    
    var progressCaloriesUsed: CGFloat { CGFloat(max(0, min(1, 1 - (caloriesRemainingMeal / caloriesUserMax)))) }
    var progressCaloriesBurn: CGFloat { CGFloat(max(0, min(1, 1 - (caloriesRemainingBurn / caloriesBurnMax)))) }
    
    let dateToday: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }()
    
    // Page du tableau de bord
    var body: some View {
        ZStack {
            Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
                .ignoresSafeArea()
            
            VStack() {
                ScrollView {
                    VStack(alignment: .center) {
                        
                        // Logo Nutrifit
                        HStack {
                            VStack {
                                Image("Icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                
                                Text("Aujourd'hui")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 20)
                        
                        // Zone calories de la journée
                        VStack {
                            ZStack {
                                
                                NavigationLink(destination: MealsView()) {
                                    Image(systemName: "fork.knife")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 25))
                                }
                                .padding(.trailing, 290)
                                .padding(.bottom, 140)
                                
                                NavigationLink(destination: CalendarView()) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 30))
                                }
                                .padding(.leading, 290)
                                .padding(.bottom, 140)
                                
                                Circle()
                                    .trim(from: 0.0, to: 0.5)
                                    .stroke(
                                        Color.gray.opacity(0.2),
                                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                    )
                                    .frame(width: 300, height: 150)
                                    .rotationEffect(.degrees(180))
                                
                                Circle()
                                    .trim(from: 0.0, to: progressCaloriesUsed * 0.5)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.red, .yellow, .green]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                    )
                                    .frame(width: 300, height: 150)
                                    .rotationEffect(.degrees(180))
                                
                                VStack {
                                    Text("\(Int(caloriesUsed))")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Calories consommées")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                                
                                HStack() {
                                    Image("IconFire")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(Int(caloriesRemainingMeal)) Cal")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("Calories restantes")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.top, 170)
                            }
                        }
                        .padding(.bottom, 20)
                        .frame(width: 370)
                        .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 0.2))
                        .shadow(radius: 5)
                        .padding(.bottom, -10)
                        
                        // Zone Pas de la journée
                        VStack(alignment: .leading) {
                            HStack {
                                Image("IconStep")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                
                                VStack(alignment: .leading) {
                                    Text("\(Int(stepCount)) Pas")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Nombre de pas")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            HStack {
                                Image("IconWinner")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                
                                VStack(alignment: .leading) {
                                    Text("\(Int(caloriesStep)) Cal")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Gain en calories")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding([.top, .bottom], 10)
                        .frame(width: 370)
                        .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 0.2))
                        .shadow(radius: 5)
                        .padding()
                        
                        // Zone calories brulées
                        VStack{
                            ZStack {
                                Circle()
                                    .trim(from: 0.0, to: 0.5)
                                    .stroke(
                                        Color.gray.opacity(0.2),
                                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                    )
                                    .frame(width: 300, height: 150)
                                    .rotationEffect(.degrees(180))
                                
                                Circle()
                                    .trim(from: 0.0, to: progressCaloriesBurn * 0.5)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.red, .purple, .blue, .cyan]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                    )
                                    .frame(width: 300, height: 150)
                                    .rotationEffect(.degrees(180))
                                
                                VStack {
                                    Text("\(Int(caloriesBurned))")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Calories brulées")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.top, 30)
                        .padding(.bottom, -30)
                        .frame(width: 370)
                        .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 0.2))
                        .shadow(radius: 5)
                        .padding(.top, -10)
                        .padding(.bottom, 60)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    logout()
                }) {
                    Image("IconLogout")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
        }
        .navigationTitle("Accueil")
        .navigationDestination(isPresented: $isLogout) { HomeView().navigationBarBackButtonHidden(true) }
        .onAppear {
            fetchCalories { result in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    print("Erreur : \(error.localizedDescription)")
                }
            }
            
            requestAuthorizationAppHealthStep { success, error in
                if success {
                    getStepCount { count in
                        DispatchQueue.main.async {
                            stepCount = count
                        }
                    }
                } else {
                    print("Erreur HealthKit : \(error?.localizedDescription ?? "Permission refusée")")
                }
            }
            
            fetchDailyEntry(date: dateToday) { result in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    print("Erreur : \(error.localizedDescription)")
                }
            }
            
            fetchAndCalculateCalories(date: dateToday) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let totalCalories):
                        self.caloriesUsed = totalCalories
                    case .failure(let error):
                        print("Erreur : \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // Fonction pour se déconnecter
    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        isLogout = true
    }
    
    // Fonction pour récupérer les informations utilisateur
    func fetchCalories(completion: @escaping (Result<Double, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let userId = UserDefaults.standard.string(forKey: "userId") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token ou ID utilisateur manquant."])))
            return
        }
        
        guard let url = URL(string: "https://nutrifitbackend-2v4o.onrender.com/api/user-info/\(userId)") else {
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
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
               let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let calories = jsonResponse["calories"] as? Double {
                            caloriesUserMax = calories
                        }
                        completion(.success(caloriesUserMax))
                    } else {
                        completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Réponse non valide."])))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Échec de la requête. Code HTTP : \(statusCode)"])))
            }
        }.resume()
    }
    
    // Fonction autorisation a utiliser l'application Health de IOS pour les pas
    func requestAuthorizationAppHealthStep(completion: @escaping (Bool, Error?) -> Void) {
        if HKHealthStore.isHealthDataAvailable() {
            let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let typesToRead: Set = [stepCountType]
            
            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
                completion(success, error)
            }
        } else {
            completion(false, nil)
        }
    }
    
    // Fonction pour récupérer le nombre de pas de la journée
    func getStepCount(completion: @escaping (Double) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        
        healthStore.execute(query)
    }
    
    // Fonction pour retourner les informations users d'aujourd'hui
    func fetchDailyEntry(date: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token non disponible"])))
            return
        }
        
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "UserId non disponible"])))
            return
        }
        
        guard let url = URL(string: "https://nutrifitbackend-2v4o.onrender.com/api/daily_entries/\(userId)/entries/\(date)") else {
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
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let caloriesBurn = json["caloriesBurn"] as? Double {
                                if let steps = json["steps"] as? Double {
                                    caloriesBurned = caloriesBurn
                                    stepDiff = stepCount - steps
                                    if(stepDiff == 0.0) {
                                        caloriesBurned = caloriesBurned
                                    } else {
                                        caloriesBurned = (caloriesBurned + (stepDiff * 0.05))
                                    }
                                }
                            }
                            let dataToUpdate: [String: Any] = [
                                "calories": caloriesUsed,
                                "caloriesBurn": Int(caloriesBurned),
                                "steps": stepCount
                            ]
                            updateDailyEntry(date: dateToday, data: dataToUpdate) { result in
                                switch result {
                                case .success(_):
                                    break
                                case .failure(let error):
                                    print("Erreur : \(error.localizedDescription)")
                                }
                            }
                            completion(.success(json))
                        } else {
                            completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Réponse non valide."])))
                        }
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
    
    // Fonction pour mettre à jour les données d'aujourd'hui
    func updateDailyEntry(date: String, data: [String: Any], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token non disponible"])))
            return
        }
        
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "userId non disponible"])))
            return
        }
        
        guard let url = URL(string: "https://nutrifitbackend-2v4o.onrender.com/api/daily_entries/\(userId)/entries/\(date)") else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "URL non valide"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "auth-token")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200, let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            completion(.success(json))
                        } else {
                            completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Réponse non valide."])))
                        }
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
    
    // Récupérer les calories des repas de la journée
    func fetchAndCalculateCalories(date: String, completion: @escaping (Result<Double, Error>) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Utilisateur non authentifié."])))
            return
        }

        let urlString = "https://nutrifitbackend-2v4o.onrender.com/api/daily_entries/\(userId)/entries/\(date)/meals"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "URL non valide."])))
            return
        }
        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "auth-token non disponible."])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(authToken, forHTTPHeaderField: "auth-token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                do {
                    let meals = try JSONDecoder().decode([Meal].self, from: data)
                    let totalCalories = meals.reduce(0) { $0 + $1.calories }
                    completion(.success(Double(totalCalories)))
                } catch {
                    completion(.failure(error))
                }
            } else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Erreur HTTP : \(statusCode)"])))
            }
        }.resume()
    }
}
