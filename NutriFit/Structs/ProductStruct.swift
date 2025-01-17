//
//  ProductStruct.swift
//  NutriFit
//
//  Created by Maxence Walter on 26/11/2024.
//

import Foundation

struct Product: Identifiable {
    let id = UUID()
    let productName: String
    let ingredientsText: String
    let nutriments: Nutriments
    let nutriscoreGrade: String
    let brands: String
    let categories: String
    let quantity: String
    let labels: String
    let allergens: [String]
    let imageUrl: String
}

struct Nutriments {
    let energy: Double
    let energyKcal: Double
    let fat: Double
    let saturatedFat: Double
    let sugars: Double
    let salt: Double
    let proteins: Double
}

extension Nutriments {
    func asDictionary() -> [String: String] {
        return [
            "Énergie (kJ)": "\(energy) kJ",
            "Énergie (kcal)": "\(energyKcal) kcal",
            "Graisses": "\(fat) g",
            "Graisses saturées": "\(saturatedFat) g",
            "Sucres": "\(sugars) g",
            "Sel": "\(salt) g",
            "Protéines": "\(proteins) g"
        ]
    }
}

extension Nutriments {
    func asDictionaryBdd() -> [String: String] {
        return [
            "energy": "\(energy)",
            "energy-kcal": "\(energyKcal)",
            "fat": "\(fat)",
            "saturatedFat": "\(saturatedFat)",
            "sugars": "\(sugars)",
            "salt": "\(salt)",
            "proteins": "\(proteins)"
        ]
    }
}

struct ProductList: Identifiable {
    let id = UUID()
    let _id: String
    let productName: String
    let ingredientsText: String
    let nutriments: NutrimentsListProduct
    let nutriscoreGrade: String
    let brands: String
    let categories: String
    let quantity: String
    let labels: String
    let allergens: [String]
    let imageUrl: String
}

struct NutrimentsListProduct {
    let energy: String
    let energyKcal: String
    let fat: String
    let saturatedFat: String
    let sugars: String
    let salt: String
    let proteins: String
}

extension NutrimentsListProduct {
    func asDictionary() -> [String: String] {
        return [
            "Énergie (kJ)": "\(energy) kJ",
            "Énergie (kcal)": "\(energyKcal) kcal",
            "Graisses": "\(fat) g",
            "Graisses saturées": "\(saturatedFat) g",
            "Sucres": "\(sugars) g",
            "Sel": "\(salt) g",
            "Protéines": "\(proteins) g"
        ]
    }
}
