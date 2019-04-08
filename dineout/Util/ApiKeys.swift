/**
 * Copyright (c) Tova Roth 2019
 * License: MIT
 */

import Foundation

func apiKeyValue(keyname:String) -> String? {
    var value: String? = nil
    if let path = Bundle.main.path(forResource: "ApiKeys", ofType: "plist") {
        let dict = NSDictionary(contentsOfFile: path)
        value = (dict?[keyname] as? String?) ?? nil
    }
    return value
}
