//
//  AppActivity.swift
//  tracka
//
//  Created by Neal Carico on 2/12/24.
//

import Foundation

class AppActivity: Identifiable, ObservableObject, Hashable, Codable {
    let id: UUID
    let name: String
    var usageDuration: TimeInterval
    let bundleIdentifier: String
    var tags: Set<String>

    enum CodingKeys: CodingKey {
        case id, name, usageDuration, bundleIdentifier, tags
    }

    init(name: String, usageDuration: TimeInterval, bundleIdentifier: String, tags: Set<String> = []) {
        self.id = UUID()
        self.name = name
        self.usageDuration = usageDuration
        self.bundleIdentifier = bundleIdentifier
        self.tags = tags
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        usageDuration = try container.decode(TimeInterval.self, forKey: .usageDuration)
        bundleIdentifier = try container.decode(String.self, forKey: .bundleIdentifier)
        tags = try container.decode(Set<String>.self, forKey: .tags)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(usageDuration, forKey: .usageDuration)
        try container.encode(bundleIdentifier, forKey: .bundleIdentifier)
        try container.encode(tags, forKey: .tags)
    }

    static func == (lhs: AppActivity, rhs: AppActivity) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
