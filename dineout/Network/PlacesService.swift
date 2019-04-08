/**
 * Copyright (c) Tova Roth 2019
 * License: MIT
 */

import Foundation
import RxSwift
import CoreLocation
import Alamofire
import GooglePlaces

class PlacesService {
    static let sharedInstance = PlacesService()
    static var placesClient = GMSPlacesClient.shared()
    
    private var places: ReplaySubject<[Place]>
    private var placeDetails: ReplaySubject<PlaceDetails>
    private var currentPlace: ReplaySubject<GMSPlace>
    private let decoder = JSONDecoder()
    private let apiKey = apiKeyValue(keyname: "GoogleCloudPlatformApiKey") ?? ""
    
    private init() {
        places = ReplaySubject<[Place]>.create(bufferSize: 1)
        placeDetails = ReplaySubject<PlaceDetails>.create(bufferSize: 1)
        currentPlace = ReplaySubject<GMSPlace>.create(bufferSize: 1)
    }
    
    public func placesSequence() -> ReplaySubject<[Place]> {
        return self.places
    }
    
    public func placeDetailsSequence() -> ReplaySubject<PlaceDetails> {
        return self.placeDetails
    }
    
    public func currentPlaceSequence() -> ReplaySubject<GMSPlace> {
        return self.currentPlace
    }
    
    public func getCurrentPlace() { 
        PlacesService.placesClient.currentPlace { (placeLikelihoodList, error) in
            guard error == nil else {
                Logger.logError("Error \(error!)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                if let gmsPlace = placeLikelihoodList.likelihoods.first?.place {
                    self.currentPlaceSequence().onNext(gmsPlace)
                }
            }
        }
    }
    
    func fetchNearbyRestaurants(latitude: CLLocationDegrees, longitude: CLLocationDegrees, keyword: String?) {
        var stringUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=1500&types=restaurant&key=\(apiKey)"
        if let keyword = keyword {
            stringUrl += "&keyword=\(keyword)"
        }
        Logger.logInfo("stringUrl for nearby places: \(stringUrl)")
        
        Alamofire.request(stringUrl).responseJSON { [unowned self] response in
            do {
                guard response.data != nil else {
                    let message = "Response from URL `\(stringUrl)` is empty"
                    Logger.logError(message)
                    throw PlacesError.emptyJsonError(message)
                }
                let json = response.data!
                
                let results = try self.decoder.decode(Results.self, from: json)
                
                self.placesSequence().onNext(results.results)
            } catch let err {
                Logger.logError(err)
            }
        }
    }
    
    func fetchReviews(placeId: String) {
        let stringUrl = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeId)&fields=place_id,reviews&key=\(apiKey)"
        Logger.logInfo("stringUrl for details: \(stringUrl)")
        
        Alamofire.request(stringUrl).responseJSON { [unowned self] response in
            do {
                guard response.data != nil else {
                    let message = "Response from URL `\(stringUrl)` is empty"
                    Logger.logError(message)
                    throw PlacesError.emptyJsonError(message)
                }
                let json = response.data!
                let result = try self.decoder.decode(PlaceDetailsResult.self, from: json)
                
                if let pd = result.result {
                    self.placeDetailsSequence().onNext(pd)
                }
            } catch let err {
                Logger.logError(err)
            }
        }
    }
}
