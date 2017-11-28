//
//  Constants.swift
//  PixelCity
//
//  Created by Mohamed SADAT on 28/11/2017.
//  Copyright © 2017 Mohamed SADAT. All rights reserved.
//

import Foundation


let API_KEY = "de7b76be949df0e02ae113292548387e"
let SECRET_KEY = "5021767bab7f06cc"

func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
  return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
}

