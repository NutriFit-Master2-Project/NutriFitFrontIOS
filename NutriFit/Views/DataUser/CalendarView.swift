//
//  CalendarView.swift
//  NutriFit
//
//  Created by Maxence Walter on 04/01/2025.
//

import SwiftUI
import Foundation

struct CalendarView: View {
    @State private var currentDate = Date()
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()
    
    // Génère toutes les dates (y compris les espaces vides avant le début du mois)
    var daysInMonthWithPadding: [Date?] {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return []
        }
        
        // Obtenez le jour de la semaine du premier jour du mois
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let paddingDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        // Ajoutez les jours vides pour le début de la semaine
        let paddedDays = Array(repeating: nil as Date?, count: paddingDays)
        
        // Génère toutes les dates du mois
        let monthDays = range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
        
        // Combinez les jours vides et les jours du mois
        return paddedDays + monthDays
    }

    private var currentMonthName: String {
        dateFormatter.string(from: currentDate)
    }
    
    private var today: Date {
        calendar.startOfDay(for: Date())
    }

    let columns = Array(repeating: GridItem(.flexible()), count: 7) // 7 colonnes pour les jours de la semaine

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 34 / 255, green: 34 / 255, blue: 34 / 255)
                    .ignoresSafeArea()
                
                VStack {
                    
                    // Titre du mois
                    VStack {
                        Text(currentMonthName.capitalized)
                            .font(.largeTitle)
                    }
                    .padding(.bottom, 30)
                    
                    // Grille du calendrier
                    VStack {
                        HStack {
                            ForEach(["L", "M", "M", "J", "V", "S", "D"], id: \.self) { day in
                                VStack() { // Ajouter de l'espace entre le texte et la ligne
                                    Text(day)
                                        .foregroundColor(.gray)
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(daysInMonthWithPadding, id: \.self) { day in
                                if let day = day {
                                    let isToday = calendar.isDate(day, inSameDayAs: today)
                                    
                                    NavigationLink(
                                        destination: DayDetailView(day: day),
                                        label: {
                                            Text("\(calendar.component(.day, from: day))")
                                                .frame(width: 40, height: 40)
                                                .background(isToday ? Color.blue : Color.clear)
                                                .foregroundColor(.white)
                                                .clipShape(Circle())
                                                .padding(.bottom, 20)
                                                .padding([.leading, .trailing], 5)
                                        }
                                    )
                                } else {
                                    Text("")
                                        .frame(width: 40, height: 40)
                                }
                            }
                        }                    }
                    .padding([.top, .bottom], 10)
                    .frame(width: 370)
                    .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 0.2))
                    .shadow(radius: 5)
                    .padding()
                    
                    // Boutons pour naviguer entre les mois
                    VStack {
                        HStack {
                            Button(action: {
                                currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                            }) {
                                Label("Précédent", systemImage: "chevron.left")
                            }
                            .padding(.leading, 25)
                            
                            Spacer()
                            
                            Button(action: {
                                currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                            }) {
                                Label("Suivant", systemImage: "chevron.right")
                            }
                            .padding(.trailing, 25)
                        }
                    }
                }
            }
        }
        .navigationTitle("Calendrier")
    }
}
