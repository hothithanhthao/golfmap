//
//  ViewController.swift
//  MapExample3
//
//  Created by Pasi Manninen on 21/05/2018.
//  Copyright © 2018 Pasi Manninen. All rights reserved.
//

import UIKit
import MapKit

class EmployeeMarkerView: MKMarkerAnnotationView /* MKMarkerAnnotationView */ {
    override var annotation: MKAnnotation? {
        willSet {
            guard let employee = newValue as? Place else { return }
            // show callout
            canShowCallout = true
            calloutOffset = CGPoint(x: -5 , y: 5)
            let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                    size: CGSize(width:60, height: 60)))
            let subtile = employee.address + "\n" + employee.phone + "\n" + employee.email + "\n" + employee.web + "\n" + employee.text
            rightCalloutAccessoryView = mapsButton
            markerTintColor = employee.markerTintColor
            glyphText = String(employee.course)
            let detailLabel = UILabel()
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.numberOfLines = 10
            detailLabel.text = subtile
            detailCalloutAccessoryView = detailLabel
            
            // show image
            
            // load image from url
            /*
            print("\(employee.imageURL)")
            let url = URL(string: employee.imageURL)
            let imageData = try? Data(contentsOf: url!)
            if imageData != nil {
                image = UIImage(data: imageData!)
                
                let size = CGSize(width: 30, height: 30)
                UIGraphicsBeginImageContext(size)
                image!.draw(in: CGRect(x:0, y:0, width:size.width, height:size.height))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                image = resizedImage
            }
 */
            
        }
    }
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(latitude)
        try container.encode(longitude)
    }
    public init(from decoder: Decoder) throws {
        self.init()
        var container = try decoder.unkeyedContainer()
        latitude = try container.decode(Double.self)
        longitude = try container.decode(Double.self)
    }
}

class Place: NSObject, MKAnnotation, Codable {
    // for annotation
    let coordinate: CLLocationCoordinate2D
    var title: String? { return course }
    
    // for employee
    let course: String
    let type: String
    let address: String
    let phone: String
    let email : String
    let text: String
    let web: String
    
    
    
    public init(coordinate: CLLocationCoordinate2D, course: String, type: String,address: String, phone: String, email: String, web:String, text: String) {
        self.course = course
        self.coordinate = coordinate
        self.address = address
        self.type = type
        self.phone = phone
        self.email = email
        self.web = web
        self.text = text
        
        super.init()
    }
    var markerTintColor: UIColor  {
        switch type {
        case "Kulta":
            return .yellow
        case "Etu":
            return .cyan
        case "?":
            return .blue
        default:
            return .brown
        }
    }
}

// MKMapViewDelegate is used to get selection from MapView
class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    // employees
    var places = [Place]()

    
    
    // the map view needs an annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // indentifier
        let identifier = "EmployeeMarker"
        
        // don't modify user location annotation
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        // reuse the annotation if possible
        var annotationView: EmployeeMarkerView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? EmployeeMarkerView
        
        // if we can't reuse, create a new one
        if annotationView == nil {
            annotationView = EmployeeMarkerView(annotation: annotation, reuseIdentifier: identifier)
        }

        //annotationView?.glyphText =
      //  annotationView?.markerTintColor = places.
        // return annotation view
        return annotationView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
       // mapView.register(EmployeeMarkerView.self,
       //                  forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        // load json from web server
        loadJSONFromWeb()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func loadJSONFromWeb() {
        // create URL
        let urlString = "http://ptm.fi/data/golf_courses_ios.json"
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            return
        }
        
        // create URLSession task
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // print possible error message
            if error != nil {
                print(error!.localizedDescription)
            }
            
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            // decode JSON data
            let decoder = JSONDecoder()
            do {
                self.places = try decoder.decode([Place].self, from: responseData)
                // show employee annotations
                DispatchQueue.main.async {
                    self.mapView.addAnnotations(self.places)
                }
            } catch let error {
                print(error)
            }
            
            }.resume() // start task
    }
   
    // some annotation calloutAccessoryControlTapped is tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("CalloutAccessoryControlTapped tapped!")
        let place = view.annotation as! Place
        let course = place.course
        
        let ac = UIAlertController(title: course, message: "This employee annotation callout button is tapped", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    // some annotation is selected from the map
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("MKAnnotationView tapped!")
        if view.annotation is MKUserLocation {
            return
        }
        let selectedAnnotation = view.annotation as! Place
        let title = selectedAnnotation.course
        print("tapped: \(title)")
    }
    
}

