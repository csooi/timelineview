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
                return .yellow //
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
    
    func sort() -> [TimelinePill] {
        guard let timeline = loadTimelineValues(),
                let timelineCards = timeline.timeline else {
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
