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
    @State private var isScrolling = false

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
                                .position(x: weekWidth(geometry.size.width) * CGFloat(viewModel.currentWeek + 1),
                                          y: 80)
                            Rectangle()
                                .fill(Color.red)
                              .frame(width: 2, height: geometry.size.height)
                              .position(x: weekWidth(geometry.size.width) * CGFloat(viewModel.currentWeek + 1),
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
                                                updateTextAlignment()
                                                //Should find a better way to update the state of isscrolling
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    isScrolling = false
                                                }
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
                                                        PillView(currentWeek: $currentIndex, pill: $viewModel.timePills[index],
                                                                 isScrolling: $isScrolling,
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
                                scrollToIndexWith(scrollView: proxy.scrollView,
                                                  index: CGFloat(viewModel.currentWeek),
                                                  animated: false)
                                updateTextAlignment()
                                isScrolling = false
                            }
                        }
                    }
                    .onEndDragging { scrollView in
                        snapWith(scrollView: scrollView)
                        isScrolling = false
                       // updateTextAlignment()
                    }.onEndDecelerating { scrollView in
                        snapWith(scrollView: scrollView)
                        //updateTextAlignment()
                        isScrolling = false
                    }
                    .onScroll { scrollView in
                        isScrolling = true
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
                                .position(x: (geometry.size.width/4 * 3) + 5, y: 0)
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
//            .ignoresSafeArea()
            .navigationBarTitle("Timeline")
            .navigationBarTitleDisplayMode(.inline)
            //        .offset(y: 80)
        }
    }

    func snapWith(scrollView: UIScrollView) {
        let segmentWidth = UIScreen.main.bounds.size.width / 2
        let offset = scrollView.contentOffset.x
        let index = round(offset / segmentWidth)
        let newOffset = index * segmentWidth
        if direction == .rightToLeft {
            currentIndex = (CGFloat(totalCount + 1) -  index)
        } else {
            currentIndex = index
        }
        
        updateTextAlignment()

        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentOffset = CGPoint(x: newOffset, y: 0)
        })
    }
    
    func scrollToIndexWith(scrollView: UIScrollView, index: CGFloat, animated: Bool) {
        let segmentWidth = UIScreen.main.bounds.size.width / 2
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
        screenWidth / 2
    }
    
    func maxRow(in timePills: [TimelinePill]) -> Int {
        // Determine the maximum row number needed
        timePills.count
    }
}

struct PillView: View {
    @Binding var currentWeek: CGFloat
    @Binding var pill: TimelinePill
    @Binding var isScrolling: Bool

    @State var widthPerWeek: CGFloat
    @State private var pillGeometries: [UUID: CGRect] = [:]
    @State var padding: CGFloat = 20
    @State private var alpha: Double = 1.0

    var isSingleWeekWidthPill: Bool {
        pill.startWeek == pill.endWeek
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
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
                        .padding(.horizontal, 4.0)
                        .onChange(of: geometry.frame(in: .global)) { newFrame in
                            pillGeometries[pill.id] = newFrame
                        }
                })
            HStack(spacing: 0.0) {
                Text((pill.body ?? ""))
                    .font(.system(size: 14.0, weight: .medium))
                    .foregroundColor(pill.color ?? Color.blue)
                    .padding(.vertical, 10.0)
                    .padding(.leading, 10.0)
                    .padding(.trailing, 10.0)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: widthOfText(), alignment: alignmentC())
                    .opacity(alpha)
    //                .onChange(of: pill.leadingPadding, perform: { newValue in
    //                    withAnimation(.easeIn(duration: 0.3)) {
    //                        self.padding = xPosition()
    //                    }
    //                })
                    .onChange(of: isScrolling, perform: { newValue in
                        withAnimation(.easeIn(duration: 0.3)) {
                            self.alpha = !isScrolling || isSingleWeekWidthPill ? 1.0 : 0.4
                        }
                    })
                    //.animation(animationText())
                    
                    //.background(Color.gray)
                    .lineLimit(3)
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 8, height: 14)
                    .padding(.trailing, 10.0)
                    .foregroundColor(pill.color ?? .gray)
            }
            .padding(.leading, padding)
            .padding(.trailing, 10.0) //dybamically set trailing space
            .frame(width: widthOfPill(), alignment: .leading)
            //.background(Color.green)
            .onChange(of: pill.leadingPadding, perform: { newValue in
                withAnimation(.easeIn(duration: 0.3)) {
                    self.padding = xPosition()
                }
            })
        }
//        HStack(spacing: 0.0) {
//            Text((pill.body ?? ""))
//                .font(.system(size: 14.0, weight: .medium))
//                .foregroundColor(pill.color ?? Color.blue)
//                .padding(.vertical, 10.0)
//                .padding(.leading, 10.0)
//                .padding(.trailing, 10.0)
//                .fixedSize(horizontal: false, vertical: true)
//                .frame(width: widthOfText(), alignment: alignmentC())
//                .opacity(alpha)
////                .onChange(of: pill.leadingPadding, perform: { newValue in
////                    withAnimation(.easeIn(duration: 0.3)) {
////                        self.padding = xPosition()
////                    }
////                })
//                .onChange(of: isScrolling, perform: { newValue in
//                    withAnimation(.easeIn(duration: 0.3)) {
//                        self.alpha = !isScrolling || isSingleWeekWidthPill ? 1.0 : 0.4
//                    }
//                })
//                //.animation(animationText())
//
//                .background(Color.gray)
//                .lineLimit(3)
//
//            Image(systemName: "chevron.right")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 8, height: 14)
//                .padding(.trailing, 10.0)
//                .foregroundColor(pill.color ?? .gray)
//        }
//        .padding(.leading, 100)
//        .frame(width: widthOfPill())
//        .background(Color.green)
//        .onChange(of: pill.leadingPadding, perform: { newValue in
//            withAnimation(.easeIn(duration: 0.3)) {
//                self.padding = xPosition()
//            }
//        })
        
        //.background(Color.green)
    }
    
    func widthOfText() -> CGFloat? {
        if isSingleWeekWidthPill {
            return CGFloat(pill.duration ?? 0) * widthPerWeek - 30
        }
        return nil
//        if pill.pillTextWidth ?? 0 > UIScreen.main.bounds.size.width - 40 {
//            return UIScreen.main.bounds.size.width - 40 - 30
//        }
//        return (pill.pillTextWidth ?? 0) + 30 //here 20 is lead, trail padding and 30 is arrow width
    }
    func alignmentC() -> Alignment {
        if pill.startWeek == pill.endWeek {
            return .center
        }
//        print("--> title - \(pill.body)")
//        print("--> startWeek - \(pill.startWeek)")
//        print("--> endWeek - \(pill.endWeek)")
//        print("--> currentWeek - \(currentWeek)")

        if pill.endWeek == Int(currentWeek+1) || pill.endWeek == Int(currentWeek-1) || pill.endWeek == Int(currentWeek) {
            return .leading
        }
        return .trailing
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
        return .easeIn(duration: 0.3)
    }
    func widthOfPill() -> CGFloat {
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
