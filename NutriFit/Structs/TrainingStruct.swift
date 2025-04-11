//
//  TrainingStruct.swift
//  NutriFit
//
//  Created by Maxence Walter on 20/01/2025.
//

import Foundation

// Structure d'une séance sportive
struct TrainingProgram: Codable, Identifiable {
    let id: String
    let totalCalories: Int
    let name: String
    let description: String
    let type: String
    let exercises: [Exercise]
}

// Structure d'un exercice d'une séance sportive
struct Exercise: Codable, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let muscles: [String]
    let series: Int
    let repetitions: Int
    let calories: Int
    let image: String
}
