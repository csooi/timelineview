import SwiftUI
import LegacyScrollView

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
            LegacyScrollView(.horizontal, showsIndicators: false) {
                ZStack {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 2, height: geometry.size.height)
                        .position(x: weekWidth(geometry.size.width) * CGFloat(viewModel.currentWeek + 1) + weekWidth(geometry.size.width)/2.0,
                                  y: geometry.size.height / 2)
                        .offset(y: 210)
                    VStack(alignment: .leading) {
                        //Week header
                        
                        Spacer().frame(height: 120)
                        HStack(spacing: 0) {
                            ForEach(0..<43, id: \.self) { week in
                                Text("\(week)")
                                    .frame(width: weekWidth(geometry.size.width))
                                    .foregroundColor(.black)
                                    .onTapGesture {
                                        print("week tapped")
                                    }
                            }
                        }
                        Spacer().frame(height: 80)
                        ForEach(0..<maxRow(in: viewModel.timePills), id: \.self) { row in
                            HStack(alignment: .top, spacing: 0) {
                                ForEach(0..<43, id: \.self) { week in
                                    ZStack(alignment: .center) {
                                        
                                        // The week background (can be empty or styled)
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(width: (viewModel.isOccupying(week: week,
                                                                                 row: row)) ? 0.0 : weekWidth(geometry.size.width))
                                        // Overlay TimePill if it exists for this week and row
                                        if let pill = viewModel.timePillForRowAndWeek(row: row, week: week) {
                                            PillView(pill: pill,
                                                     widthPerWeek: weekWidth(geometry.size.width))
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }.padding(.horizontal, geometry.size.width/3)
                }
            }
            .onEndDragging { scrollView in
                snapWith(scrollView: scrollView)
            }.onEndDecelerating { scrollView in
                snapWith(scrollView: scrollView)
            }
            .background(
                VStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 2, height: geometry.size.height)
                        .position(x: geometry.size.width/3, y: geometry.size.height / 2)
                        .offset(y: 80)
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 2, height: geometry.size.height)
                        .position(x: geometry.size.width/3 * 2, y: 0)
                        .offset(y: 80)
                }
            )
        }
    }
    
    func snapWith(scrollView: UIScrollView) {
        let segmentWidth = UIScreen.main.bounds.size.width / 3
        let offset = scrollView.contentOffset.x
        let index = round(offset / segmentWidth)
        let newOffset = index * segmentWidth
        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentOffset = CGPoint(x: newOffset, y: 0)
        })
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
    @State var pill: TimelinePill
    @State var widthPerWeek: CGFloat
    @State private var pillGeometries: [UUID: CGRect] = [:]
    var body: some View {
        Rectangle()
            .fill(Color(pill.color ?? UIColor.red))
            .cornerRadius(10)
            .frame(width: CGFloat(Int(pill.duration ?? 0)/7) * widthPerWeek)
            .onTapGesture {
                print("Tapped")
            }
            .background(GeometryReader { geometry in
                Color.clear
                    .onChange(of: geometry.frame(in: .global)) { newFrame in
                        pillGeometries[pill.id] = newFrame
                    }
            })
        Text((pill.body ?? "ttiel"))
            .font(.system(size: 20.0, weight: .bold))
            .padding(.horizontal, 10.0)
            .foregroundColor(.white)
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: (CGFloat(Int(pill.duration ?? 0)/7).rounded() * widthPerWeek))
            .padding(.vertical, 20.0)
            .lineLimit(3)
    }
    
    func pillOffsetArea(_ pillFrame: CGRect?) -> CGFloat {
        if isPillVisible(pillFrame) {
            return pillFrame?.minX ?? 0.0
        }
        return 0.0
    }
    
    func isPillVisible(_ pillFrame: CGRect?) -> Bool {
        guard let pillFrame else { return false }
        let screenRect = UIScreen.main.bounds
        return pillFrame.intersects(screenRect)
    }
    
}
struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView(viewModel: TimelineViewModel())
    }
}
