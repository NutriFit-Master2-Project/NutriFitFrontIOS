//
//  FridgeView.swift
//  NutriFit
//
//  Created by Maxence Walter on 26/11/2024.
//

import SwiftUI

struct FridgeView: View {
    @State private var productList: [ProductList] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @State private var selectedProduct: ProductList? = nil

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
                    List {
                        ForEach(productList) { product in
                            HStack {
                                // Image du produit
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

                                // Nom du produit
                                Text(product.productName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .contentShape(Rectangle())
                            .foregroundColor(.clear)
                            .listRowBackground(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                            .padding(.vertical, 10)
                            .onTapGesture {
                                selectedProduct = product
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .shadow(radius: 5)
                    .scrollContentBackground(.hidden)
                    .sheet(item: $selectedProduct) { product in
                        ProductDetailView(product: product)
                    }
                }
            }
            .navigationTitle("Mon Frigo")
            .onAppear {
                fetchProductList() { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let products):
                            self.productList = products
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

    func fetchProductList(completion: @escaping (Result<[ProductList], Error>) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            self.errorMessage = "Utilisateur non authentifié."
            return
        }
        
        let urlString = "https://nutrifitbackend-2v4o.onrender.com/api/nutrition/product-list/\(userId)"
        
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
                    //print("Données brutes : \(String(data: data, encoding: .utf8) ?? "Aucune donnée lisible")")
                    isLoading = false
                    do {
                        // Utilisation de JSONSerialization pour décoder la liste des produits
                        if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                            var productList: [ProductList] = []
                            
                            for json in jsonArray {
                                // Extraire les informations de chaque produit
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
                                    
                                    // Convertir nutriments
                                    let nutriments = NutrimentsListProduct(
                                        energy: nutrimentsDict["energy"] as? String ?? "0.0 kJ",
                                        energyKcal: nutrimentsDict["energy-kcal"] as? String ?? "0.0 kcal",
                                        fat: nutrimentsDict["fat"] as? String ?? "0.0 g",
                                        saturatedFat: nutrimentsDict["saturatedFat"] as? String ?? "0.0 g",
                                        sugars: nutrimentsDict["sugars"] as? String ?? "0.0 g",
                                        salt: nutrimentsDict["salt"] as? String ?? "0.0 g",
                                        proteins: nutrimentsDict["proteins"] as? String ?? "0.0 g"
                                    )
                                    
                                    // Créer le modèle `Product`
                                    let product = ProductList(
                                        _id: _id,
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
    
    func deleteProduct(productId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            self.errorMessage = "Utilisateur non authentifié."
            return
        }
        
        let urlString = "https://nutrifitbackend-2v4o.onrender.com/api/nutrition/product/\(userId)/\(productId)"
        
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
    
    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let product = productList[index]
            deleteProduct(productId: product._id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.productList.remove(atOffsets: offsets)
                    case .failure(let error):
                        self.errorMessage = "Erreur lors de la suppression : \(error.localizedDescription)"
                    }
                }
            }
        }
    }

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
}

