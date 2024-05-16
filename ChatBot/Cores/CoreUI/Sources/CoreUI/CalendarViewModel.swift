//
//  CalendarViewModel.swift
//  
//
//  Created by Kevin on 5/16/24.
//

import Foundation

final class CalendarViewModel: ObservableObject {


    func generateDatesForCurrentMonth() -> [Date] {
        var dates = [Date]()
        let calendar = Calendar.current
        let today = Date()

        // Get the range of days in the current month
        if let range = calendar.range(of: .day, in: .month, for: today) {
            for day in range {
                var components = calendar.dateComponents([.year, .month], from: today)
                components.day = day
                if let date = calendar.date(from: components) {
                    dates.append(date)
                }
            }
        }

        return dates
    }

}


