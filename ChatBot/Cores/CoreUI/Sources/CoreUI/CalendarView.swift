//
//  CalendarView.swift
//  
//
//  Created by Kevin on 5/16/24.
//

import UIKit
import SwiftUI

struct CalendarView: View {

    var body: some View {
        let dates = generateDatesForCurrentMonth()
        let dayFormatter = dayFormatter()
        let weekdayFormatter = weekdayFormatter()

        VStack {
            ForEach(dates, id: \.self) { date in
                HStack {
                    Text(dayFormatter.string(from: date)) // Day number
                        .font(.headline)
                    Text(weekdayFormatter.string(from: date)) // Weekday name
                        .font(.subheadline)
                }
            }
        }
        .padding()
    }
    func dayFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }

    func weekdayFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }

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


