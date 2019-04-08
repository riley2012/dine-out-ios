/**
 * Copyright (c) Tova Roth 2019
 * License: MIT
 */

import Foundation
import RxSwift
import GooglePlaces

class ViewModel {
    let placesService = PlacesService.sharedInstance
    let toneAnalyzerService = ToneAnalyzerService.sharedInstance
    let disposeBag: DisposeBag = DisposeBag()
    let placesArrayVariable = Variable([Place]())
    let currentPlaceVariable: Variable<GMSPlace?> = Variable(nil as GMSPlace?)
    var places = [Place]()
    
    init() {
        subscribeToCurrentLocation()
        subscribeToFetchNearbyPlaces()
        subscribeToFetchReviews()
        subscribeToFetchReviewSentiments()
    }
    
    private func subscribeToCurrentLocation() {
        placesService.currentPlaceSequence()
            .subscribe(onNext: { [weak self] (gmsPlace) in
                guard let strongSelf = self else { return }
                strongSelf.currentPlaceVariable.value = gmsPlace
            })
            .disposed(by: self.disposeBag)
    }
    
    private func subscribeToFetchNearbyPlaces() {
        placesService.placesSequence()
            .subscribe(onNext: { [weak self] (plcs) in
                guard let strongSelf = self else { return }
                strongSelf.placesArrayVariable.value = plcs
                strongSelf.places = plcs
                for place in plcs {
                    if let placeId = place.place_id {
                        strongSelf.placesService.fetchReviews(placeId: placeId)
                    }
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func subscribeToFetchReviews() {
        placesService.placeDetailsSequence()
            .subscribe(onNext: { [weak self] (placeDetails) in
                guard let strongSelf = self else { return }
                if (placeDetails.place_id != nil && placeDetails.reviews != nil) {
                    var text = ""
                    for review in placeDetails.reviews! {
                        if let reviewText = review.text {
                            text += "." + reviewText
                        }
                    }
                    if !text.isEmpty {
                        strongSelf.toneAnalyzerService.fetchTone(placeId: placeDetails.place_id!, text: text)
                    }
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func subscribeToFetchReviewSentiments() {
        toneAnalyzerService.documentTonesSequence()
            .subscribe(onNext: { [weak self] (documentTones) in
                guard let strongSelf = self else { return }
                var sentiments = [String]()
                if let tones = documentTones.document_tone?.tones {
                    for tone in tones {
                        if let name = tone.tone_name {
                            sentiments.append(name)
                        }
                    }
                }
                if !sentiments.isEmpty && documentTones.place_id != nil {
                    let updatedPlaces: [Place] = strongSelf.places.map { if $0.place_id == documentTones.place_id { return Place(place_id: $0.place_id, name: $0.name, vicinity: $0.vicinity, icon: $0.icon, sentiments: sentiments)} else { return $0 }
                    }
                    // publish the update to the places Variable sequence
                    strongSelf.placesArrayVariable.value = updatedPlaces
                    strongSelf.places = updatedPlaces
                }
            })
            .disposed(by: self.disposeBag)
        
    }
}

