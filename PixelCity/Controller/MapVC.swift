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
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {
  
  // Outlets
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var pullUpView: UIView!
  @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
  
  // Variables
  var locationManager = CLLocationManager()
  let authorizationStatus = CLLocationManager.authorizationStatus()
  let regionRadius: Double = 1000
  var screenSize = UIScreen.main.bounds
  var spinner: UIActivityIndicatorView?
  var progressLabel: UILabel?
  
  var flowLayout =  UICollectionViewFlowLayout()
  var collectionView: UICollectionView?
  
  var imageUrlArray = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    locationManager.delegate = self
    configureLocationServices()
    addDoubleTap()
    
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
    collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
    collectionView?.delegate = self
    collectionView?.dataSource = self
    
    collectionView?.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    pullUpView.addSubview(collectionView!)
  }

  func addDoubleTap() {
    let doubletap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
    doubletap.numberOfTapsRequired = 2
    doubletap.delegate = self
    mapView.addGestureRecognizer(doubletap)
  }
  
  func addSwipe() {
    let swipe =  UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
    swipe.direction = .down
    pullUpView.addGestureRecognizer(swipe)
  }
  
  func animateViewUp() {
    pullUpViewHeightConstraint.constant = 300
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
  
  @objc func animateViewDown() {
    pullUpViewHeightConstraint.constant = 0
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
  
  func addSpinner() {
    spinner = UIActivityIndicatorView()
    spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
    spinner?.activityIndicatorViewStyle = .whiteLarge
    spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    spinner?.startAnimating()
    collectionView?.addSubview(spinner!)
  }
  
  func removeSpinner() {
    if spinner != nil {
      spinner?.removeFromSuperview()
    }
  }
  
  func addProgressLabel() {
    progressLabel = UILabel()
    progressLabel?.frame = CGRect(x: (screenSize.width / 2) - 100, y: 175, width: 200, height: 40)
    progressLabel?.font = UIFont(name: "Avenir", size: 17)
    progressLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    progressLabel?.textAlignment = .center
//    progressLabel?.text = "12/40 Photos chargées..."
    collectionView?.addSubview(progressLabel!)

  }
  
  func removeProgressLabel() {
    if progressLabel != nil {
      progressLabel?.removeFromSuperview()
    }
  }
  
  @IBAction func locationButtonPressed(_ sender: Any) {
    if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
      centerMapOnUserLocation()
    }
  }
}

extension MapVC: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      return nil
    }
    let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
    pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
    pinAnnotation.animatesDrop = true
    return pinAnnotation
  }
  
  func centerMapOnUserLocation() {
    guard let coordinate = locationManager.location?.coordinate else { return }
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
    mapView.setRegion(coordinateRegion, animated: true)
  }
  
  @objc func dropPin(sender: UITapGestureRecognizer) {
    removePin()
    removeSpinner()
    removeProgressLabel()
    
    animateViewUp()
    addSwipe()
    addSpinner()
    addProgressLabel()
    
    let touchPoint = sender.location(in: mapView)
    let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
    let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
    mapView.addAnnotation(annotation)
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
    mapView.setRegion(coordinateRegion, animated: true)
    retrieveUrls(forAnnotation: annotation) { (true) in
      print(self.imageUrlArray)
    }
  }
  
  func removePin() {
    for annotation in mapView.annotations {
      mapView.removeAnnotation(annotation)
    }
  }
  
  func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
    imageUrlArray = []
    Alamofire.request(flickrUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
      guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
      let photosDict = json["photos"] as! Dictionary<String, AnyObject>
      let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
      
      for photo in photosDictArray {
        let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
        self.imageUrlArray.append(postUrl)
      }
      handler(true)
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

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 4
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell
    return cell!
  }
}

















