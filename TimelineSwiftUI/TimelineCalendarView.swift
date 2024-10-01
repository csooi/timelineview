import SwiftUI

struct TimelineCalendarView: View {
    @Binding var currentDate: Date
    @State var duedate: Date = Date(timeIntervalSince1970: 1743487531)
    // Month update on arrow button clicks...
    @State var currentMonth: Int = 0
    
    let calendar = Calendar(identifier: .gregorian)

    var body: some View {
        VStack(spacing: 0) {
            headerView
            daysHeaderView
            calendarGridView
            Spacer()
        }
//        .padding(.horizontal)
//        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
    }

    var headerView: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text(getMonthString())
                    .font(Font.system(size: 32.0, weight: .bold))
                
            }
            Spacer()
            Button(action: { currentMonth -= 1 }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
            }
            Button(action: { currentMonth += 1 }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
            }
        }
        .frame(height: 60.0)
        .padding(.horizontal, 16.0)
    }

    var daysHeaderView: some View {
        HStack(spacing: 0) {
            ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
                    id: \.self) { day in
                Text(day)
                    .textCase(.uppercase)
                    .font(Font.system(size: 12.0, weight: .semibold))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 10)
    }

    var calendarGridView: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing:0), count: 7)
        return LazyVGrid(columns: columns, spacing: 0) {
            ForEach(extractDates()) { value in
                CardView(value: value)
                    .frame(height: 110)
            }
        }
    }

    @ViewBuilder
    func CardView(value: DateValue) -> some View {
        ZStack(content: {
            VStack(spacing: 3.0) {
                Text("\(value.day)")
                    .font(Font.system(size: 14.0, weight: .medium))
                    .foregroundColor(value.isCurrentMonth ? .primary : .gray)
                    .frame(maxWidth: .infinity)
                    .background(value.isToday ? Color.blue.opacity(0.5) : Color.white)
                if (value.isNewWeek) {
                    Text("\(value.day)")
                        .font(Font.system(size: 10.0, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.69, green: 0.69, blue: 0.71))
                }
                Spacer()
            }
        })
        .padding(.vertical, 8.0)
        .border(Color(red: 0.89, green: 0.89, blue: 0.91), width: 0.5)
        
    }

    func extractDates() -> [DateValue] {
        let extractor = CalendarDayExtractor(calendar: calendar,
                                             referenceDate: duedate)
        switch extractor.extractDates(from: getCurrentMonth()) {
        case .success(let dates):
            return dates
        case .failure(let error):
            return []
        }
    }

    func getCurrentMonth() -> Date {
        calendar.date(byAdding: .month, value: currentMonth, to: Date()) ?? Date()
    }

    func getMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: getCurrentMonth())
    }
}

struct DateValue: Identifiable {
    let id = UUID()
    let day: Int
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let isNewWeek: Bool
}

struct CustomDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimelineCalendarView(currentDate: .constant(Date()))
        }
    }
}
