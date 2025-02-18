//
//  RecommendedDishView.swift
//  NutriFit
//
//  Created by Maxence Walter on 17/02/2025.
//

import SwiftUI

struct RecommendedDishView: View {
    var dish: Dish

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(dish.name)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.bottom, 5)

                Text("Description : \(dish.description)")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 5)

                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                    Text("Temps de préparation : \(dish.cookTime)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 5)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Ingrédients :")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.bottom, 2)

                    ForEach(dish.food, id: \.self) { food in
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.green)
                            Text("• \(food)")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 5)
                    }
                }
                .padding(.bottom, 10)

                if !dish.extraFood.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Aliments supplémentaires :")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.bottom, 2)

                        ForEach(dish.extraFood, id: \.self) { extraFood in
                            HStack {
                                Image(systemName: "fork.knife.circle.fill")
                                    .foregroundColor(.red)
                                Text("• \(extraFood)")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 5)
                        }
                    }
                    .padding(.bottom, 10)
                } else {
                    Text("Aucun aliment supplémentaire au frigo")
                        .font(.body)
                        .italic()
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                        .padding(.bottom, 10)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Étapes de préparation :")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.bottom, 2)

                    ForEach(dish.preparationStep, id: \.self) { step in
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.purple)
                            Text("• \(step)")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 10)
                        .padding(.leading, 5)
                    }
                }

                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal)
        }
    }
}

