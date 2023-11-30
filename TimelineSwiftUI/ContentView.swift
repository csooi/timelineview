import SwiftUI

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading) {
                    ForEach(0..<maxRow(in: viewModel.timePills), id: \.self) { row in
                        HStack(alignment: .top, spacing: 1) {
                            ForEach(0..<42, id: \.self) { week in
                                ZStack(alignment: .center) {
                                    // The week background (can be empty or styled)
                                    Rectangle()
                                        .fill(Color.red.opacity(0.2))
                                        .frame(width: weekWidth(geometry.size.width), height: 30)
                                    // Overlay TimePill if it exists for this week and row
                                    if let pill = viewModel.timePillForRowAndWeek(row: row, week: week) {
                                        Rectangle()
                                            .fill(Color(pill.color ?? UIColor.red))
                                            .frame(width: CGFloat(pill.duration ?? 0) * weekWidth(geometry.size.width))
                                        Text((pill.body ?? "ttiel") + " \(pill.duration ?? 0)" )
                                            .font(.system(size: 20.0, weight: .bold))
                                            .padding(.horizontal, 20.0)
                                            .foregroundColor(.white)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .frame(width: CGFloat(pill.duration ?? 0) * weekWidth(geometry.size.width))
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

    func weekWidth(_ screenWidth: CGFloat) -> CGFloat {
        // Calculate the width for each week column
        screenWidth / 3
    }

    func maxRow(in timePills: [TimelinePill]) -> Int {
        // Determine the maximum row number needed
        timePills.count
    }
}

struct PillView: View {
    var pill: TimelinePill
    var totalWidth: CGFloat

    var body: some View {
        Text(pill.body ?? "body")
//            .frame(maxWidth: .infinity, maxHeight: 30)
            .background(Color(pill.color ?? UIColor.red))
            .cornerRadius(15)
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView(viewModel: TimelineViewModel())
    }
}
