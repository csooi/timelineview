import Foundation

enum DateExtractorError: Error {
    case invalidDate
    case dateCreationFailed
}

struct CalendarDayExtractor {
    private let calendar: Calendar
    private let numberOfWeeks = 6
    private let referenceDate: Date
    private let referenceWeekday: Int

    init(calendar: Calendar = .current, referenceDate: Date = Date()) {
        self.calendar = calendar
        self.referenceDate = calendar.startOfDay(for: referenceDate)
        self.referenceWeekday = calendar.component(.weekday, from: self.referenceDate)
    }

    func extractDates(from date: Date = Date()) -> Result<[DateValue], DateExtractorError> {
        guard let currentMonthDate = getCurrentMonthDate(from: date) else {
            return .failure(.invalidDate)
        }

        guard let firstDayOfGrid = getFirstDayOfGrid(for: currentMonthDate) else {
            return .failure(.dateCreationFailed)
        }

        return .success(generateDatesForGrid(startingFrom: firstDayOfGrid, currentMonthDate: currentMonthDate))
    }

    private func getCurrentMonthDate(from date: Date) -> Date? {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)
    }

    private func getFirstDayOfGrid(for date: Date) -> Date? {
        let firstOfMonth = date
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let daysToSubtract = (firstWeekday - calendar.firstWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: firstOfMonth)
    }

    private func generateDatesForGrid(startingFrom startDate: Date, currentMonthDate: Date) -> [DateValue] {
        let totalDays = numberOfWeeks * 7
        return (0..<totalDays).compactMap { day in
            guard let currentDate = calendar.date(byAdding: .day, value: day, to: startDate) else {
                return nil
            }
            return createDateValue(for: currentDate, currentMonthDate: currentMonthDate)
        }
    }

    private func createDateValue(for date: Date, currentMonthDate: Date) -> DateValue {
        DateValue(
            day: calendar.component(.day, from: date),
            date: date,
            isCurrentMonth: calendar.isDate(date, equalTo: currentMonthDate, toGranularity: .month),
            isToday: calendar.isDateInToday(date),
            isNewWeek: isNewWeek(date)
        )
    }

    private func isNewWeek(_ date: Date) -> Bool {
        let dateWeekday = calendar.component(.weekday, from: date)
        return dateWeekday == referenceWeekday
    }
}
