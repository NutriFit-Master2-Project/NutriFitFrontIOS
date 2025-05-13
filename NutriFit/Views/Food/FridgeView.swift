//
//  FridgeView.swift
//  NutriFit
//
//  Created by Maxence Walter on 26/11/2024.
//

import SwiftUI

struct FridgeView: View {
    @State private var productList: [Product] = []
    @State private var listProductName: [String] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @State private var selectedProduct: Product? = nil
    @State private var isGeneratingDish: Bool = false
    @State private var recommendationDish: Dish? = nil
    @State private var showRecommendedDishView: Bool = false

    // Page du frigo
    var body: some View {
        ZStack {
            Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
                .ignoresSafeArea()
            VStack {
                if isLoading {
                    ProgressView("Chargement des produits...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.gray)
                        .padding()
                } else if productList.isEmpty {
                    Text("Aucun produit enregistré.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // Liste des repas du frigo
                    List {
                        Section(header: Text("Mes Aliments")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        ) {
                            ForEach(productList) { product in
                                HStack {
                                    if let url = URL(string: product.imageUrl) {
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

                                    Text(product.productName)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .contentShape(Rectangle())
                                .listRowBackground(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                                .padding(.vertical, 10)
                                .onTapGesture {
                                    selectedProduct = product
                                }
                            }
                            .onDelete(perform: deleteItems)
                        }

                        // Centrer le bouton horizontalement et afficher le ProgressView
                        Section {
                            VStack {
                                HStack {
                                    Spacer()

                                    Button(action: {
                                        generateDish()
                                    }) {
                                        Text("Générer un plat")
                                            .font(.headline)
                                            .foregroundColor(Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255))
                                            .frame(width: 170, height: 40)
                                            .background(Color.white)
                                            .cornerRadius(10)
                                    }
                                    .padding()

                                    Spacer()
                                }
                                HStack {
                                    Spacer()

                                    if isGeneratingDish {
                                        ProgressView("Génération de votre plat en cours...")
                                            .padding()
                                    }

                                    Spacer()
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                        .padding(.top, -20)
                    }
                    .shadow(radius: 5)
                    .scrollContentBackground(.hidden)
                    .sheet(item: $selectedProduct) { product in
                        ProductDetailView(product: product)
                    }
                    .sheet(isPresented: $showRecommendedDishView) {
                        if let dish = recommendationDish {
                            RecommendedDishView(dish: dish)
                        }
                    }
                }
            }
            .onAppear {
                fetchProductList() { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let products):
                            self.productList = products
                            self.listProductName = products.map { $0.productName }
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

    // Fonction pour récupérer les repas du frigo de l'user
    func fetchProductList(completion: @escaping (Result<[Product], Error>) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            self.errorMessage = "Utilisateur non authentifié."
            return
        }
        
        let urlString = "https://nutri-fit-back-576739684905.europe-west1.run.app/api/nutrition/product-list/\(userId)"
        
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
                    isLoading = false
                    do {
                        if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                            var productList: [Product] = []
                            
                            for json in jsonArray {
                                if let _id = json["_id"] as? String,
                                   let productName = json["product_name"] as? String,
                                   let ingredientsText = json["ingredients_text"] as? String,
                                   let nutriscoreGrade = json["nutriscore_grade"] as? String,
                                   let brands = json["brands"] as? String,
                                   let categories = json["categories"] as? String,
                                   let quantity = json["quantity"] as? String,
                                   let labels = json["labels"] as? String,
                                   let allergens = json["allergens"] as? [String],
                                   let imageUrl = json["image_url"] as? String,
                                   let nutrimentsDict = json["nutriments"] as? [String: Any] {
                                    
                                    let nutriments = Nutriments(
                                        energy: nutrimentsDict["energy"] as? Double ?? 0.0,
                                        energyKcal: nutrimentsDict["energy-kcal"] as? Double ?? 0.0,
                                        fat: nutrimentsDict["fat"] as? Double ?? 0.0,
                                        saturatedFat: nutrimentsDict["saturatedFat"] as? Double ?? 0.0 ,
                                        sugars: nutrimentsDict["sugars"] as? Double ?? 0.0 ,
                                        salt: nutrimentsDict["salt"] as? Double ?? 0.0 ,
                                        proteins: nutrimentsDict["proteins"] as? Double ?? 0.0
                                    )

                                    let product = Product(
                                        id: _id,
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
                                    productList.append(product)
                                }
                            }
                            
                            completion(.success(productList))
                        } else {
                            completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Format de données incorrect"])))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Données manquantes"])))
                }
            } else {
                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Aucun produit enregistré."])))
            }
        }.resume()
    }
    
    // Fonction pour supprimer un repas en base
    func deleteProduct(productId: Any, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            self.errorMessage = "Utilisateur non authentifié."
            return
        }
        
        let urlString = "https://nutri-fit-back-576739684905.europe-west1.run.app/api/nutrition/product/\(userId)/\(productId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "URL non valide"])))
            return
        }
        guard let authToken = UserDefaults.standard.string(forKey: "authToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "auth-token non disponible"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue(authToken, forHTTPHeaderField: "auth-token")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Erreur lors de la suppression du produit"])))
            }
        }.resume()
    }
    
    // Fontion pour supprimer un repas sur le front et en base
    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let product = productList[index]
            guard let productId = product.id else {
                self.errorMessage = "Identifiant du produit non valide."
                return
            }
            deleteProduct(productId: productId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.productList.remove(atOffsets: offsets)
                        self.listProductName.remove(atOffsets: offsets)
                    case .failure(let error):
                        self.errorMessage = "Erreur lors de la suppression : \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    // Fonction pour la couleur du nutriscore
    func nutriScoreColor(for grade: String) -> Color {
        switch grade.lowercased() {
        case "a": return .green
        case "b": return .yellow
        case "c": return .orange
        case "d": return .red
        case "e": return .red.opacity(0.8)
        default: return .gray
        }
    }
    
    // Fonction pour récupérer un repas généré par l'IA en fonction des aliments du frigo
    func recommendedDishAi(productNames: [String], completion: @escaping (Result<Dish, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token non disponible"])))
            return
        }
        
        guard let url = URL(string: "https://nutri-fit-back-576739684905.europe-west1.run.app/api/recommend-dish") else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "URL non valide"])))
            return
        }

        let requestBody: [String: Any] = ["aliments": productNames]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Erreur de sérialisation JSON"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "auth-token")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Données manquantes"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                let dish = try decoder.decode(Dish.self, from: data)
                completion(.success(dish))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Fonction pour affichier le repas généré par l'IA
    func generateDish() {
        isGeneratingDish = true
        recommendedDishAi(productNames: listProductName) { result in
            DispatchQueue.main.async {
                self.isGeneratingDish = false
                switch result {
                case .success(let dish):
                    self.recommendationDish = dish
                    self.showRecommendedDishView = true
                case .failure(let error):
                    self.errorMessage = "Erreur : \(error.localizedDescription)"
                }
            }
        }
    }
}

