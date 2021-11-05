//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Межевич on 2.10.21.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    
    let mapManager = MapManager()
    
    static var closureLocation: ((_ location: String?) -> Void)?
    
    var place: Places!
    
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIdentifier = ""
    
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(
                for: mapView,
                   and: previousLocation) { currentLocation in
                       
                       self.previousLocation = currentLocation
                       
                       DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                           self.mapManager.showUserLocation(mapView: self.mapView)
                       }
                   }
        }
    }
    
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
    }
    
    @IBAction func centerViewUserLocation(_ sender: UIButton) {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        MapViewController.closureLocation?(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed(_ sender: UIButton) {
        mapManager.getDirections(for: mapView) { location in
            self.previousLocation = location
        }
    }
    
    @IBAction func closeMap() {
        dismiss(animated: true)
    }
    
    private func setupMapView() {
        
        goButton.isHidden = true
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    
}

//  MARK: - Extention MapVC: CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        guard CLLocationManager.locationServicesEnabled() else { return }
        print(CLLocationManager.locationServicesEnabled())
        
        switch manager.authorizationStatus {
        case .notDetermined:
            mapManager.locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .denied:
            mapManager.showAlert(title: "Your Location is not Availeble",
                      massane: "To give permission Go to: Setting -> MyPlaces -> Location")
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAddress" { mapManager.showUserLocation(mapView: mapView) }
            break
        @unknown default:
            break
        }
        
    }
}


//  MARK: - Extention MapVC Delegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation,
                                                 reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { placemark, error in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemark = placemark?.first else { return }
            let streetName = placemark.thoroughfare
            let buildNumber = placemark.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil, buildNumber != nil {
                    self.addressLabel.text = "\(streetName!) \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = "No Adress"
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let rendere = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        rendere.strokeColor = .blue
        return rendere
    }
}
