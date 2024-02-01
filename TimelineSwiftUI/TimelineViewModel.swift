
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

    func filterVisibleTextPillsAndUpdateMetaData(currentIndex: CGFloat) {
        let index = Int(currentIndex)+1
        let pills = timePills.filter { pill in
            // Assuming that the start and end week should fall within the specified range
            return (index >= pill.startWeek ?? 0 && index <= pill.endWeek ?? 0) ||
            (index - 1) == pill.startWeek ?? 0 ||
            (index - 1) == pill.endWeek ?? 0 ||
            (index + 1) == pill.startWeek ?? 0 ||
            (index + 1) == pill.endWeek ?? 0
        }
        updateTextPillMetaDataOnScrollStops(pills, currentIndex: index)
    }
    
    fileprivate func updateTextPillMetaDataOnScrollStops(_ pills: [TimelinePill], currentIndex: Int)  {
        for pill in pills {
            if let row = timePills.firstIndex(where: {$0.id == pill.id}) {
                var leadingPadding = 0.0
                let weekWidth = UIScreen.main.bounds.size.width/2 //TBD: make it genric
                let textWidth = widthOfText(pill: pill, currentWeek: currentIndex)
                if pill.startWeek == pill.endWeek {
                    leadingPadding = 10.0
                } else {
                    let startWeek = pill.startWeek ?? 1
                    let pillWidth = (CGFloat(pill.duration ?? 0) * weekWidth) //TBD: make it generic
                    leadingPadding = (Double(((currentIndex) - (startWeek))) * weekWidth) - (weekWidth/2)
                    //handle the edge cases
                    if leadingPadding < 10 {
                        leadingPadding = 10
                    } else if leadingPadding > (pillWidth-textWidth-30) {
                        leadingPadding = pillWidth - textWidth - 30
                    }
                }
                
                timePills[row].leadingPadding = leadingPadding
                timePills[row].pillTextWidth = textWidth
                timePills[row].textContentAligment = textContentAlignment(pill: pill, currentWeek: currentIndex)
                timePills[row].textAligment = textViewAlignment(pill: pill, currentWeek: currentIndex)
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
