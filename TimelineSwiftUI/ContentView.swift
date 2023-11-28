import SwiftUI

struct TimePill: Identifiable {
    let id = UUID()
    var name: String
    var startWeek: Int
    var duration: Int
    var color: Color
    var row: Int
}

struct TimelineView: View {
    let timePills: [TimePill] = [
        TimePill(name: "Pill that do something at Week 1-3 Pill that do something at Week 1-3 Pill that do something at Week 1-3", startWeek: 1, duration: 3, color: .black, row: 0),
        TimePill(name: "Pill that do something at Week 6-7", startWeek: 5, duration: 2, color: .green, row: 1),
        TimePill(name: "Pill that do something at Week 11-13", startWeek: 10, duration: 4, color: .blue, row: 2),
        TimePill(name: "Pill that do something at Week 15-19", startWeek: 15, duration: 5, color: .yellow, row: 0),
        TimePill(name: "Pill that do something at Week 20-22", startWeek: 20, duration: 3, color: .purple, row: 1)
    ]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        ForEach(0..<20, id: \.self) { row in
                            HStack(spacing: 1) {
                                ForEach(0..<42, id: \.self) { week in
                                    ZStack(alignment: .center) {
                                        // The week background (can be empty or styled)
                                        Rectangle()
                                            .fill(Color.red.opacity(0.2))
                                            .frame(width: weekWidth(geometry.size.width), height: 30)
                                            .padding(.zero)
                                        // Overlay TimePill if it exists for this week and row
                                        if let pill = timePillForRowAndWeek(row: row, week: week) {
                                            Rectangle()
                                                .fill(pill.color)
                                                .frame(width: CGFloat(pill.duration) * weekWidth(geometry.size.width))
                                                .padding(.zero)
                                            Text(pill.name)
                                                .font(.headline)
                                                .padding(.horizontal, 20.0)
                                                .foregroundColor(.white)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .frame(width: CGFloat(pill.duration) * weekWidth(geometry.size.width))
                                                .padding(.vertical, 20.0)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

    }

    func weekWidth(_ screenWidth: CGFloat) -> CGFloat {
        // Calculate the width for each week column
        screenWidth / 3
    }

    func maxRow(in timePills: [TimePill]) -> Int {
        // Determine the maximum row number needed
        timePills.count
    }

    func timePillForRowAndWeek(row: Int, week: Int) -> TimePill? {
        // Find the TimePill for a specific row and week, if it exists
        timePills.first { pill in
            pill.row == row && pill.startWeek == week
        }
    }
}

struct PillView: View {
    var pill: TimePill
    var totalWidth: CGFloat

    var body: some View {
        Text(pill.name)
            .frame(maxWidth: .infinity, maxHeight: 30)
            .background(pill.color)
            .cornerRadius(15)
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
