/**
 * Copyright (c) Tova Roth 2019
 * License: MIT
 */

import Foundation

struct Place: Codable {
    let place_id: String?
    let name: String?
    let vicinity: String?
    let icon: String?
    var sentiments: [String]?
}

struct Results: Codable {
    let results: [Place]
}

struct Review: Codable {
    let text: String?
}

struct PlaceDetails: Codable {
    let place_id: String?
    let reviews: [Review]?
}

struct PlaceDetailsResult: Codable {
    let result: PlaceDetails?
}

public enum PlacesError: Error {
    case emptyJsonError(_: String)
}
