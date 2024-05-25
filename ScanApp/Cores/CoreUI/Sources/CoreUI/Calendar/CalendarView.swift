import SwiftUI

public struct CalendarView: View {
    @Binding var selectedDate: Date?

    public init(selectedDate: Binding<Date?>) {
        self._selectedDate = selectedDate
    }

    private func getCalendarGrid(for date: Date) -> [[Date?]] {
        var calendar = Calendar.current
        calendar.firstWeekday = 1 // Sunday = 1, Monday = 2, etc.

        let dateComponents = calendar.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!
        let numberOfDaysInMonth = range.count
        let weekdayOfFirstDay = calendar.component(.weekday, from: firstDayOfMonth) - 1

        var daysInGrid = [[Date?]]()
        var currentRow = [Date?]()

        for day in 0 ..< (numberOfDaysInMonth + weekdayOfFirstDay) {
            if day < weekdayOfFirstDay {
                currentRow.append(nil)
            } else {
                let dateToAdd = calendar.date(byAdding: .day, value: day - weekdayOfFirstDay, to: firstDayOfMonth)!
                currentRow.append(dateToAdd)
            }

            if currentRow.count == 7 {
                daysInGrid.append(currentRow)
                currentRow = [Date?]()
            }
        }

        if !currentRow.isEmpty {
            daysInGrid.append(currentRow)
        }

        return daysInGrid
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate ?? Date())
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
                Text(selectedDate.map {
                    DateFormatter().monthSymbols[
                        Calendar.current.component(.month, from: $0) - 1] + " " + String(
                        Calendar.current.component(.year, from: $0)
                    )
                } ?? "")
                    .font(.title2)
                    .fontWeight(.bold)
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate ?? Date())
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }

            }
            .padding().background(Color.yellow)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(getCalendarGrid(for: selectedDate ?? Date()), id: \.self) { row in
                    ForEach(row, id: \.self) { date in
                        if let date = date {
                            Text(
                                Calendar.current.isDate(date, inSameDayAs: Date()) ? "Today" : String(
                                    Calendar.current.component(.day, from: date)
                                )
                            )
                            .frame(maxWidth: .infinity)
                            .foregroundColor(selectedDate.flatMap { Calendar.current.isDate(date, inSameDayAs: $0) ? .white : .black } ?? .black)
                            .background(selectedDate.flatMap { Calendar.current.isDate(date, inSameDayAs: $0) ? Color.blue : Color.clear } ?? .clear)
                            .onTapGesture {
                                selectedDate = date
                            }
                        } else {
                            Text("")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }.background(Color.red)
        Spacer()
    }
}
