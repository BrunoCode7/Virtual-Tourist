//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Baraa Hesham on 5/12/19.
//  Copyright © 2019 Baraa Hesham. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func onMapLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UILongPressGestureRecognizer.State.began{
            let location = sender.location(in: self.mapView)
            
            let coordinates = self.mapView.convert(location, toCoordinateFrom: self.mapView)
            
            print(coordinates)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            
            self.mapView.addAnnotation(annotation)
        }
        
    }
}

