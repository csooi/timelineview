//Copyright © 2022 Koninklijke Philips N.V. All rights reserved.

import SwiftUI

class Timeline: Codable, ObservableObject {
    var categoryMetaData: [CategoryMetadata]?
    @Published var timelinePills: [TimelinePill]?

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

class TimelinePill: Codable, Identifiable, ObservableObject {
    let id = UUID()
     var categoryId: String?
     var body: String?
     var startWeek: Int?
     var endWeek: Int?
    var duration: Int? {
        (endWeek ?? 1) - (startWeek ?? 1) + 1
    }

     var priority: Int?
     var color: Color?
     @Published var textAligment: Alignment = .leading
    @Published var offset: CGFloat = UIScreen.main.bounds.size.width/2 - 10
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "Category"
        case body = "Body"
        case startWeek = "StartWeek"
        case endWeek = "EndWeek"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        categoryId = try container.decodeIfPresent(String.self, forKey: .categoryId)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        startWeek = try container.decodeIfPresent(Int.self, forKey: .startWeek)
        endWeek = try container.decodeIfPresent(Int.self, forKey: .endWeek)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(categoryId, forKey: .categoryId)
        try container.encodeIfPresent(body, forKey: .body)
        try container.encodeIfPresent(startWeek, forKey: .startWeek)
        try container.encodeIfPresent(endWeek, forKey: .endWeek)
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
