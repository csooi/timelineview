import SwiftUI

struct TimelineCalendarView: View {
    @Binding var currentDate: Date
    @State var duedate: Date = Date(timeIntervalSince1970: 1743487531)
    // Month update on arrow button clicks...
    @State var currentMonth: Int = 0
    
    let calendar = Calendar(identifier: .gregorian)
    
    var startMonth: Int = -3
    var endMonth: Int = 8
    
    @State var canScroll = false

    var body: some View {
        TabView{
            NavigationView {
                GeometryReader { calenderProxy in
                    ScrollViewReader { scrollViewProxy in
                        PreventableScrollView (canScroll: $canScroll) {
                            VStack(spacing: 0) {
                                headerView.id(0)
                                daysHeaderView
                                calendarGridView(scrollViewProxy: scrollViewProxy)
                                Spacer()
                            }.onAppear {
                                detectScrollView(calenderProxy: calenderProxy)
                            }
                        }
                        .background(Color.white)
                        
                        .navigationTitle("Timeline")
                        .navigationBarTitleDisplayMode(.inline)
                        
                    }
                }
            }.tabItem {
                Text("Today")
                Image(systemName: "circle.fill")
                    .renderingMode(.template)
            }
        }
    }
    
    var headerView: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text(getMonthString())
                    .font(Font.system(size: 32.0, weight: .bold))
                
            }
            Spacer()
//            Button(action: { currentMonth -= 1 }) {
//                Image(systemName: "chevron.left")
//                    .font(.title2)
//            }
//            Button(action: { currentMonth += 1 }) {
//                Image(systemName: "chevron.right")
//                    .font(.title2)
//            }
        }
        .frame(height: TimelineConstants.CalenderView.headerHeight)
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
        .frame(height: TimelineConstants.CalenderView.daysRowHeight)
    }

    func calendarGridView(scrollViewProxy: ScrollViewProxy) -> some View {
        let columns = Array(repeating: GridItem(.flexible(),
                                                spacing: 0),
                            count: 7)
        
        return TabView(selection: $currentMonth) {
            ForEach(startMonth...endMonth, id: \.self) { index in
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(extractDates(fromMonth: index)) { value in
                        DayView(value: value)
                            .frame(height: TimelineConstants.CalenderView.dayViewHeight)
                    }
                }
                .tag(index)
            }
        }
        .onChange(of: currentMonth) { newIndex in
            // This block gets called whenever currentIndex changes
            print("Current index: \(newIndex)")
//            withAnimation {
//                scrollViewProxy.scrollTo(0)
//            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: TimelineConstants.CalenderView.totalCalenderHeight)
    }

    @ViewBuilder
    func DayView(value: DayModel) -> some View {
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

    func extractDates(fromMonth: Int) -> [DayModel] {
        let extractor = CalendarDayExtractor(calendar: calendar,
                                             referenceDate: duedate)
        switch extractor.extractDates(from: getCurrentMonth(month: fromMonth)) {
        case .success(let dates):
            return dates
        case .failure(_):
            return []
        }
    }

    func getCurrentMonth(month: Int) -> Date {
        calendar.date(byAdding: .month,
                      value: month,
                      to: Date()) ?? Date()
    }

    func getMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: getCurrentMonth(month: currentMonth))
    }
    
    func detectScrollView(calenderProxy: GeometryProxy) {
        let availableFrameHeight = calenderProxy.size.height
        let contentHeight = TimelineConstants.CalenderView.headerHeight +
        TimelineConstants.CalenderView.daysRowHeight +
        TimelineConstants.CalenderView.totalCalenderHeight
        
        canScroll =  contentHeight > availableFrameHeight
    }
}

struct DayModel: Identifiable {
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

enum TimelineConstants {
    enum CalenderView {
        static let headerHeight = 60.0
        static let daysRowHeight = 26.0
        static let totalCalenderHeight = 660.0
        static let dayViewHeight = 110.0
    }
}
