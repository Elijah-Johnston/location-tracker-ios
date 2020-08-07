//
//  SecondViewController.swift
//  Tabbed Location Sender
//
//  Created by Eli Johnston on 2020-07-08.
//  Copyright © 2020 Eli Johnston. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation
import CoreData

class SecondViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var startRouteButton: UIButton!
    @IBOutlet weak var stopRouteButton: UIButton!
    @IBOutlet weak var clearAllButton: UIButton!
    
    private var locationManager : CLLocationManager?
    
    var myInitLocation = CLLocationCoordinate2D(latitude: 32.7767, longitude: -96.7970)
    
    var currentLocation : CLLocation!
    
    var locations : [CLLocationCoordinate2D] = []
    
    var path : PathMapping?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        
        mapSetUp()
        
        locationManager?.delegate = self
        
        if (path != nil) {
            drawExistingPath()
        }
    }
    
    func drawExistingPath() {
        path?.route.forEach { coord in
            if (coord.count > 0) {
                locations.append(CLLocationCoordinate2D(latitude: coord[0], longitude: coord[1]))
            }
        }
        let polyline = MKPolyline(coordinates: locations, count: locations.count)
        myMapView?.addOverlay(polyline)
        
        path?.waypoints.forEach { waypoint in
            if (waypoint.count > 0) {
                setPin(location: CLLocationCoordinate2D(latitude: waypoint[0], longitude: waypoint[1]))
            }
        }
    }
    
    func mapSetUp() {
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||           CLLocationManager.authorizationStatus() ==  .authorizedAlways ) {
            guard let currentLocation = locationManager?.location else {
                return
            }
            myInitLocation = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        }
        
        myMapView?.delegate = self
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: myInitLocation, span: span)
        
        myMapView?.setRegion(region, animated: true)
        myMapView.showsScale = true
        myMapView.showsCompass = true
        myMapView.showsUserLocation = true
//        locationManager?.desiredAccuracy = .greatestFiniteMagnitude
        myMapView.mapType = .satellite
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(title: "Location Fail", message: error.localizedDescription)
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        showAlert(title: "Location Fail", message: error.localizedDescription)
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        showAlert(title: "Location Fail", message: error.localizedDescription)
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D? {
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() ==  .authorizedAlways ) {
            guard let currentLocation = locationManager?.location else {
                return nil
            }
            return CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        }
        return nil
    }
    
    func updatePolyline(location: CLLocation) {
        if (locations.count == 2) {
            locations[0] = locations[1]
            locations.remove(at: 1)
        }
        locations.append(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        let polyline = MKPolyline(coordinates: locations, count: locations.count)
        myMapView?.addOverlay(polyline)
    }
    
    func setPin(location: CLLocationCoordinate2D) {
       let pin = MKPlacemark(coordinate: location)
       myMapView.addAnnotation(pin)
    }
    
    func removeOverlay(overlay: MKOverlay) {
        myMapView.removeOverlay(overlay)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer! {
        if (overlay is MKPolyline) {
            let polylineRender = MKPolylineRenderer(overlay: overlay)
            polylineRender.strokeColor = UIColor.red.withAlphaComponent(0.5)
            polylineRender.lineWidth = 5
            removeOverlay(overlay: overlay)
            return polylineRender
        }
        return nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Everytime a location is updated
        if let location = locations.last {
            updatePolyline(location: location)
            self.path?.appendRoute(location: [location.coordinate.latitude, location.coordinate.longitude])
        }
    }
    
    @IBAction func mapControlsOnClick(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        switch button.tag {
        case 1:
            // Start
            promptForNewPath()
            locationManager?.startUpdatingLocation()
            locationManager?.allowsBackgroundLocationUpdates = true
            break
        case 2:
            // Stop
            locationManager?.stopUpdatingLocation()
            break
        case 3:
            // Waypoint
            let curLoc = getCurrentLocation()
            self.path?.waypoints.append([curLoc?.latitude ?? 0, curLoc?.longitude ?? 0])
            setPin(location: curLoc!)
            break
        case 4:
            // Save
            // prepare json data
            let json: [String: Any] = ["name": self.path?.name as Any,
                                       "route": self.path?.getRoute() as Any,
                                       "waypoints": self.path?.getWaypoints() as Any]
            let req = HttpRequest()
            do {
                try path?.save()
                req.postRequest(json: json) { (output) in
                    print("SHOW")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Saved", message: output["message"] as! String)
                        self.locations.removeAll()
                    }
                }
            } catch {
                print("ERROR SAVING")
                showAlert(title: "Error", message: "Error Saving")
            }
        default:
            print("Unknown Button")
            return
        }
    }
    
    func promptForNewPath() {
        let ac = UIAlertController(title: "Enter New Path Name", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0]
            if (answer.text?.count == 0) {
                self.promptForNewPath()
            }
            self.path = PathMapping(name: answer.text!)
        }

        ac.addAction(submitAction)

        present(ac, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

