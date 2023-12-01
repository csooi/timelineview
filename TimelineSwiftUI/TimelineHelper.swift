//Copyright © 2022 Koninklijke Philips N.V. All rights reserved.

import UIKit

public enum Categories:String {

    case welcome = "Welcome"
    case pregnancyMilestones = "Pregnancy milestones"
    case babysDevelopment = "Your baby's development"
    case healthcare = "Your healthcare"
    case dailyHabits = "Daily habits"
    case thingsToPrepare = "Things to prepare"
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

    func loadTimelineValues() -> Timeline? {
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
    
    func sort(timeline: Timeline) -> [TimelinePill] {
        guard let timelineCards = timeline.timeline else {
            return []
        }
        let filteredArray = timelineCards.sorted {
            if $0.startDay == $1.startDay {
                if categories($0.category ?? "", timeline.priorityOfCategories) == categories($1.category ?? "", timeline.priorityOfCategories) {
                    let vv = ($0.startDay ?? 0) + ($0.duration ?? 0)
                    let rrr = ($1.startDay ?? 0) + ($1.duration ?? 0)
                    return vv < rrr
                }
                return categories($0.category ?? "", timeline.priorityOfCategories) < categories($1.category ?? "", timeline.priorityOfCategories)
            }
            return $0.startDay ?? 0 < $1.startDay ?? 0
        }
        return filteredArray
    }
    
    func categories(_ categ: String, _ priorities: [String]?) -> Int {
        guard let priority = priorities else {
            return 100 //some random number
        }
        
        let pri = priority.firstIndex{ $0 == categ}
        return pri ?? 100
    }
    
}

extension TimelineHelper {
    
    static func determineRow(for targetPill: TimelinePill, in pills: [TimelinePill], withPriority priorityCategories: [String]) -> Int {
        // Mapping of week number to rows occupied in that week
        var occupiedRowsByWeek: [Int: [Int]] = [:]

        // Sort all pills including the target pill by priority
        let sortedPills = (pills + [targetPill]).sorted(by: {
            priorityIndex(for: $0.category, priorityCategories: priorityCategories) <
            priorityIndex(for: $1.category, priorityCategories: priorityCategories)
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

    private static func priorityIndex(for category: String?, priorityCategories: [String]) -> Int {
        guard let category = category else { return priorityCategories.count }
        return priorityCategories.firstIndex(of: category) ?? priorityCategories.count
    }
}
