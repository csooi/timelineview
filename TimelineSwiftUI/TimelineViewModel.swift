
import Foundation
import SwiftUI

class TimelineViewModel: ObservableObject {
    var timePills: [TimelinePill] = []
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
        }
    }

    func timePillForRowAndWeek(row: Int, week: Int) -> TimelinePill? {
        timePills.first { pill in
            guard let pillRow = pillRowMapping[pill.id], let startDay = pill.startDay, let duration = pill.duration else {
                return false
            }

            let endDay = startDay + duration
            return pillRow == row && (week >= startDay && week < endDay)
        }
    }
}
