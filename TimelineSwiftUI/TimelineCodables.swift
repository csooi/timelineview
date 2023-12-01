//Copyright © 2022 Koninklijke Philips N.V. All rights reserved.

import UIKit

class Timeline: Codable {
    var priorityOfCategories: [String]?
    var timeline: [TimelinePill]?
    
    enum CodingKeys: String, CodingKey {
        case timeline = "Timeline"
        case priorityOfCategories = "PriorityOfCategories"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        priorityOfCategories = try container.decodeIfPresent([String].self,
                                                             forKey: .priorityOfCategories)
        timeline = try container.decodeIfPresent([TimelinePill].self,
                                                 forKey: .timeline)
        
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(timeline, forKey: .timeline)
        try container.encodeIfPresent(priorityOfCategories, forKey: .priorityOfCategories)
    }
}

class TimelinePill: Codable, Identifiable {
    let id = UUID()
    var category: String?
    var body: String?
    var startDay: Int?
    var duration: Int?
    var color: UIColor? {
        guard let category = category else {
            return nil
        }
        let cate = Categories(rawValue: category)
        return cate?.color
    }

    enum CodingKeys: String, CodingKey {
        case category = "Category"
        case body = "Body"
        case startDay = "StartDay"
        case duration = "Duration"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        startDay = try container.decodeIfPresent(Int.self, forKey: .startDay)
        duration = try container.decodeIfPresent(Int.self, forKey: .duration)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(body, forKey: .body)
        try container.encodeIfPresent(startDay, forKey: .startDay)
        try container.encodeIfPresent(duration, forKey: .duration)
    }
}
