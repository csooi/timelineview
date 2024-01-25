import SwiftUI
import LegacyScrollView

struct TimelineUIConstants {
    static let heightOfWeekView: CGFloat = 40
    static let segmentOffset: CGFloat = 10
    static let positionOfWeeksZstackElements: CGFloat = TimelineUIConstants.heightOfWeekView+8
}

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel
    @State var currentIndex: CGFloat = 0.0
    let bleen = UIColor(red: 0, green: 0.75, blue: 0.86, alpha: 1.0)
    let bombayLB = Color(red: 0.69, green: 0.69, blue: 0.71)
    let concreteLB = Color(red: 0.95, green: 0.95, blue: 0.97)
    @Environment(\.layoutDirection) var direction
    let totalCount = 43
    
    fileprivate func updateTextAlignment() {
        let index = Int(currentIndex)+1
        let pills = viewModel.timePills.filter { pill in
            // Assuming that the start and end week should fall within the specified range
            return (index >= pill.startWeek ?? 0 && index <= pill.endWeek ?? 0) ||
            (index - 1) == pill.startWeek ?? 0 ||
            (index - 1) == pill.endWeek ?? 0 ||
            (index + 1) == pill.startWeek ?? 0 ||
            (index + 1) == pill.endWeek ?? 0
        }
        // viewModel.updateTextAlignmentMetaData(pills, currentIndex: index)
        viewModel.updateOffsetValue(pills, currentIndex: index, weekWidth: weekWidth(UIScreen.main.bounds.size.width))
    }
    
    var body: some View {
        NavigationView {
            LegacyScrollViewReader { proxy in
                GeometryReader { geometry in
                    LegacyScrollView(.horizontal, showsIndicators: false) {
                        ZStack(alignment: .top) {
                            Circle()
                                .fill(Color(red: 1, green: 0.3, blue: 0.39))
                                .frame(width: 10)
                                .position(x: weekWidth(geometry.size.width) * CGFloat(viewModel.currentWeek + 1) + 10,
                                          y: 80)
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 2, height: geometry.size.height)
                                .position(x: weekWidth(geometry.size.width) * CGFloat(viewModel.currentWeek + 1) + 10,
                                          y: (geometry.size.height)/2 + 80)
                            VStack(alignment: .leading) {
                                Spacer().frame(height: 8)
                                HStack(alignment: .center, spacing: 0) {
                                    ForEach(0..<totalCount, id: \.self) { week in
                                        Text(week == 0 ? "<1" : "\(week)")
                                            .font(
                                                Font.system(size: week == Int(currentIndex) ? 28 : 18)
                                                    .weight(.semibold)
                                            )
                                        
                                            .frame(width: weekWidth(geometry.size.width))
                                            .foregroundColor(week == Int(currentIndex) ? Color(bleen) : bombayLB)
                                            .onTapGesture {
                                                scrollToIndexWith(scrollView: proxy.scrollView, index: CGFloat(week), animated: true)
                                            }
                                    }
                                }
                                Spacer().frame(height: 60)
                                LegacyScrollView(.vertical, showsIndicators: true) {
                                    ForEach(0..<maxRow(in: viewModel.timePills), id: \.self) { row in
                                        HStack(alignment: .top, spacing: 0) {
                                            ForEach(0..<totalCount, id: \.self) { week in
                                                ZStack(alignment: .leading) {
                                                    
                                                    // The week background (can be empty or styled)
                                                    Rectangle()
                                                        .fill(Color.clear)
                                                        .frame(width: (viewModel.isOccupying(week: week,
                                                                                             row: row)) ? 0.0 : weekWidth(geometry.size.width))
                                                    // Overlay TimePill if it exists for this week and row
                                                    if let index = viewModel.timePillForRowAndWeek(row: row, week: week) {
                                                        PillView(pill: $viewModel.timePills[index],
                                                                 widthPerWeek: weekWidth(geometry.size.width))
                                                        .frame(height: 62.0)
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, geometry.size.width/4 + 5)
                            .onAppear {
                                scrollToIndexWith(scrollView: proxy.scrollView, index: CGFloat(viewModel.currentWeek), animated: false)
                            }
                        }
                    }
                    .onEndDragging { scrollView in
                        snapWith(scrollView: scrollView)
                       // updateTextAlignment()
//                        if let pills = scrollView.subviews as? PillView {
//
//                        }
//                        scrollView.visibleRect.
                    }.onEndDecelerating { scrollView in
                        snapWith(scrollView: scrollView)
                        //updateTextAlignment()
                        
                    }
                    .background(
                        VStack {
                            Rectangle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.white, Color(red: 0.95, green: 0.95, blue: 0.97).opacity(1), Color.white]),
                                                     startPoint: .top,
                                                     endPoint: .bottom))
                                .frame(width: 2,
                                       height: geometry.size.height)
                                .position(x: geometry.size.width/4 + 5,
                                          y: geometry.size.height/2)
                                .offset(y: 0)
                            Rectangle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.white, Color(red: 0.95, green: 0.95, blue: 0.97).opacity(1), Color.white]),
                                                     startPoint: .top,
                                                     endPoint: .bottom))
                                .frame(width: 2, height: geometry.size.height)
                                .position(x: geometry.size.width/4 * 3 - 5, y: 0)
                                .offset(y: 0)
                        }
                    )
                    ZStack {
                        Rectangle()
                            .frame(width:geometry.size.width , height: 3)
                            .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.97))
                            .position(CGPoint(x: geometry.size.width/2,
                                              y: TimelineUIConstants.positionOfWeeksZstackElements ))
                        Text("WEEKS")
                            .font(.system(size: 12.0, weight: .bold))
                            .foregroundColor(Color(bleen))
                            .background(Color.white)
                            .position(CGPoint(x: geometry.size.width/2 ,
                                              y: TimelineUIConstants.positionOfWeeksZstackElements))
                            .padding([.leading, .trailing], 4)
                        
                    }
                    Text("11 Dec - 18 Dec") //TBD: calculate and update
                        .font(Font.custom("SF Pro", size: 10))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding([.leading, .trailing], 10)
                        .padding([.top, .bottom], 4)
                    
                        .background(
                            Capsule()
                                .fill(concreteLB)
                                .frame(width: 100)
                        )
                        .position(CGPoint(x: geometry.size.width/2 ,
                                          y: TimelineUIConstants.positionOfWeeksZstackElements+30))
                }
            }
            .ignoresSafeArea()
            .navigationBarTitle("Timeline")
            .navigationBarTitleDisplayMode(.inline)
            //        .offset(y: 80)
        }
    }

    func snapWith(scrollView: UIScrollView) {
        let segmentWidth = UIScreen.main.bounds.size.width / 2 - 10
        let offset = scrollView.contentOffset.x
        let index = round(offset / segmentWidth)
        let newOffset = index * segmentWidth
        if direction == .rightToLeft {
            currentIndex = (CGFloat(totalCount + 1) -  index)
        } else {
            currentIndex = index
        }
        
        updateTextAlignment()

        UIView.animate(withDuration: 0.4, animations: {
            scrollView.contentOffset = CGPoint(x: newOffset, y: 0)
        })
    }
    
    func scrollToIndexWith(scrollView: UIScrollView, index: CGFloat, animated: Bool) {
        let segmentWidth = UIScreen.main.bounds.size.width / 2 - 10
        var offsetIndex = index
        
        if direction == .rightToLeft {
            offsetIndex = (CGFloat(totalCount + 1) -  index)
        }
        
        let newOffset = offsetIndex * segmentWidth
        
        
        currentIndex = index
        withAnimation(.default.delay(0.3)) {
            scrollView.setContentOffset(CGPoint(x: newOffset, y: 0), animated: animated)
        }
    }
    
    func weekWidth(_ screenWidth: CGFloat) -> CGFloat {
        // Calculate the width for each week column
        screenWidth / 2  - 10
    }
    
    func maxRow(in timePills: [TimelinePill]) -> Int {
        // Determine the maximum row number needed
        timePills.count
    }
}

struct PillView: View {
    @Binding var pill: TimelinePill
    @State var widthPerWeek: CGFloat
    @State private var pillGeometries: [UUID: CGRect] = [:]
    var body: some View {
        ZStack {
            Rectangle()
                .fill(pill.color ?? Color.blue).opacity(0.12)
                .cornerRadius(8)
                .padding(.horizontal, 4.0)
                .frame(width: CGFloat(pill.duration ?? 0) * widthPerWeek)
                .onTapGesture {
                    print("Tapped")
                }
                .background(GeometryReader { geometry in
                    Color.white
                        .onChange(of: geometry.frame(in: .global)) { newFrame in
                            pillGeometries[pill.id] = newFrame
                        }
                })
            
        }
            Text((pill.body ?? ""))
                .font(.system(size: 14.0, weight: .medium))
                .foregroundColor(pill.color ?? Color.blue)
                .padding(.vertical, 10.0)
                .padding(.leading, xPosition())
                .animation(animationText())
                .padding(.trailing, 10.0)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: widthOfText(pill: pill), alignment: alignmentC())
                //.background(Color.gray)
                .lineLimit(3)
    }
    
    func alignmentC() -> Alignment {
        if pill.startWeek == pill.endWeek {
            return .center
        }
        return .leading
    }
    func xPosition() -> CGFloat {
//        if pill.startWeek == pill.endWeek {
//            return widthPerWeek/2.0
//        }
        return pill.leadingPadding
    }
    
    func animationText() -> Animation? {
        if pill.startWeek == pill.endWeek {
            return nil
        }
        return .linear
    }
    func widthOfText(pill: TimelinePill) -> CGFloat {
        CGFloat(pill.duration ?? 0) * widthPerWeek
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
            .previewDevice("iPhone SE (2nd generation)")
        
        TimelineView(viewModel: TimelineViewModel())
            .previewDevice("iPhone 13 Pro")
        
        TimelineView(viewModel: TimelineViewModel())
            .previewDevice("iPhone 14 Pro Max")
    }
}

struct TextWidthPreferenceKey: PreferenceKey {
    static var defaultValue: [CGFloat] = []

    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value += nextValue()
    }
}

struct ViewWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
