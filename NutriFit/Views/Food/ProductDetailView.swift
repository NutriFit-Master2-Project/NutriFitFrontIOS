//
//  ProductDetailView.swift
//  NutriFit
//
//  Created by Maxence Walter on 29/11/2024.
//

import SwiftUI

struct ProductDetailView: View {
    let product: ProductList

    var body: some View {
        ZStack {
            Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
                .ignoresSafeArea()
            
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
                                        .frame(width: 300, height: 200)
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
