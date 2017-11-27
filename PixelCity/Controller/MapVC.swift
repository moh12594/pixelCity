//
//  MapVC.swift
//  PixelCity
//
//  Created by Mohamed SADAT on 26/11/2017.
//  Copyright © 2017 Mohamed SADAT. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate {
  
  // Outlets
  @IBOutlet weak var mapView: MKMapView!
  
  // Variables
  var locationManager = CLLocationManager()
  let authorizationStatus = CLLocationManager.authorizationStatus()
  let regionRadius: Double = 1000
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    locationManager.delegate = self
    configureLocationServices()
    addDoubleTap()
  }

  func addDoubleTap() {
    let doubletap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
    doubletap.numberOfTapsRequired = 2
    doubletap.delegate = self
    mapView.addGestureRecognizer(doubletap)
  }
  
  @IBAction func locationButtonPressed(_ sender: Any) {
    if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
      centerMapOnUserLocation()
    }
  }
}

extension MapVC: MKMapViewDelegate {
  func centerMapOnUserLocation() {
    guard let coordinate = locationManager.location?.coordinate else { return }
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
    mapView.setRegion(coordinateRegion, animated: true)
  }
  
  @objc func dropPin(sender: UITapGestureRecognizer) {
    removePin()
    let touchPoint = sender.location(in: mapView)
    let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
    let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
    mapView.addAnnotation(annotation)
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
    mapView.setRegion(coordinateRegion, animated: true)
  }
  
  func removePin() {
    for annotation in mapView.annotations {
      mapView.removeAnnotation(annotation)
    }
  }
}

extension MapVC: CLLocationManagerDelegate {
  
  func configureLocationServices() {
    if authorizationStatus == .notDetermined {
      locationManager.requestAlwaysAuthorization()
    } else {
      return
    }
  }
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    centerMapOnUserLocation()
  }
}

