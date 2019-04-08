/**
 * Copyright (c) Tova Roth 2019
 * License: MIT
 */

import Foundation
import RxSwift
import CoreLocation
import Alamofire

class ToneAnalyzerService {
    static let sharedInstance = ToneAnalyzerService()
    private let apiKey = apiKeyValue(keyname: "ToneAnalyzerApiKey") ?? ""
    private var documentTones: ReplaySubject<DocumentTone>
    private let decoder = JSONDecoder()
    
    private init() {
        documentTones = ReplaySubject<DocumentTone>.create(bufferSize: 1)
    }
    
    public func documentTonesSequence() -> ReplaySubject<DocumentTone> {
        return self.documentTones
    }
    
    public func fetchTone(placeId: String, text: String) {
        let escapedText = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        var stringUrl = "https://gateway.watsonplatform.net/tone-analyzer/api/v3/tone?version=2017-09-21&text=\(escapedText!)"
        Logger.logInfo("stringUrl for ToneAnalyzer: \(stringUrl)")
        
        //        let credential = URLCredential(user: "apikey", password: apiKey, persistence: NSURLCredentialPersistence.ForSession)
        Alamofire.request(stringUrl, method: .get)
            .authenticate(user: "apikey", password: apiKey)
            .responseJSON { [unowned self] response in
                do {
                    guard response.data != nil else {
                        let message = "Response from URL `\(stringUrl)` is empty"
                        Logger.logError(message)
                        throw ToneAnalyzerError.emptyJsonError(message)
                    }
                    let json = response.data!
                    var docTone = try self.decoder.decode(DocumentTone.self, from: json)
                    docTone.place_id = placeId
                    self.documentTonesSequence().onNext(docTone)
                } catch let err {
                    Logger.logError(err)
                }
        }
    }
    
}
