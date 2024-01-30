//Copyright © 2022 Koninklijke Philips N.V. All rights reserved.

import SwiftUI

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
            timelinePill.color = colorForCategory(categoryId: timelinePill.categoryId ?? "", in: categoryMetaData) ?? Color.blue          //any other updation  which makes ui plotting easier can be added here
        }
        return timelinePills
    }
    
    func colorForCategory(categoryId: String, in categoryMetadataArray: [CategoryMetadata]) -> Color? {
        guard let matchingMetadata = categoryMetadataArray.first(where: { $0.id == categoryId }),
              let hexColorString = matchingMetadata.categoryColors?.codes?.first else {
            return nil
        }

        return Color(hex: hexColorString)
    }

    func sort(timeline: [TimelinePill]) -> [TimelinePill] {
        return timeline.sorted {
            if $0.startWeek == $1.startWeek {
                if $0.priority ?? 0 == $1.priority ?? 0 {
                    return $0.duration ?? 0 < $1.duration ?? 0
                }
                return $0.priority ?? 0 < $1.priority ?? 0
            }
            return $0.startWeek ?? 0 < $1.startWeek ?? 0
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
        })

        for pill in sortedPills {
            let startWeek = (pill.startWeek ?? 1) - 1
            guard let endWeek = pill.endWeek else {
                continue
            }

            if pill.id == targetPill.id {
                // Find the lowest unoccupied row for the target pill
                var targetRow = 0
                for _ in startWeek..<endWeek {
                    // Find the lowest unoccupied row across all weeks the pill spans
                    let rowForWeek = findLowestUnoccupiedRowAcrossWeeks(in: occupiedRowsByWeek, startWeek: startWeek, endWeek: endWeek)
                    targetRow = max(targetRow, rowForWeek)
                }
                return targetRow
            } else {
                // Populate occupied rows for other pills considering all weeks they span
                let row = findLowestUnoccupiedRowAcrossWeeks(in: occupiedRowsByWeek, startWeek: startWeek, endWeek: endWeek)
                for week in startWeek..<endWeek {
                    occupiedRowsByWeek[week, default: []].append(row)
                }
            }
        }
        return 0
    }
    
    private static func findLowestUnoccupiedRowAcrossWeeks(in occupiedRowsByWeek: [Int: [Int]], startWeek: Int, endWeek: Int) -> Int {
        var row = 0
        var isRowOccupiedInAnyWeek = true
        
        while isRowOccupiedInAnyWeek {
            isRowOccupiedInAnyWeek = false
            for week in startWeek..<endWeek {
                if occupiedRowsByWeek[week, default: []].contains(row) {
                    isRowOccupiedInAnyWeek = true
                    row += 1
                    break
                }
            }
        }
        
        return row
    }
}
