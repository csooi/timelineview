//Copyright © 2022 Koninklijke Philips N.V. All rights reserved.

import SwiftUI

class Timeline: Codable {
    var categoryMetaData: [CategoryMetadata]?
    var timelinePills: [TimelinePill]?

    enum CodingKeys: String, CodingKey {
        case timeline = "Timeline"
        case categoryMetaData = "CategoryMetadata"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        categoryMetaData = try container.decodeIfPresent([CategoryMetadata].self,
                                                             forKey: .categoryMetaData)
        timelinePills = try container.decodeIfPresent([TimelinePill].self,
                                                 forKey: .timeline)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(timelinePills, forKey: .timeline)
        try container.encodeIfPresent(categoryMetaData, forKey: .categoryMetaData)
    }
}

class TimelinePill: Codable, Identifiable {
    let id = UUID()
    var categoryId: String?
    var body: String?
    var startDay: Int?
    var duration: Int?
    var priority: Int?
    var color: Color?
//    var color: UIColor? {
//        guard let category = categoryId else {
//            return nil
//        }
//        let cate = Categories(rawValue: category)
//        return cate?.color
//    }

    enum CodingKeys: String, CodingKey {
        case categoryId = "CategoryId"
        case body = "Body"
        case startDay = "StartDay"
        case duration = "Duration"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        categoryId = try container.decodeIfPresent(String.self, forKey: .categoryId)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        startDay = try container.decodeIfPresent(Int.self, forKey: .startDay)
        duration = try container.decodeIfPresent(Int.self, forKey: .duration)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(categoryId, forKey: .categoryId)
        try container.encodeIfPresent(body, forKey: .body)
        try container.encodeIfPresent(startDay, forKey: .startDay)
        try container.encodeIfPresent(duration, forKey: .duration)
    }
}

struct CategoryMetadata: Codable {
    var id: String?
    var localized: String?
    var categoryColors: CategoryColors?
    enum CodingKeys: String, CodingKey {
        case id = "CategoryId"
        case localized = "Localised"
        case categoryColors = "CategoryColors"
    }
}

struct CategoryColors: Codable {
    var gradientType: String?
    var codes: [String]?
    enum CodingKeys: String, CodingKey {
        case gradientType = "GradientType"
        case codes = "Codes"
    }
}
