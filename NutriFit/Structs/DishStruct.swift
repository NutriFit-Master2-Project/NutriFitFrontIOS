//
//  DishStruct.swift
//  NutriFit
//
//  Created by Maxence Walter on 18/02/2025.
//

import Foundation

struct Dish: Codable {
    let id: String
    let name: String
    let description: String
    let food: [String]
    let extraFood: [String]
    let preparationStep: [String]
    let cookTime: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "Name"
        case description = "Description"
        case food = "Food"
        case extraFood = "ExtraFood"
        case preparationStep = "PreparationStep"
        case cookTime = "CookTime"
    }
}
