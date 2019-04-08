/**
 * Copyright (c) Tova Roth 2019
 * License: MIT
 */

import Foundation

struct Tone: Codable {
    let score: Double?
    let tone_id: String?
    let tone_name: String?
}

struct Tones: Codable {
    let tones: [Tone]?
}

struct DocumentTone: Codable {
    var place_id: String?
    let document_tone: Tones?
}

public enum ToneAnalyzerError: Error {
    case emptyJsonError(_: String)
}
