import SwiftUI

struct TimelineUIConstants {
    static let heightOfWeekView: CGFloat = 40
    static let positionOfWeeksZstackElements: CGFloat = TimelineUIConstants.heightOfWeekView+8
}

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .frame(width:geometry.size.width , height: 2)
                    .foregroundColor(Color.gray)
                    .position(CGPoint(x: geometry.size.width/2 ,
                                      y: TimelineUIConstants.positionOfWeeksZstackElements ))
                Text("WEEKS")
                    .font(.system(size: 20.0, weight: .bold))
                    .foregroundColor(.blue)
                    .background(Color.white)
                    .position(CGPoint(x: geometry.size.width/2 ,
                                      y: TimelineUIConstants.positionOfWeeksZstackElements))
                    .padding([.leading, .trailing], 4)
                
                Text("11 Dec - 18 Dec") //TBD: calculate and update
                    .foregroundColor(.black)
                    .padding([.leading, .trailing], 10)
                    .padding([.top, .bottom], 4)

                    .background(
                        Capsule()
                            .fill(Color.gray)
                    )
                    .position(CGPoint(x: geometry.size.width/2 ,
                                      y: TimelineUIConstants.positionOfWeeksZstackElements+30))
                
            }
            //.background(Color.green)
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading) {
                    //Week header
                    HStack {
                        ForEach(0..<42, id: \.self) { week in
                            Text("\(week)")
                                .frame(width: weekWidth(geometry.size.width), height: TimelineUIConstants.heightOfWeekView)
                                .foregroundColor(.black)
                                .onTapGesture {
                                    print("week tapped")
                                }
                        }
                    }
                    Spacer().frame(height: 80)
                    ForEach(0..<maxRow(in: viewModel.timePills), id: \.self) { row in
                        HStack(alignment: .top, spacing: 1) {
                            ForEach(0..<42, id: \.self) { week in
                                ZStack(alignment: .center) {
                                    // The week background (can be empty or styled)
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: weekWidth(geometry.size.width), height: 30)
                                    // Overlay TimePill if it exists for this week and row
                                    if let pill = viewModel.timePillForRowAndWeek(row: row, week: week) {
                                        Rectangle()
                                            .fill(Color(pill.color ?? UIColor.red))
                                            .cornerRadius(10)
                                            .frame(width: CGFloat(pill.duration ?? 0)/7.0 * weekWidth(geometry.size.width))
                                            .onTapGesture {
                                                print("Tapped")
                                            }
                                        Text(pill.body ?? "ttiel")
                                            .font(.system(size: 20.0, weight: .bold))
                                            .padding(.horizontal, 10.0)
                                            .foregroundColor(.white)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .frame(width: CGFloat(pill.duration ?? 0)/7.0 * weekWidth(geometry.size.width))
                                            .padding(.vertical, 20.0)
                                            .lineLimit(3)
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

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView(viewModel: TimelineViewModel())
    }
}
