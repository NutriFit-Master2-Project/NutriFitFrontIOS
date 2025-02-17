//
//  ProductScanView.swift
//  NutriFit
//
//  Created by Maxence Walter on 14/11/2024.
//
import SwiftUI

struct ProductScanView: View {
    let barCode: String
    @State private var product: Product? = nil
    @State private var errorMessage: String? = nil
    @State private var isSaving = false
    @State private var SuccessSaveProduct = false
    @State private var showChooseSave = false
    @State private var showQuantityInput = false
    @State private var quantityNumber = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isFirstConnection = false
    
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
                if let errorMessage = errorMessage {
                    Text("Erreur : \(errorMessage)")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                        .padding()
                } else if let product = product {
                    ScrollView(.vertical) {
                        VStack {
                            VStack(alignment: .leading, spacing: 15) {
                                // Image du produit
                                HStack {
                                    Spacer()
                                    if let url = URL(string: product.imageUrl) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                            //.frame(width: 300, height: 300)
                                                .cornerRadius(10)
                                                .shadow(radius: 5)
                                        } placeholder: {
                                            ProgressView("Chargement....")
                                        }
                                    }
                                    Spacer()
                                }
                                
                                // Nom du produit
                                HStack {
                                    Spacer()
                                    Text(product.productName)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.bottom, 5)
                                    Spacer()
                                }
                                
                                // Marque
                                Text("Marque : \(product.brands)")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                // Nutri-Score
                                Text("Nutri-Score : \(product.nutriscoreGrade.uppercased())")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(nutriScoreColor(for: product.nutriscoreGrade))
                                
                                // Ingrédients
                                Text("Ingrédients :")
                                    .font(.headline)
                                    .padding(.top, 10)
                                Text(product.ingredientsText)
                                    .font(.body)
                                    .lineLimit(nil)
                                    .padding(.bottom, 10)
                                
                                // Nutriments
                                Text("Nutriments :")
                                    .font(.headline)
                                    .padding(.top, 10)
                                ForEach(product.nutriments.asDictionary().keys.sorted(), id: \.self) { key in
                                    HStack {
                                        Text("\(key) :")
                                            .font(.body)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text(product.nutriments.asDictionary()[key] ?? "")
                                            .font(.body)
                                    }
                                }
                                
                                // Allergènes
                                if !product.allergens.isEmpty {
                                    Text("Allergènes :")
                                        .font(.headline)
                                        .padding(.top, 10)
                                        .foregroundColor(.red)
                                    Text(product.allergens.joined(separator: ", "))
                                        .font(.body)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                                    .shadow(radius: 5)
                            )
                        }
                        
                        // Bouton Ajouter à la liste du Frigo ou Repas du jour
                        Button("Enregistrer") {
                            showChooseSave = true
                        }
                        .font(.headline)
                        .foregroundColor(Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255))
                        .frame(width: 200, height: 40)
                        .background(Color.white)
                        .cornerRadius(10)
                        .disabled(isSaving)
                        .confirmationDialog(
                            "Choisissez l'enregistrement",
                            isPresented: $showChooseSave,
                            titleVisibility: .visible
                        ) {
                            Button("Mon frigo") {
                                saveProductFridge()
                            }
                            Button("Consommation du jour") {
                                showQuantityInput = true
                            }
                            Button("Annuler", role: .cancel) {
                                showChooseSave = false
                            }
                        }
                        .alert("Entrez la quantité (g ou ml)", isPresented: $showQuantityInput) {
                            TextField("Nombre", text: $quantityNumber)
                                .keyboardType(.numberPad)
                            Button("OK") {
                                saveProductConsumes(date: dateToday, product: product) { result in
                                    DispatchQueue.main.async {
                                        switch result {
                                        case .success(let message):
                                            alertMessage = message
                                        case .failure(let error):
                                            alertMessage = "Erreur : \(error.localizedDescription)"
                                        }
                                        showAlert = true
                                    }
                                }
                            }
                        }
                        
                        
                        // ProgressView affiché pendant l'enregistrement
                        if isSaving {
                            ProgressView("Enregistrement du produit...")
                                .padding()
                        }
                        
                        // Message d'erreur echec enregistrement
                        if let errorMessage = errorMessage {
                            Text("Erreur : \(errorMessage)")
                                .foregroundColor(.red)
                                .padding()
                        }
                }
                .frame(height: 710)
                .padding()
                } else {
                    ProgressView("Chargement du produit...")
                }
            }
        }
        .onAppear {
            fetchNutritionalInfo(productId: barCode) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedProduct):
                        product = fetchedProduct
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
        .navigationDestination(isPresented: $SuccessSaveProduct) { MainApp(isFirstConnection: $isFirstConnection) }
        .navigationTitle("Informations Produit")
    }
    
    func fetchNutritionalInfo(productId: String, completion: @escaping (Result<Product, Error>) -> Void) {
        let urlString = "https://nutrifitbackend-2v4o.onrender.com/api/nutrition/get-nutritional-info/\(productId)"
        
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
                if let data = data {
                    do {
                        // Utilisation de JSONSerialization
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            // Extraire les informations manuellement
                            if let productName = json["product_name"] as? String,
                               let ingredientsText = json["ingredients_text"] as? String,
                               let nutriscoreGrade = json["nutriscore_grade"] as? String,
                               let brands = json["brands"] as? String,
                               let categories = json["categories"] as? String,
                               let quantity = json["quantity"] as? String,
                               let labels = json["labels"] as? String,
                               let allergens = json["allergens"] as? [String],
                               let imageUrl = json["image_url"] as? String,
                               let nutrimentsDict = json["nutriments"] as? [String: Any] {
                                
                                // Convertir nutriments
                                let nutriments = Nutriments(
                                    energy: nutrimentsDict["energy"] as? Double ?? 0.0,
                                    energyKcal: nutrimentsDict["energy-kcal"] as? Double ?? 0.0,
                                    fat: nutrimentsDict["fat"] as? Double ?? 0.0,
                                    saturatedFat: nutrimentsDict["saturated-fat"] as? Double ?? 0.0,
                                    sugars: nutrimentsDict["sugars"] as? Double ?? 0.0,
                                    salt: nutrimentsDict["salt"] as? Double ?? 0.0,
                                    proteins: nutrimentsDict["proteins"] as? Double ?? 0.0
                                )
                                
                                // Créer le modèle `Product`
                                let product = Product(
                                    productName: productName,
                                    ingredientsText: ingredientsText,
                                    nutriments: nutriments,
                                    nutriscoreGrade: nutriscoreGrade,
                                    brands: brands,
                                    categories: categories,
                                    quantity: quantity,
                                    labels: labels,
                                    allergens: allergens,
                                    imageUrl: imageUrl
                                )
                                completion(.success(product))
                            } else {
                                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Données manquantes ou invalides"])))
                            }
                        }
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Données manquantes"])))
                }
            } else {
                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Produit inconnu ou non alimentaire"])))
            }
        }.resume()
    }
    
    func saveProductFridge() {
        isSaving = true
        guard let product = product else {
            errorMessage = "Aucun produit à enregistrer."
            return
        }

        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            errorMessage = "Utilisateur non authentifié."
            return
        }

        let urlString = "https://nutrifitbackend-2v4o.onrender.com/api/nutrition/save-product/\(userId)"

        guard let url = URL(string: urlString) else {
            errorMessage = "URL non valide."
            return
        }

        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            errorMessage = "auth-token non disponible."
            return
        }

        let body: [String: Any] = [
            "product_name": product.productName,
            "ingredients_text": product.ingredientsText,
            "nutriscore_grade": product.nutriscoreGrade,
            "brands": product.brands,
            "categories": product.categories,
            "quantity": product.quantity,
            "labels": product.labels,
            "allergens": product.allergens,
            "image_url": product.imageUrl,
            "nutriments": product.nutriments.asDictionaryBdd()
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue(authToken, forHTTPHeaderField: "auth-token")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    isSaving = false
                    if let error = error {
                        errorMessage = "Erreur réseau : \(error.localizedDescription)"
                        return
                    }

                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        errorMessage = nil
                        SuccessSaveProduct = true
                    } else {
                        errorMessage = "Erreur lors de l'ajout du produit."
                    }
                }
            }.resume()
        } catch {
            errorMessage = "Erreur lors de la création du corps de la requête : \(error.localizedDescription)"
        }
    }

    func saveProductConsumes(date: String, product: Product, completion: @escaping (Result<String, Error>) -> Void) {
        // Vérification des informations utilisateur
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Utilisateur non authentifié."])))
            return
        }
        
        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "auth-token non disponible."])))
            return
        }
        
        // Création de l'URL
        guard let url = URL(string: "https://nutrifitbackend-2v4o.onrender.com/api/daily_entries/\(userId)/entries/\(date)/meals") else {
            completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "URL invalide."])))
            return
        }
        
        // Calcul des calories consommées
        let caloriesEat = Double(product.nutriments.energyKcal / 100.0) * (Double(quantityNumber) ?? 0)
        
        // Corps de la requête
        let requestBody: [String: Any] = [
            "name": product.productName,
            "calories": caloriesEat,
            "quantity": quantityNumber,
            "image_url": product.imageUrl
        ]
        
        // Configuration de la requête
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
        
        // Exécution de la requête réseau
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -5, userInfo: [NSLocalizedDescriptionKey: "Réponse du serveur non valide."])))
                return
            }
            
            // Vérification du code de statut HTTP
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Erreur HTTP : \(httpResponse.statusCode)."])))
                return
            }
            
            // Traitement des données
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -6, userInfo: [NSLocalizedDescriptionKey: "Aucune donnée reçue du serveur."])))
                return
            }
            
            do {
                struct ApiResponse: Decodable {
                    let message: String
                }
                
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                SuccessSaveProduct = true
                completion(.success(apiResponse.message))
            } catch {
                completion(.failure(NSError(domain: "", code: -7, userInfo: [NSLocalizedDescriptionKey: "Erreur lors du décodage de la réponse."])))
            }
        }.resume()
    }

    func nutriScoreColor(for score: String) -> Color {
        switch score.lowercased() {
        case "a", "b":
            return .green
        case "c":
            return .yellow
        case "d":
            return .orange
        case "e":
            return .red
        default:
            return .gray
        }
    }
}






