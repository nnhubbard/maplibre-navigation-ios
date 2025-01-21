//
//  CarPlayUserLocation.swift
//  Cachly
//
//  Created by Nicholas Hubbard on 1/19/25.
//  Copyright © 2025 Zed Said Studio LLC. All rights reserved.
//

import Foundation
import MapLibre
import UIKit

public class CarPlayUserLocation: MLNUserLocationAnnotationView {
    
    let size: CGFloat = 40
    var puckImageView: UIImageView!

    // -update is a method inherited from MGLUserLocationAnnotationView. It updates the appearance of the user location annotation when needed. This can be called many times a second, so be careful to keep it lightweight.
    public override func update() {
        if frame.isNull {
            frame = CGRect(x: size/2, y: size/2, width: size, height: size)
            return setNeedsLayout()
        }

        // Check whether we have the user’s location yet.
        if CLLocationCoordinate2DIsValid(userLocation!.coordinate) {
            setupLayers()
            //updateHeading()
        }
    }

    private func setupLayers() {
        
        if puckImageView == nil {
            
            let puckImage = CarPlayNavigationStyleKit.imageOfUserLocationPuck(puckColor: .systemBlue)
            puckImageView = UIImageView(image: puckImage)
            puckImageView.transform = CGAffineTransformMakeScale(1.0, 0.7)
            self.addSubview(puckImageView)
            
        }
        
    }

}
