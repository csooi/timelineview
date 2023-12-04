import SwiftUI

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    var body: some View {
            LazyHStack(spacing: 0) {
                ForEach(0..<42) { week in
                    HStack(alignment: .center, spacing: 0) {
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: UIScreen.main.bounds.width)
                            VStack(alignment: .leading) {
                                ForEach(0..<maxRow(in: viewModel.timePills), id: \.self) { row in
                                    if let pill = viewModel.timePillForRowAndWeek(row: row, week: week) {
                                        Text((pill.body ?? "ttiel") + " \(pill.duration ?? 0)" )
                                            .font(.system(size: 20.0, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: (CGFloat(pill.duration ?? 0) / 7.0) * weekWidth())
                                            .padding(.vertical, 20.0)
                                            .padding(.horizontal, 20.0)
                                            .lineLimit(3)
                                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(pill.color ?? UIColor.red)))
                                            .onTapGesture {
                                                print("Tapped")
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        
        .modifier(ScrollingHStackModifier(
            items: 42,
            itemWidth: UIScreen.main.bounds.width,
            itemSpacing: 0))
        
//        GeometryReader { geometry in
//            ScrollView(.horizontal, showsIndicators: false) {
//                VStack(alignment: .leading) {
//                    ForEach(0..<maxRow(in: viewModel.timePills), id: \.self) { row in
//                        HStack(alignment: .top, spacing: 1) {
//                            ForEach(0..<42, id: \.self) { week in
//                                ZStack(alignment: .center) {
//                                    // The week background (can be empty or styled)
//                                    Rectangle()
//                                        .fill(Color.clear)
//                                        .frame(width: weekWidth(geometry.size.width), height: 30)
//                                    // Overlay TimePill if it exists for this week and row
//                                    if let pill = viewModel.timePillForRowAndWeek(row: row, week: week) {
//                                            Rectangle()
//                                                .fill(Color(pill.color ?? UIColor.red))
//                                                .cornerRadius(10)
//                                                .frame(width: CGFloat(pill.duration ?? 0)/7.0 * weekWidth(geometry.size.width))
//                                                .onTapGesture {
//                                                    print("Tapped")
//                                                }
//                                            Text(pill.body ?? "ttiel")
//                                                .font(.system(size: 20.0, weight: .bold))
//                                                .padding(.horizontal, 10.0)
//                                                .foregroundColor(.white)
//                                                .fixedSize(horizontal: false, vertical: true)
//                                                .frame(width: CGFloat(pill.duration ?? 0)/7.0 * weekWidth(geometry.size.width))
//                                                .padding(.vertical, 20.0)
//                                                .lineLimit(3)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }

    }

    func weekWidth(_ screenWidth: CGFloat? = UIScreen.main.bounds.width) -> CGFloat {
        // Calculate the width for each week column
        (screenWidth ?? 0) / 7
    }

    func maxRow(in timePills: [TimelinePill]) -> Int {
        // Determine the maximum row number needed
        timePills.count
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView(viewModel: TimelineViewModel())
    }
}
