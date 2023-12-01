
import Foundation
import SwiftUI

class TimelineViewModel: ObservableObject {
    @Published var timePills: [TimelinePill] = []
    var priorityCategories: [String] = []
    private var pillRowMapping: [UUID: Int] = [:]

    init() {
        loadTimeline()
        calculateRows(for: timePills, withPriority: priorityCategories)
    }
    
    private func loadTimeline() {
        guard let timeline = TimelineHelper().loadTimelineValues() else {
            return
        }
        timePills = TimelineHelper().sort(timeline: timeline)
        priorityCategories = timeline.priorityOfCategories ?? []
    }

    private func calculateRows(for pills: [TimelinePill], withPriority priorityCategories: [String]) {
        for pill in pills {
            let row = TimelineHelper.determineRow(for: pill, in: pills, withPriority: priorityCategories)
            pillRowMapping[pill.id] = row
            print("Pill \(pill.body ?? "") assigned to row \(row)")
        }
    }


    func timePillForRowAndWeek(row: Int, week: Int) -> TimelinePill? {
        timePills.first { pill in
            guard let pillRow = pillRowMapping[pill.id],
                  let startDay = pill.startDay else {
                return false
            }

            let pillWeek = (startDay) / 7 // Calculate the week number
            return pillRow == row && pillWeek == week
        }
    }


}
