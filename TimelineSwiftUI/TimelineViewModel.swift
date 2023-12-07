
import Foundation
import SwiftUI

class TimelineViewModel: ObservableObject {
    @Published var timePills: [TimelinePill] = []
    var categoryMetaData: [CategoryMetadata] = []
    private var pillRowMapping: [UUID: Int] = [:]
    var currentWeek: Int = 4
    
    init() {
        loadTimeline()
        calculateRows(for: timePills, withPriority: categoryMetaData)
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
    
    func isOccupying(week: Int, row: Int) -> Bool {
        return timePills.contains { pill in
            guard let pillRow = pillRowMapping[pill.id],
                  let startDay = pill.startDay,
                  let duration = pill.duration else {
                return false
            }

            let pillStartWeek = startDay / 7
            let pillEndWeek = (startDay + duration - 1) / 7
            return pillRow == row && week >= pillStartWeek && week < pillEndWeek
        }
    }
}
