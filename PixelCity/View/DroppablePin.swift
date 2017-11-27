//
//  droppablePin.swift
//  PixelCity
//
//  Created by Mohamed SADAT on 27/11/2017.
//  Copyright © 2017 Mohamed SADAT. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
  
  dynamic var coordinate: CLLocationCoordinate2D
  var identifier: String
  
  init(coordinate: CLLocationCoordinate2D, identifier: String) {
    self.coordinate = coordinate
    self.identifier = identifier
    super.init()
  }
  
}
