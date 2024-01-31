
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
                if pill.startWeek == pill.endWeek {
                    leadingPadding = 0.0
                } else {

                    let startWeek = pill.startWeek ?? 1
                    let endWeek = pill.endWeek ?? 1
                    print("--> Title - \(pill.body)")
                    print("--> start week - \(pill.startWeek)")
                    print("--> end week - \(pill.endWeek)")
                    print("--> current week - \(currentIndex)")
                    
                    var textWidth = pill.pillTextWidth ?? 10
                    let pillWidth = (CGFloat(pill.duration ?? 0) * weekWidth)
                    print("--> pillWidth - \(pillWidth)")
                    print("--> textWidth - \(textWidth)")
                    print("--> weekWidth - \(weekWidth)")

                    leadingPadding = (Double(((currentIndex) - (startWeek))) * weekWidth)
                    
//
//                    if startWeek == currentIndex {
//                        textWidth = UIScreen.main.bounds.size.width/2
//                    }
                    
                    if textWidth < weekWidth {
                        leadingPadding = leadingPadding + (weekWidth - textWidth)/2
                    } else if textWidth > weekWidth {
                        leadingPadding = leadingPadding - (textWidth - weekWidth)/2
                    }
                    
                    //adjust trailing space of 
//                    //handle the edge cases
                    if leadingPadding < 0 {
                        leadingPadding = 0
                    } else if leadingPadding > (pillWidth-textWidth - 30) {
                        leadingPadding = pillWidth - textWidth - 30
                    }
                    print("--> leadingPadding - \(leadingPadding)")
                }
                
                timePills[row].leadingPadding = leadingPadding
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
