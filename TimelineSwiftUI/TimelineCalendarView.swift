import SwiftUI

struct TimelineWrapper: Codable {
    let Timeline: [OriEvent]
}

struct OriEvent: Identifiable, Codable {
    let id = UUID()
    let category: String
    let body: String
    let startWeek: Int
    let endWeek: Int
    let deepLink: String?
    
    enum CodingKeys: String, CodingKey {
        case category = "Category"
        case body = "Body"
        case startWeek = "StartWeek"
        case endWeek = "EndWeek"
        case deepLink = "DeepLink"
    }
}

func loadEventsFromJSON() -> [OriEvent] {
    guard let url = Bundle.main.url(forResource: "Timeline", withExtension: "json") else {
        print("Timeline.json not found in bundle.")
        return []
    }
    
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let timelineData = try decoder.decode(TimelineWrapper.self, from: data)
        return timelineData.Timeline
    } catch {
        print("Error decoding Timeline.json: \(error)")
        return []
    }
}


struct PlottingEvent: Identifiable {
    let id = UUID()
    // let weekRow: Int
    let plotStartIndex: Int
    let plotEndIndex: Int
    let plotRow: Int
    let event: OriEvent
}

//let sampleEvents: [OriEvent] = [
//    OriEvent(category: "Welcome",
//                  body: "Willkommen in Ihrer Timeline 👋",
//                  startWeek: 1, endWeek: 1, deepLink: nil),
//    OriEvent(category: "DailyHabits", body: "Folsäure-Ergänzung empfohlen", startWeek: 1, endWeek: 13, deepLink: nil),
//    OriEvent(category: "PregnancyMilestones", body: "Letzte Periode", startWeek: 1, endWeek: 1, deepLink: "action://pregnancy/show/content/ArticleContainer?cmsId=28fddbada1aae9bcf6d2c24f26f6cf0a"),
//    OriEvent(category: "PregnancyMilestones", body: "Ovulation", startWeek: 3, endWeek: 3, deepLink: "action://pregnancy/show/content/ArticleContainer?cmsId=94bb61190618d545c62bea5d6ea99280"),
//    OriEvent(category: "PregnancyMilestones", body: "Konzeption", startWeek: 3, endWeek: 3, deepLink: "action://pregnancy/show/content/ArticleContainer?cmsId=fe3242cf53055ef96f038a251e29accd")
//]

struct TimelineCalendarView: View {
    @Binding var currentDate: Date
    @State var pregStartDay: Date = Date(timeIntervalSince1970: 1733249793)
    // Month update on arrow button clicks...
    @State var currentMonth: Int = 0
    
    let calendar = Calendar(identifier: .gregorian)
    
    var startMonth: Int = 0
    var endMonth: Int = 9
    
    @State var canScroll = false
    @State private var jsonEvents: [OriEvent] = []
    @State private var plottingEvents: [Int: [PlottingEvent]] = [:]

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
                                
                                jsonEvents = loadEventsFromJSON()
                                plottingEvents = generatePlottingEvents(events: jsonEvents,
                                                                        pregStartDay: pregStartDay)
                                print(pregStartDay.remappedWeekday)
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
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        
        return TabView(selection: $currentMonth) {
            ForEach(startMonth...endMonth, id: \.self) { index in
                ZStack {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(extractDates(fromMonth: index)) { value in
                            DayView(value: value)
                                .frame(height: TimelineConstants.CalenderView.dayViewHeight)
                        }
                    }
                    
                    // Overlay events for this month
                    eventsOverlayView(for: index)
                }
                .tag(index)
            }
        }
        .onChange(of: currentMonth) { newIndex in
            print("Current index: \(newIndex)")
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: TimelineConstants.CalenderView.totalCalenderHeight)
    }
    
    @ViewBuilder
    func DayView(value: DayModel) -> some View {
        // Calculate days since pregnancy start
        let startOfPregStart = calendar.startOfDay(for: pregStartDay)
        let startOfValue = calendar.startOfDay(for: value.date)
        let daysSincePregStart = calendar.dateComponents([.day], from: startOfPregStart, to: startOfValue).day ?? -9999
        
        ZStack {
            VStack(spacing: 3.0) {
                Text("\(value.day)")
                    .font(.system(size: 14.0, weight: .medium))
                    .foregroundColor(dayTextColor(date: value.date,
                                                  isCurrentMonth: value.isCurrentMonth))
                    .frame(maxWidth: .infinity)
                    .background {
                        if(value.isToday) {
                            Circle()
                                .fill(Color(red: 1, green: 0.5, blue: 0.62).opacity(0.12))
                                .frame(width: 26.0, height: 26.0)
                                
                        }
                    }
                
                // Check if this day marks a new pregnancy week
                // Conditions:
                // - daysSincePregStart >= 0 and < 42*7 (within 42 weeks range)
                // - multiple of 7 days means a new pregnancy week starts
                if daysSincePregStart >= 0 && daysSincePregStart < 42 * 7 && (daysSincePregStart % 7) == 0 {
                    let weeks = daysSincePregStart / 7
                    let weekText = (weeks == 0) ? "<1 wk" : "\(weeks) wk"
                    
                    Text(weekText)
                        .font(.system(size: 10.0, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(pregnancyWeekColor(for: value.date, pregStartDay: pregStartDay))
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 8.0)
        .border(Color(red: 0.89, green: 0.89, blue: 0.91), width: 0.5)
    }
    
    func dayTextColor(date: Date, isCurrentMonth: Bool) -> Color {
        if Calendar.current.isDateInToday(date) {
            return .pink
        } else if isCurrentMonth {
            return .black
        } else {
            return .gray
        }
    }
    
    func pregnancyWeekColor(for date: Date, pregStartDay: Date) -> Color {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayStart = calendar.startOfDay(for: date)
        let pregStart = calendar.startOfDay(for: pregStartDay)
        let defaultColor = Color(red: 0.69, green: 0.69, blue: 0.71)
        guard let daysSincePregStartForDate = calendar.dateComponents([.day], from: pregStart, to: dayStart).day,
              let daysSincePregStartForToday = calendar.dateComponents([.day], from: pregStart, to: today).day else {
            return .black
        }

        let weekForDate = Int(floor(Double(daysSincePregStartForDate) / 7.0))
        let weekForToday = Int(floor(Double(daysSincePregStartForToday) / 7.0))

        return weekForDate == weekForToday ? .pink : defaultColor
    }



    func extractDates(fromMonth: Int) -> [DayModel] {
        let extractor = CalendarDayExtractor(calendar: calendar,
                                             referenceDate: pregStartDay)
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
    
    @ViewBuilder
    func eventsOverlayView(for monthIndex: Int) -> some View {
        GeometryReader { geometry in
            let dayWidth = geometry.size.width / 7
            let dayHeight = TimelineConstants.CalenderView.dayViewHeight
            let weeksPerMonth = CalendarDayExtractor.numberOfWeeks
            
            let monthDates = extractDates(fromMonth: monthIndex)

            if monthDates.isEmpty {
                EmptyView()
            } else {
                ForEach(0..<weeksPerMonth, id: \.self) { weekIndex in
                    let weekStartIndex = weekIndex * 7
//                    guard weekStartIndex < monthDates.count else { return }
                    
                    let firstDayOfWeek = monthDates[weekStartIndex].date
                    let weekRow = calculateWeekRow(for: firstDayOfWeek, pregStartDay: pregStartDay)
                    
                    let eventsForWeek = plottingEvents[weekRow] ?? []
                    
                    let startColumnIndex = pregStartDay.remappedWeekday
                    let dayEventsForWeek = eventsForWeek.filter {
                        $0.plotStartIndex <= startColumnIndex && $0.plotEndIndex >= startColumnIndex
                    }
                    
                    let displayedEvents = eventsForWeek
                        .filter { $0.plotRow < 2 }
                        .sorted { $0.plotRow < $1.plotRow }
                    
                    let remainingCount = dayEventsForWeek.count - displayedEvents.count
                    
                    let relativeWeekIndex = CGFloat(weekIndex)
                    let weekOffsetY: CGFloat = relativeWeekIndex * dayHeight
                    let topOffset: CGFloat = 50.0
                    let eventBarHeight: CGFloat = 18.0
                    let eventVerticalSpacing: CGFloat = 2.0
                    let eventHorizontalPadding: CGFloat = 2.0
                    let moreTextX = CGFloat(startColumnIndex) * dayWidth + (dayWidth / 2)
                    
                    ForEach(displayedEvents) { plottingEvent in
                        let startIndex = plottingEvent.plotStartIndex
                        let endIndex = plottingEvent.plotEndIndex
                        let plotRow = plottingEvent.plotRow
                        
                        let startX: CGFloat = CGFloat(startIndex) * dayWidth + eventHorizontalPadding
                        let endX: CGFloat = CGFloat(endIndex + 1) * dayWidth - eventHorizontalPadding
                        let eventWidth: CGFloat = endX - startX
                        let yOffsetForPlotRows = CGFloat(plotRow) * (eventBarHeight + eventVerticalSpacing)
                        let eventY: CGFloat = weekOffsetY + topOffset + yOffsetForPlotRows + eventBarHeight / 2
                        
                        let eventColor = getEventColor(for: plottingEvent.event.category)
                        
                        ZStack(alignment: .leading) {
                            Group {
                                Color.white
                                Rectangle()
                                    .fill(eventColor.opacity(0.12))
                            }
                            .cornerRadius(4)
                            .frame(width: eventWidth, height: eventBarHeight)
                            
                            Text(plottingEvent.event.body)
                                .font(.system(size: 10))
                                .foregroundColor(eventColor)
                                .lineLimit(1)
                                .padding(.horizontal, 4)
                                .frame(width: eventWidth - 8, alignment: .leading)
                        }
                        .position(x: startX + eventWidth / 2, y: eventY)
                    }
                    
                    if remainingCount > 0 {
                        let lastEventRow = min(eventsForWeek.count - 1, 1)
                        let yOffsetForPlotRows = CGFloat(lastEventRow) * (eventBarHeight + eventVerticalSpacing)
                        let moreTextY: CGFloat = weekOffsetY + topOffset + yOffsetForPlotRows + eventBarHeight / 2 + 16
                        
                        Text("\(remainingCount) more")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(uiColor: UIColor(red: 0, green: 0.745, blue: 0.86, alpha: 1)))
                            .position(x: moreTextX, y: moreTextY)
                    }
                }
            }
        }
    }


    func generatePlottingEvents(events: [OriEvent], pregStartDay: Date) -> [Int: [PlottingEvent]] {
        let calendar = Calendar(identifier: .gregorian)
        var plottingEventsDictionary: [Int: [PlottingEvent]] = [:]
        
        for event in events {
            // Calculate the start date of the event based on pregStartDay and startWeek
            guard let eventStartDate = calendar.date(byAdding: .weekOfYear, 
                                                     value: event.startWeek - 1, 
                                                     to: pregStartDay) else {
                continue
            }
            
            // Determine the total weeks the event spans
            let totalWeeks = event.endWeek - event.startWeek + 1
            let weekday = pregStartDay.remappedWeekday
            let adjustedTotalWeeks = (weekday == 0) ? totalWeeks : totalWeeks + 1
            
            for weekIndex in 0..<adjustedTotalWeeks {
                // Calculate the current week's start date
                guard let currentWeekStartDate = calendar.date(byAdding: .weekOfYear, 
                                                               value: weekIndex, 
                                                               to: eventStartDate) else {
                    continue
                }
                
                // Determine the weekRow (week of the month)
                let weekRow = calculateWeekRow(for: currentWeekStartDate, pregStartDay: pregStartDay)
                
                // Determine plotStartIndex and plotEndIndex
                let (plotStartIndex, plotEndIndex) = calculatePlotIndices(
                    weekIndex: weekIndex, 
                    totalWeeks: adjustedTotalWeeks,
                    currentWeekStartDate: currentWeekStartDate,
                    pregStartDay: pregStartDay
                )
                print("Event:\(event.body) @ weekRow:\(weekRow) - \((plotStartIndex, plotEndIndex)) adjustedTotalWeeks: \(adjustedTotalWeeks) weekDAY:\(weekday)")
                // Find an available plotRow for this week
                let plotRow = findAvailablePlotRow(plotStartIndex: plotStartIndex,
                                                   plotEndIndex: plotEndIndex,
                                                   existingEvents: plottingEventsDictionary[weekRow] ?? [])
                
                // Create PlottingEvent
                let plottingEvent = PlottingEvent(
                    plotStartIndex: plotStartIndex, 
                    plotEndIndex: plotEndIndex, 
                    plotRow: plotRow, 
                    event: event
                )
                
                // Add to dictionary
                plottingEventsDictionary[weekRow, default: []].append(plottingEvent)
            }
        }
        var adjustedDictionary: [Int: [PlottingEvent]] = [:]
            for (key, value) in plottingEventsDictionary {
                adjustedDictionary[key - 1] = value
            }
        return adjustedDictionary
    }

    // Helper function to calculate weekRow
    func calculateWeekRow(for date: Date, pregStartDay: Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        guard let dayCount = calendar.dateComponents([.day], from: pregStartDay, to: date).day else {
            return 0
        }

        let floatWeeks = Double(dayCount) / 7.0
        let weekRow = Int(floor(floatWeeks))
        return weekRow
    }


    // Helper function to calculate plot indices
    func calculatePlotIndices(
        weekIndex: Int, 
        totalWeeks: Int, 
        currentWeekStartDate: Date, 
        pregStartDay: Date
    ) -> (Int, Int) {
        // Find the day of the week for the current week's start date
        let weekday = currentWeekStartDate.remappedWeekday
        let plotStartIndex = weekIndex == 0 ? weekday : 0
        var plotEndIndex = weekIndex == totalWeeks - 1 ? weekday - 1 : 6
        
        // Ensure plotEndIndex is not -1
        if plotEndIndex == -1 {
            plotEndIndex = 6
        }
        
        // Determine plotEndIndex
        if weekIndex == 0 {
            // First week of a multi-week event
            return (plotStartIndex, plotEndIndex)
        } else if weekIndex > 0 && weekIndex == totalWeeks - 1 {
            // End week of a multi-week event
            return (0, plotEndIndex)
        } else {
            // Middle weeks of a multi-week event
            return (0, 6)
        }
    }

//    // Helper function to find an available plot row
//    func findAvailablePlotRow(in existingEvents: [PlottingEvent]) -> Int {
//        let usedRows = Set(existingEvents.map { $0.plotRow })
//        var plotRow = 0
//        while usedRows.contains(plotRow) {
//            plotRow += 1
//        }
//        return plotRow
//    }
    func findAvailablePlotRow(plotStartIndex: Int,
                              plotEndIndex: Int,
                              existingEvents: [PlottingEvent]) -> Int {
        // Group existing events by their plotRow
        let eventsByRow = Dictionary(grouping: existingEvents, by: { $0.plotRow })
        
        var row = 0
        while true {
            let rowEvents = eventsByRow[row] ?? []
            
            // Check if the row is completely free
            let isRowFree = rowEvents.allSatisfy { existing in
                // No overlap means either:
                // 1. New event entirely before existing event
                // 2. New event entirely after existing event
                plotEndIndex < existing.plotStartIndex || 
                plotStartIndex > existing.plotEndIndex
            }
            
            if isRowFree {
                return row
            }
            
            // Otherwise, try next row
            row += 1
        }
    }

    
    // Helper function to assign colors based on event category
    func getEventColor(for category: String) -> Color {
        return categoryColors[category, default: .gray]
    }
    let categoryColors: [String: Color] = [
        "Welcome": Color(hex: "FF809F"),
        "PregnancyMilestones": Color(hex: "FF809F"),
        "YourBabyDevelopment": Color(hex: "52CC85"),
        "YourHealthcare": Color(hex: "9466E0"),
        "DailyHabits": Color(hex: "FFA200"),
        "ThingsToPrepare": Color(hex: "F1A183")
    ]
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
extension Date {
    var remappedWeekday: Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        // Shift so that Monday=0, Tuesday=1, ..., Sunday=6
        return (weekday + 5) % 7
    }
}
