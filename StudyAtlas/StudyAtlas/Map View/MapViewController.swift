//
//  MapViewController.swift
//  StudyAtlas
//
//  Created by Shaifali Goyal on 11/21/18.
//  Copyright © 2018 Jaime Park. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import UserNotifications

class MapViewController: UIViewController {
    
    
    let zoomLevel : Float = 18.0 // 20 = buildings, 15 = streets, 10 = city, 5 = landmass/continent
    let kemperHallCoordinates = CLLocationCoordinate2D(latitude: 38.537161, longitude: -121.755021) //placeHolder location
    let locationManager = CLLocationManager()
    var locationMarker : GMSMarker?
    private var infoWindow = MapMarkerView()
    var currMarkerData : NSDictionary?
    var geofences : [CLCircularRegion] = []
    @IBOutlet weak var feelingLuckyButton: UIButton!
    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var searchLocationButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.infoWindow = loadNiB()
        enableLocationServices()
        setMapCenter()
    }
    
    /**
     Set the center of the map at the last stored user location to begin with.
     */
    func setMapCenter() {
        
        if let lastLocation = Storage.lastUserLocation {
            centerAtLocation(lastLocation)
        } else {
            centerAtLocation(kemperHallCoordinates)
        }
    }
    
    /**
     Pop up full screen google maps places sdk location search on clicking the search around
     location button
     */
    @IBAction func searchButtonClicked() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)

    }
    
    /**
     Directs user to the nearest study location if their location is available. If their location services is not
     available then the user is direct to Shield Library.
     */
    @IBAction func feelingLuckyClicked(_ sender: Any) {
        if mapView.isMyLocationEnabled &&  Storage.lastUserLocation != nil{
            let myLocation = Storage.lastUserLocation!
            var places : [[String : Any]] = []
            Api.getCollection("places") { (documents, error) in
                if let documents = documents {
                    places = documents
                    var name = ""
                    let temp = places[0]["coordinates"] as! GeoPoint
                    var luckyLocation = CLLocationCoordinate2D.init(latitude: temp.latitude, longitude: temp.longitude)
                    for place in places {
                        guard let geopoint = place["coordinates"] as? GeoPoint else {
                            continue
                        }
                        guard let nam = place["name"] as? String else {
                            continue
                        }
                        let destinationCoord = CLLocationCoordinate2D.init(latitude: geopoint.latitude, longitude: geopoint.longitude)
                        if destinationCoord.distance(from: myLocation) < luckyLocation.distance(from: myLocation){
                            luckyLocation = destinationCoord
                            name = nam
                        }
                    }
                    self.modalPopover(name, luckyLocation)
                }
            }
        } else {
            let shieldsLibraryCoordinates = CLLocationCoordinate2D.init(latitude: 38.53965659058711, longitude: -121.74952268600464)
            self.modalPopover("Shields Library", shieldsLibraryCoordinates)
        }
    }
    
    /**
     Add extra data in case of segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "moreInfo") {
            let destination = segue.destination as! SiteViewController
            guard let data = currMarkerData else {
                print("currMarkerData null for some reason")
                return
            }
            destination.siteName = data["name"] as? String
        }
    }
    
    /**
     Animate the map's transition so that the location is at the center of the view
     */
    func centerAtLocation(_ location : CLLocationCoordinate2D) {
        mapView.animate(to: GMSCameraPosition.camera(withTarget: location, zoom: zoomLevel))
    }
    
    /**
     Gives the user options of whether they want to transition to or find out more about a suggested location.
     */
    func modalPopover(_ name : String, _ location : CLLocationCoordinate2D) {
        let alertController = UIAlertController(title: "You should study at \(name)!", message: "Would you like to go there?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action:UIAlertAction!) in
        }
        
        let moreInfoAction = UIAlertAction(title: "Take me there!", style: .default) { (action:UIAlertAction!) in
            self.centerAtLocation(location)
        }
        
        let OKAction = UIAlertAction(title: "More Info", style: .default) { (action:UIAlertAction!) in
            self.currMarkerData = NSDictionary(dictionary : ["name" : name])
            self.performSegue(withIdentifier: "moreInfo", sender: self)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(moreInfoAction)
        alertController.addAction(OKAction)

        self.present(alertController, animated: true, completion:nil)
    }
    
}

extension MapViewController : GMSMapViewDelegate, MapMarkerDelegate {
    
    /**
     In case if map is moved, make sure markers are put in correct places
     */
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (locationMarker != nil){
            guard let location = locationMarker?.position else {
                print("locationMarker is nil")
                return
            }
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y = infoWindow.center.y - 82
        }
    }
    
    /**
     If a Marker is tapped - have additional information pop up.
     */
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        var markerData : NSDictionary?
        guard let data = marker.userData! as? NSDictionary else {
            print("marker data nil")
            return false
        }
        markerData = data
        
        print("tapped location marker")
        locationMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = loadNiB()
        guard let location = locationMarker?.position else {
            print("locationMarker is nil")
            return false
        }
        // Pass the spot data to the info window, and set its delegate to self
        infoWindow.siteLabel.text = markerData?["name"] as? String
        infoWindow.siteData = markerData
        infoWindow.delegate = self
        infoWindow.infoButton.makeRoundButton()
        // Configure UI properties of info window
        infoWindow.alpha = 1
        infoWindow.layer.cornerRadius = 12
        infoWindow.infoButton.layer.cornerRadius = infoWindow.infoButton.frame.height / 2
        
        // Offset the info window to be directly above the tapped marker
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.center.y = infoWindow.center.y - 82
        self.view.addSubview(infoWindow)
        return false
    }
    
    /**
     Fill the map with special markers and geofence data based on locations that are saved in the database
     */
    func loadMapData(withGeofences setGeofences : Bool) {
        
        var places : [[String : Any]] = []
        Api.getCollection("places") { (documents, error) in
            if let documents = documents {
                places = documents
                for place in places {
                    
                    guard let name = place["name"] as? String else {
                        continue
                    }
                    guard let geopoint = place["coordinates"] as? GeoPoint else {
                        continue
                    }
                    
                    let lat = geopoint.latitude
                    let long = geopoint.longitude
                    
                    if setGeofences {
                        self.generateGeofence(identifier: name, latitude: lat, longitude: long)
                    }
                    
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    marker.map = self.mapView
                    marker.icon = GMSMarker.markerImage(with: UIColor(red:1.00, green:0.63, blue:0.11, alpha:1.0))
                    
                    marker.userData = place
                    
                }
                return
            }
            print("could not get places")
        }
    }
    
    /**
     Segue to view with information about the site that was clicked.
     */
    func infoButtonClicked(_ data: NSDictionary) {
        //segue to more info view
        currMarkerData = data
        performSegue(withIdentifier: "moreInfo", sender: self)
    }
    
    /**
     load map marker view
     */
    func loadNiB() -> MapMarkerView {
        let infoWindow = MapMarkerView.instanceFromNib() as! MapMarkerView
        return infoWindow
    }
}


/**
 Manages user location updates and changes in authorization status for user
 */
extension MapViewController : CLLocationManagerDelegate {
    
    
    /**
     Update and store the location of the user
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        Storage.lastUserLocation = location.coordinate
    }

    /**
     handle changes in location authorization status
     */
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedAlways || status != .authorizedWhenInUse {
            return
        }
        
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
    }
    
    /**
     called when user Exits a monitored region
     */
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            if geofences.contains(region) { //is member of geofences
                fenceEvent(forRegion: region, entering: false)
            }
        }
    }
    
    /**
     called when user Enters a monitored region
     */
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let location = region as? CLCircularRegion {
            if geofences.contains(location) { //is member of geofences
                fenceEvent(forRegion: location, entering: true)
            }
        }
    }
    
    /**
     Determine whether the application is allowed to use authorization status.
     */
    func enableLocationServices() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            disableLocationInUseFunctionality()
            break
        case .authorizedAlways:
            enableLocationInUseFunctionality()
            break
        case .authorizedWhenInUse: //for now, no difference between these
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            enableLocationInUseFunctionality()
            break
        }
    }
    
    /**
     Disable location based features such as ability to update the map, but still allow searching and viewing location information
     */
    func disableLocationInUseFunctionality() {
        usePickedLocation()
        loadMapData(withGeofences: false)
    }
    
    /**
     Use the location chosen by the user.
     Enable the search bar for a new center location
    */
    func usePickedLocation() {
        searchLocationButton.isHidden = false
        locationManager.stopUpdatingLocation()
    }
    
    /**
     Update Map based on physical location of the user.
     NOTE: put all user location based UIElements here
     */
    func enableLocationInUseFunctionality() {
        mapView.settings.myLocationButton = true
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        loadMapData(withGeofences: true)
    }
    
    /**
     Create a geofence at a certain radius around the specified location.
     */
    func generateGeofence(identifier id: String, latitude lat: Double, longitude long: Double) {
        //creates fence boundaries
        let geofenceRegionCenter = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long
        )
        
        let geofenceRegion = CLCircularRegion(
            center: geofenceRegionCenter,
            radius: 15,
            identifier: id
        )
        
        //creates notifications for both enter and exit
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true

        //add to list of monitored fences
        geofences.append(geofenceRegion)
        self.locationManager.startMonitoring(for: geofenceRegion)
    }
    
    /**
     Triggered when a user enters or leaves a geofenced area
     */
    func fenceEvent(forRegion region: CLRegion!, entering : Bool) {
        let content = UNMutableNotificationContent()
        var currentNum = 0
        
        //submit api call to update the count of users in
        //the geofence based off entering or leaving
        Api.changePlaceCount(region.identifier, entering) { (count) in
            currentNum = count
            content.title = "StudyAtlas"
            //create message based on if entering or exiting
            if entering {
                content.body = "You are now entering " + region.identifier
                content.body += ". Current count is " + String(currentNum)
            } else {
                content.body = "You are now leaving " + region.identifier
            }
            
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 1,
                repeats: false
            )
            
            //create notifcation request
            let request = UNNotificationRequest(
                identifier: region.identifier,
                content: content,
                trigger: trigger
            )
            
            //add notification to center to be scheduled
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request, withCompletionHandler: { (error) in
                if error != nil {
                    print("Could not add a geofence notification")
                }
            })
        }
    }
}

/**
 Search Location Functionality if using full screen autocomplete view
 */
extension MapViewController: GMSAutocompleteViewControllerDelegate {
    
    /**
     Handle the user's selection.
     */
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        mapView.camera = GMSCameraPosition.camera(withTarget: place.coordinate, zoom: zoomLevel)
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Handle error in search
     */
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    /**
     User canceled the operation.
     */
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Turn the network activity indicator on and off again.
     */
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    /**
     Turn the network activity indicator on and off again.
     */
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
