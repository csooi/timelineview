
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
                    leadingPadding = 10.0
                } else {
                    print("--> Title - \(pill.body)")
                    print("--> start week - \(pill.startWeek)")
                    print("--> end week - \(pill.endWeek)")
                    print("--> current index - \(currentIndex)")
    
                    let startWeek = pill.startWeek ?? 1
                    let endWeek = pill.endWeek ?? 1
                    
                    let textWidth = pill.pillTextWidth ?? 10

                    let pillWidth = (CGFloat(pill.duration ?? 0) * weekWidth)
                
                        leadingPadding = (Double(((currentIndex) - (pill.startWeek ?? 1 ))) * weekWidth)
                        
                        //handle edge case where start week is greater than current index
                        //handle if offset goes beyond pillwidth
                      
                        print("--> pillWidth - \(pillWidth)")

                        print("--> textWidth - \(textWidth)")

                        if leadingPadding <= 0 {
                            leadingPadding = 20.0
                        } else if leadingPadding > (pillWidth-textWidth - 40) {
                            leadingPadding = pillWidth - textWidth - 40
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
      //  let myString = "Hello, World!"
           // .font(.system(size: 14.0, weight: .medium))
        let font = UIFont.systemFont(ofSize: 14.0, weight: .medium) // Replace with your desired font
        let size = self.size(withAttributes: [NSAttributedString.Key.font: font])

        print("Width of the string:", size.width)
        return size.width
    }
}
