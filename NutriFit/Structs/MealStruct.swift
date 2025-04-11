//
//  MealStruct.swift
//  NutriFit
//
//  Created by Maxence Walter on 06/01/2025.
//

import Foundation

struct Meal: Identifiable, Codable {
    let id: String?
    let name: String
    let calories: Double
    let quantity: String
    var image_url: String
    let createdAt: CreatedAt
    
}

struct MealIA: Identifiable, Codable {
    let id: String?
    let name: String
    let calories: Int
    let quantity: Int
    var image_url: String?
}

struct CreatedAt: Codable {
    let _seconds: Int
    let _nanoseconds: Int
}

struct DailyEntry: Decodable {
    let calories: Double
    let caloriesBurn: Double
    let steps: Int
    let date: String
    let createdAt: CreatedAt

    struct CreatedAt: Decodable {
        let seconds: Int
        let nanoseconds: Int

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            seconds = try container.decodeIfPresent(Int.self, forKey: .seconds) ?? 0
            nanoseconds = try container.decodeIfPresent(Int.self, forKey: .nanoseconds) ?? 0
        }

        enum CodingKeys: String, CodingKey {
            case seconds = "_seconds"
            case nanoseconds = "_nanoseconds"
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        calories = try container.decodeIfPresent(Double.self, forKey: .calories) ?? 0.0
        caloriesBurn = try container.decodeIfPresent(Double.self, forKey: .caloriesBurn) ?? 0.0
        steps = try container.decodeIfPresent(Int.self, forKey: .steps) ?? 0
        date = try container.decodeIfPresent(String.self, forKey: .date) ?? "Inconnue"
        createdAt = try container.decode(CreatedAt.self, forKey: .createdAt)
    }

    enum CodingKeys: String, CodingKey {
        case calories
        case caloriesBurn
        case steps
        case date
        case createdAt
    }
}


