//
//  InitialViewController.swift
//  UwUeather
//
//  Created by Nick Zolnoor on 10/30/19.
//  Copyright © 2019 Nick Zolnoor. All rights reserved.
//
import UIKit
import Foundation
import CoreLocation
import GooglePlaces



class InitialViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var forecastTextView: UITextView!
    @IBOutlet weak var weatherImageView: UIView!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var refreshButton: UIButton!
    
    var locations: [CLLocation]?
    
    lazy var autocompleteController: AutocompleteViewController = {
        let controller = AutocompleteViewController()
        
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
          UInt(GMSPlaceField.placeID.rawValue))!
        controller.placeFields = fields
        
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        controller.autocompleteFilter = filter
        
        return controller
    }()
    
    private var locationManager: LocationManager?
    private var currentWeather: Weather?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after loading the view.
        if !UserDefaults.standard.bool(forKey: "launchedBefore") {
            firstLaunch()
        } else {
            weatherViewSetup()
        }
    }
    
    @IBAction func refreshWeatherPressed(_ sender: Any) {
        
        guard let exposedLocation = self.locationManager?.exposedLocation else {
            print("*** Error in \(#function): exposedLocation is nil")
            self.locationTextView.text = "Please enable location services"
            initLocation()
            return
        }
        
        if let locMan = self.locationManager {
            locMan.getPlace(for: exposedLocation) { placemark in
                guard let placemark = placemark else { return }
                
                if let state = placemark.administrativeArea {
                    print(state)
                    if let town = placemark.locality {
                        self.locationTextView.text = "\(town), \(state)"
                        print("set location to \(town), \(state)")
                        let weather = WeatherFactory()
                        if let loc = locMan.exposedLocation {
                            weather.getWeather(for: loc.coordinate, completion: { [weak self] weather, error in
                                if let info = weather {
                                    print(info)
                                    self?.currentWeather = info
                                    DispatchQueue.main.async {
                                        self?.updateWeatherText()
                                    }
                                }
                                if let err = error {
                                    print(err)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func addLocationPressed(_ sender: Any) {
        autocompleteController.delegate = self
        present(autocompleteController, animated: true){}
    }
    
    func firstLaunch() {
        let alertController = UIAlertController(title: "Welcome!", message: "Welcome to UwUeather. We're gonna need your location!", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.initLocation()
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }))
        
        self.present(alertController, animated: true){}
    }
    
    func initLocation() {
        self.locationManager = LocationManager()
        if let locMan = self.locationManager {
            locMan.setDelegate(for: self)
            locMan.startUpdating()
        }
    }
    
    func weatherViewSetup() {
        guard let exposedLocation = self.locationManager?.exposedLocation else {
            print("*** Error in \(#function): exposedLocation is nil")
            self.locationTextView.text = "Please enable location services"
            initLocation()
            return
        }
        print("exposedLocation is \(exposedLocation.coordinate.latitude),\(exposedLocation.coordinate.longitude)")
        
        if let locMan = self.locationManager {
            locMan.getPlace(for: exposedLocation) { placemark in
                guard let placemark = placemark else { return }
                
                if let state = placemark.administrativeArea {
                    if let town = placemark.locality {
                        self.locationTextView.text = "\(town), \(state)"
                        print("set location to \(town), \(state)")
                        let weather = WeatherFactory()
                        if let loc = locMan.exposedLocation {
                            weather.getWeather(for: loc.coordinate, completion: { [weak self] weather, error in
                                if let info = weather {
                                    self?.currentWeather = info
                                    DispatchQueue.main.async {
                                        self?.updateWeatherText()
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func updateWeatherText() {
        if let weather = currentWeather {
            self.forecastTextView.text = weather.summary
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
            
        case .notDetermined         : print("notDetermined")        // location permission not asked for yet
        case .authorizedWhenInUse   : self.locationManager?.startUpdating() // location authorized
        case .authorizedAlways      : print("authorizedAlways")     // location authorized
        case .restricted            : print("restricted")           // TODO: handle
        case .denied                : print("denied")               // TODO: handle
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locations are \(locations)")
        guard self.locations != nil else {
            self.locations = locations
            self.weatherViewSetup()
            return
        }
    }
    
    
}

extension InitialViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    
        print("Place name: \(place.name)")
        print("Place ID: \(place.placeID)")
        print("Place attributions: \(place.attributions)")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
      // TODO: handle the error.
      print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
      dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
