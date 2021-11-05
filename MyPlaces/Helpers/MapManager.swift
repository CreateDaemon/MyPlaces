//
//  MapManager.swift
//  MyPlaces
//
//  Created by Дмитрий Межевич on 5.11.21.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private var placeCoordinate:CLLocationCoordinate2D?
    private let regionInMetars = 1_000.00
    private var directionsArray: [MKDirections] = []
    
    // Маркер заведения
    func setupPlacemark(place: Places, mapView: MKMapView) {
        
        guard let location = place.location else { return }
         
        CLGeocoder().geocodeAddressString(location) { placemarks, error in
            
            if let error = error {
                print(error)
            }
            
            guard let placemark = placemarks?.first else { return }
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = annotation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // Проверка доступа сервисов геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> Void) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are Disable",
                                massane: "To enable it go: Setting -> Privacy -> Location Services and turn On")
            }
        }
    }
    
    // --- Проверка авторизации приложения для использования сервисов геолокации
    
    // Фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMetars,
                                            longitudinalMeters: regionInMetars)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Строим моршрут от местоположения пользователя до заведения
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> Void) {
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", massane: "Current location is not found")
            return }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsReqvest(from: location) else {
            showAlert(title: "Error", massane: "Distantion is not found")
            return }
        
        let direction = MKDirections(request: request)
        resetMapView(withNew: direction, mapView: mapView)
        
        direction.calculate { respons, error in
            
            if let error = error { print(error); return }
            
            guard let respons = respons else {
                self.showAlert(title: "Error", massane: "Distantion is not available")
                return
            }
            
            for route in respons.routes {
                mapView.addOverlays([route.polyline])
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места: \(distance)км. Приблезительное время пути: \(timeInterval)")
            }
        }
    }
    
    // Настройка запроса для расчёта маршрута
    func createDirectionsReqvest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    // Меняем отображаемую область карты в соотвествии с перемещением пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and loction: CLLocation?, closure: (_ currentLocation: CLLocation) -> Void) {
        
        guard let location = loction else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        
        closure(center)
    }
    
    // Сброс всех ранее построенных маршрутов перед построением нового
    func resetMapView(withNew direction: MKDirections, mapView: MKMapView) {
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(direction)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()

    }
    
    // Определяем центр отображаемой области карты
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Alert
    func showAlert(title: String, massane: String) {
        
        let alert = UIAlertController(title: title, message: massane, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(alertAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
    
}
