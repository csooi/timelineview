import SwiftUI

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    var body: some View {
        LazyHStack(alignment: .top, spacing: 0) {
            ForEach(0..<42) { week in
                VStack(alignment: .leading) {
                    Text("Week \(week + 1)").frame(maxWidth: .infinity, alignment: .center)
                    
                    HStack(alignment: .center, spacing: 1) {
                        ZStack() {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: UIScreen.main.bounds.width)
                            VStack(alignment: .leading) {
                                ForEach(0..<maxRow(in: viewModel.timePills), id: \.self) { row in
                                    if let pill = viewModel.timePillForRowAndWeek(row: row, week: week) {
                                        Text((pill.body ?? "ttiel") + " \(pill.duration ?? 0)" )
                                            .font(.system(size: 20.0, weight: .bold))
                                            .padding(.horizontal, 10.0)
                                            .foregroundColor(.white)
                                            .fixedSize(horizontal: false, vertical: false)
                                            .frame(width: CGFloat(pill.duration ?? 0)/7.0 * weekWidth())
                                            .padding(.vertical, 20.0)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(3)
                                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(pill.color ?? UIColor.red)))
                                            .onTapGesture {
                                                print("Tapped")
                                            }
                                    }
                                }
                                
                                
                            }
                        }
                    }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                }
            }
            
        }.modifier(ScrollingHStackModifier(
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
        (screenWidth ?? 0) / 3
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
