//
//  CalendarViewModel.swift
//  
//
//  Created by Kevin on 5/16/24.
//

import Foundation

public final class CalendarViewModel: ObservableObject {
    @Published var dates: [Date] = []
    public init() {}
    init(startDate: Date, numberOfDays: Int) {
        self.dates = CalendarViewModel.generateDates(
            startDate: startDate,
            numberOfDays: numberOfDays
        )
    }

    private static func generateDates(
        startDate: Date,
        numberOfDays: Int
    ) -> [Date] {
        var dates: [Date] = []
        for i in 0..<numberOfDays {
            if let date = Calendar.current.date(byAdding: .day, value: i, to: startDate) {
                dates.append(date)
            }
        }
        return dates
    }
}
