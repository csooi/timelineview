//Copyright © 2022 Koninklijke Philips N.V. All rights reserved.

import UIKit

public enum Categories:String {

    case welcome = "Welcome"
    case pregnancyMilestones = "PregnancyMilestones"
    case babysDevelopment = "YourBabyDevelopment"
    case healthcare = "YourHealthcare"
    case dailyHabits = "DailyHabits"
    case thingsToPrepare = "ThingsToPrepare"
    case unknown
    
    var color: UIColor {
            switch self {
            case .welcome:
                return .cyan //
            case .pregnancyMilestones:
                return .lightGray
            case .babysDevelopment:
                return .green
            case .healthcare:
                return .blue
            case .dailyHabits:
                return .brown
            case .thingsToPrepare:
                return .gray
            case .unknown:
                return .red
            }
        }
}

class TimelineHelper: NSObject {

    func loadTimelineJSON() -> Timeline? {
        if let url = Bundle.main.url(forResource: "Timeline", withExtension: "json") {
               do {
                   let data = try Data(contentsOf: url)
                   let decoder = JSONDecoder()
                   let timelineJson = try decoder.decode(Timeline.self, from: data)
                   return timelineJson
               } catch {
                   print("error:\(error)")
               }
           }
           return nil
    }
    
    func fillTimelinePillMetaDataAndSort(timeline: Timeline) -> [TimelinePill] {
        guard let timelinePills = timeline.timelinePills,
                let categoryMetadata = timeline.categoryMetaData else {
            return []
        }
        let filledTimelinePills = fillPillCategoryMetadata(timelinePills: timelinePills,
                                                           categoryMetaData: categoryMetadata)
        return sort(timeline: filledTimelinePills)
    }
    
    private func fillPillCategoryMetadata(timelinePills: [TimelinePill],
                                            categoryMetaData: [CategoryMetadata]) -> [TimelinePill] {
        for timelinePill in timelinePills {
            timelinePill.priority = categoryMetaData.firstIndex{$0.id == timelinePill.categoryId} ?? 0
            //any other updation  which makes ui plotting easier can be added here
        }
        return timelinePills
    }
    
    func sort(timeline: [TimelinePill]) -> [TimelinePill] {
        return timeline.sorted {
            if $0.startDay == $1.startDay {
                if $0.priority ?? 0 == $1.priority ?? 0 {
                    return $0.duration ?? 0 < $1.duration ?? 0
                }
                return $0.priority ?? 0 < $1.priority ?? 0
            }
            return $0.startDay ?? 0 < $1.startDay ?? 0
        }
    }
}

extension TimelineHelper {
    
    static func determineRow(for targetPill: TimelinePill,
                             in pills: [TimelinePill],
                             withPriority priorityCategories: [CategoryMetadata]) -> Int {
        // Mapping of week number to rows occupied in that week
        var occupiedRowsByWeek: [Int: [Int]] = [:]

        // Sort all pills including the target pill by priority
        let sortedPills = (pills + [targetPill]).sorted(by: {
            $0.priority ?? 0 < $1.priority ?? 0
            //priorityIndex(for: $1.categoryId, priorityCategories: priorityCategories)
        })

        for pill in sortedPills {
            guard let startWeek = weekNumber(for: pill.startDay),
                  let endWeek = weekNumber(for: (pill.startDay ?? 0) + (pill.duration ?? 0)) else {
                continue
            }

            if pill.id == targetPill.id {
                // Find the lowest unoccupied row for the target pill
                var targetRow = 0
                for week in startWeek..<endWeek {
                    targetRow = max(targetRow, findNextAvailableRow(in: occupiedRowsByWeek, forWeek: week))
                }
                return targetRow
            } else {
                // Populate occupied rows for other pills
                let row = findNextAvailableRow(in: occupiedRowsByWeek, forWeek: startWeek)
                for week in startWeek..<endWeek {
                    occupiedRowsByWeek[week, default: []].append(row)
                }
            }
        }
        return 0
    }

    private static func weekNumber(for day: Int?) -> Int? {
        guard let day = day else { return nil }
        return (day - 1) / 7
    }

    private static func findNextAvailableRow(in occupiedRowsByWeek: [Int: [Int]], forWeek week: Int) -> Int {
        let occupiedRows = occupiedRowsByWeek[week, default: []]
        var row = 0
        while occupiedRows.contains(row) {
            row += 1
        }
        return row
    }
}
