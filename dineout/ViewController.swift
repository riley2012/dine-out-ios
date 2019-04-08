/**
 * Copyright (c) Tova Roth 2019
 * License: MIT
 */

import UIKit
import GooglePlaces
import Network
import RxSwift

class ViewController: UIViewController {
    //   var placesClient: GMSPlacesClient!
    let placesService = PlacesService.sharedInstance
    let disposeBag: DisposeBag = DisposeBag()
    let model = ViewModel()
    //    var gmsPlace: GMSPlace? = nil
    var places: [Place] = [Place]()
    var gmsPlace: GMSPlace?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func searchNearMe(_ sender: Any) {
        let keyword = keywordTextField.text
        
        if let gmsPlace = gmsPlace {
            let latitude = gmsPlace.coordinate.latitude
            let longitude = gmsPlace.coordinate.longitude
            self.placesService.fetchNearbyRestaurants(latitude: latitude, longitude: longitude, keyword: keyword)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        placesService.getCurrentPlace()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    private func updateCurrentPlace() {
        if let name = self.gmsPlace?.name {
            self.nameLabel.text = name
        }
        if let formattedAddress = self.gmsPlace?.formattedAddress {
            let address = formattedAddress.components(separatedBy: ", ")
                .joined(separator: "\n")
            self.addressLabel.text = address
        }
    }
    
    private func setupObservers() {
        model.placesArrayVariable.asObservable()
            .subscribe(onNext: { [weak self] (places) in
                self?.places = places
                self?.tableView.reloadData()
                }, onError: { (error: Error) in
                    Logger.logError("error listening for places: \(error)")
            })
            .disposed(by: self.disposeBag)
        
        model.currentPlaceVariable.asObservable()
            .subscribe(onNext: { [weak self] (place) in
                self?.gmsPlace = place
                self?.updateCurrentPlace()
                }, onError: { (error: Error) in
                    Logger.logError("error listening for places: \(error)")
            })
            .disposed(by: self.disposeBag)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeTableViewCell", for: indexPath) as! PlaceTableViewCell
        if (indexPath.row < places.count) {
            let place = places[indexPath.row]
            cell.name?.text = place.name
            cell.address?.text = place.vicinity
            if (place.sentiments != nil && place.sentiments!.count > 0) {
                let sentimentString = place.sentiments?.joined(separator: ", ")
                cell.sentiments?.text = "Sentiments: " + (sentimentString ?? "")
            } else {
                cell.sentiments?.text = ""
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return places.count
    }
}

