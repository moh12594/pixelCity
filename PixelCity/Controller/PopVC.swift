//
//  PopVC.swift
//  PixelCity
//
//  Created by Mohamed SADAT on 28/11/2017.
//  Copyright © 2017 Mohamed SADAT. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

  @IBOutlet weak var popImageView: UIImageView!
  
  var passedImage: UIImage!
  
  func initData(forImage image: UIImage) {
    self.passedImage = image
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    popImageView.image = passedImage
    addDoubleTap()
  }

  func addDoubleTap() {
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
    doubleTap.numberOfTapsRequired = 2
    doubleTap.delegate = self
    view.addGestureRecognizer(doubleTap)
  }

  @objc func screenWasDoubleTapped() {
    dismiss(animated: true, completion: nil)
  }
}
