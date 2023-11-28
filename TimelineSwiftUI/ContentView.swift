import SwiftUI

struct TimelineView: View {
    let timePills: [TimelinePill] = TimelineHelper().sort()
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading) {
                    ForEach(0..<maxRow(in: timePills), id: \.self) { row in
                        HStack(spacing: 1) {
                            ForEach(0..<42, id: \.self) { week in
                                ZStack {
                                    // The week background (can be empty or styled)
                                    Rectangle()
                                        .fill(Color.red.opacity(0.2))
                                        .frame(width: weekWidth(geometry.size.width), height: 30)
                                    // Overlay TimePill if it exists for this week and row
                                    if let pill = timePillForRowAndWeek(row: row, week: week) {
                                        Rectangle()
                                            .fill(Color(pill.color ?? UIColor.red))
                                            .frame(width: CGFloat(pill.duration ?? 0) * weekWidth(geometry.size.width),
                                               height: 30)
                                        Text(pill.body ?? "ttiel")
                                        .foregroundColor(.white)
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

    func maxRow(in timePills: [TimelinePill]) -> Int {
        // Determine the maximum row number needed
        timePills.count
    }

    func timePillForRowAndWeek(row: Int, week: Int) -> TimelinePill? {
        // Find the TimePill for a specific row and week, if it exists
        timePills.first { pill in
            pill.row == row && pill.startDay == week // TBD: this needs to be adjusted
        }
    }
}

struct PillView: View {
    var pill: TimelinePill
    var totalWidth: CGFloat

    var body: some View {
        Text(pill.body ?? "body")
            .frame(maxWidth: .infinity, maxHeight: 30)
            .background(Color(pill.color ?? UIColor.red))
            .cornerRadius(15)
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
