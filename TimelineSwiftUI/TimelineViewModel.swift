
import Foundation
import SwiftUI

class TimelineViewModel: ObservableObject {
    @Published var timePills: [TimelinePill] = []
    var categoryMetaData: [CategoryMetadata] = []
    private var pillRowMapping: [UUID: Int] = [:]

    var currentWeek: Int = 12

    init() {
        loadTimeline()
        calculateRows(for: timePills, withPriority: categoryMetaData)
    }

    func updateTextAlignmentMetaData(_ pills: [TimelinePill], currentIndex: Int) {
        for pill in pills {
            if let row = timePills.firstIndex(where: {$0.id == pill.id}) {
                var alignment: Alignment = .center
                if pill.startWeek == pill.endWeek {
                    print("-->\(row) alignment - center")
                    alignment = .leading
                }
                if (pill.endWeek ?? 1) - currentIndex > currentIndex - (pill.startWeek ?? 1) {
                    print("-->\(row) alignment - trailing")
                    alignment = .trailing
                }
                timePills[row].textAligment = alignment
            }
        }
    }

    func updateOffsetValue(_ pills: [TimelinePill], currentIndex: Int, weekWidth: CGFloat)  {
        for pill in pills {
            if let row = timePills.firstIndex(where: {$0.id == pill.id}) {
                var leadingPadding = 0.0
                var textWidth = widthOfText(pill: pill, currentWeek: currentIndex)

                if pill.startWeek == pill.endWeek {
                    leadingPadding = 10.0
                } else {

                    let startWeek = pill.startWeek ?? 1
                    let endWeek = pill.endWeek ?? 1
                    print("--> Title - \(pill.body)")
                    print("--> start week - \(pill.startWeek)")
                    print("--> end week - \(pill.endWeek)")
                    print("--> current week - \(currentIndex)")
                    
                    let pillWidth = (CGFloat(pill.duration ?? 0) * weekWidth)
                    print("--> pillWidth - \(pillWidth)")
                    print("--> textWidth - \(textWidth)")
                    print("--> weekWidth - \(weekWidth)")

                    leadingPadding = (Double(((currentIndex) - (startWeek))) * weekWidth) - (weekWidth/2)
                    
//                    if startWeek == currentIndex {
//                        textWidth = UIScreen.main.bounds.size.width * 0.75
//                    } else if endWeek == currentIndex {
//                        textWidth = UIScreen.main.bounds.size.width * 0.25
//                    }
                    
//                    if textWidth < weekWidth {
//                        leadingPadding = leadingPadding + (weekWidth - textWidth)/2
//                    } else if textWidth > weekWidth {
//                        leadingPadding = leadingPadding - (textWidth - weekWidth)/2
//                    }
                   // leadingPadding = leadingPadding - (weekWidth - textWidth)/2
                   // leadingPadding = leadingPadding - 30
                    //adjust trailing space of 
//                    //handle the edge cases
                    if leadingPadding < 10 {
                        leadingPadding = 10
                    } else if leadingPadding > (pillWidth-textWidth-30) {
                        leadingPadding = pillWidth - textWidth - 30
                    }
                    print("--> leadingPadding - \(leadingPadding)")
                }
                
                timePills[row].leadingPadding = leadingPadding
                timePills[row].pillTextWidth = textWidth
                timePills[row].textContentAligment = textContentAlignment(pill: pill, currentWeek: currentIndex)
                timePills[row].textAligment = textViewAlignment(pill: pill, currentWeek: currentIndex)
                let trailingPadding = trailingPadding(pill: pill, currentWeek: currentIndex)
               // print("--> trailingPadding - \(trailingPadding)")
               // timePills[row].trailingPadding = trailingPadding
            }
        }
    }
    
    private func loadTimeline() {
        guard let timeline = TimelineHelper().loadTimelineJSON() else {
            return
        }
        timePills = TimelineHelper().fillTimelinePillMetaDataAndSort(timeline: timeline)
        categoryMetaData = timeline.categoryMetaData ?? []
    }
    private func calculateRows(for pills: [TimelinePill],
                               withPriority priorityCategories: [CategoryMetadata]) {
        for pill in pills {
            let row = TimelineHelper.determineRow(for: pill, in: pills, withPriority: priorityCategories)
            pillRowMapping[pill.id] = row
            print("Pill \(pill.body ?? "") assigned to row \(row) from week \(pill.startWeek!) to \(pill.endWeek!)")
        }
    }
    
    func timePillForRowAndWeek(row: Int, week: Int) -> Int? {
        timePills.firstIndex { pill in
            let startWeek = (pill.startWeek ?? 1) - 1
            guard let pillRow = pillRowMapping[pill.id] else {
                return false
            }
            return pillRow == row && startWeek == week
        }
    }

    //    func timePillForRowAndWeek(row: Int, week: Int) -> TimelinePill? {
    //        timePills.first { pill in
    //            let startWeek = (pill.startWeek ?? 1) - 1
    //            guard let pillRow = pillRowMapping[pill.id] else {
    //                return false
    //            }
    //            return pillRow == row && startWeek == week
    //        }
    //    }
    func isOccupying(week: Int, row: Int) -> Bool {
        return timePills.contains { pill in
            let startWeek = (pill.startWeek ?? 1) - 1
            guard let pillRow = pillRowMapping[pill.id],
                  let endWeek = pill.endWeek else {
                return false
            }
            return pillRow == row && week-1 > startWeek && week <= endWeek
        }
    }
    
    func widthOfText(pill: TimelinePill, currentWeek: Int) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.size.width
        if pill.startWeek == pill.endWeek {
            return CGFloat(pill.duration ?? 0) * (screenWidth/2)-30
        }
        if pill.startWeek == Int(currentWeek) || pill.endWeek == Int(currentWeek) || pill.endWeek == Int(currentWeek-1) || pill.startWeek == Int(currentWeek+1) {
            return screenWidth * 0.75 - 30
        }
        return screenWidth - 30
    }
    
    func trailingPadding(pill: TimelinePill, currentWeek: Int) -> CGFloat {
        if pill.startWeek == pill.endWeek {
            return 10.0
        }
        let widthOfText = widthOfText(pill: pill, currentWeek: currentWeek)
        let widthOfPill = CGFloat(pill.duration ?? 0) * (UIScreen.main.bounds.size.width/2) //should make a common code to get week width
        var trailingPadding = widthOfPill - pill.leadingPadding - widthOfText
        if trailingPadding < 0 {
            trailingPadding = 10.0
        }
        return trailingPadding
    }
    
    fileprivate func alignText(_ pill: TimelinePill, _ currentWeek: Int) -> Alignment {
        if pill.startWeek == pill.endWeek {
            return .leading
        }
        if pill.endWeek == currentWeek-1 || pill.endWeek == currentWeek {
            return .trailing
        }
        if pill.startWeek == currentWeek || pill.startWeek == currentWeek+1 {
            return .leading
        }
        return .center
    }
    
    func textViewAlignment(pill: TimelinePill, currentWeek: Int) -> Alignment {
        return alignText(pill, currentWeek)
    }
    
    func textContentAlignment(pill: TimelinePill, currentWeek: Int) -> TextAlignment {
        return alignText(pill, currentWeek).toTextAlignment()
    }
}


extension String {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.systemFont(ofSize: 17)],
            context: nil
        )
        return boundingBox.height
    }
    
    func widthOfText() -> CGFloat {
        let font = UIFont.systemFont(ofSize: 14.0, weight: .medium) // we can pass the font here
        //this font sytle should be same as pill text font
        let size = self.size(withAttributes: [NSAttributedString.Key.font: font])
        return size.width
    }
}

extension Alignment {
    func toTextAlignment() -> TextAlignment {
        switch self {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        default:
            return .center
        }
    }
}
