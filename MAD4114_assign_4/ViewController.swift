//
//  ViewController.swift
//  MAD4114_assign_4
//
//  Created by Stainley A Lebron R on 2023-01-15.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    var locationManager = CLLocationManager()
    var places: [Place] = []
    //var annotations: [MKAnnotation] = [MKAnnotation]()
    var numberTap: Int = 0
    var numbersOfAnnotations: Int = 0
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        map.isZoomEnabled = false
        map.showsUserLocation = false
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //let latitude: CLLocationDegrees = 43.64312520699445
        //let longitude: CLLocationDegrees = -79.38692805397866
        
        let oneTapPress = UITapGestureRecognizer(target: self, action: #selector(addOneTapAnnotation))
        oneTapPress.delaysTouchesBegan = true
        map.addGestureRecognizer(oneTapPress)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(removeAnnotation))
        longPress.delaysTouchesBegan = true
        //longPress.numberOfTapsRequired = 2
        map.addGestureRecognizer(longPress)
        
        map.delegate = self
                        
    }

    //MARK: show updating location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude)
    }

    //MARK: Display my current location
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
        let latitudeDelta: CLLocationDegrees = 0.7
        let longitudeDelta: CLLocationDegrees = 0.7
        
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        
        map.setRegion(region, animated: true)
    }
    
    //MARK: Add Polyne
    func addPolyline() {
        //self.places.append(places[0])
        
        //let locations = places.map { $0.coordinate }
        //let locations = map.annotations.map( { $0.coordinate; $0.title})
        var myAnnotations: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        for (index, anno) in map.annotations.enumerated() {
            if anno.title == "My Location" {
                continue
            }
            myAnnotations.append(anno.coordinate)
        }
        myAnnotations.append(myAnnotations[0])
        let polyline = MKPolyline(coordinates: myAnnotations, count: myAnnotations.count)
        
        /*
        for index in 0 ..< places.count - 1 {
            let distance: Double = getDistance(from: places[index].coordinate, to: places[index + 1].coordinate)
            
            print("\(Double( round(distance * 0.001))) Km")
            polyline.title = "\(distance) Km"
        }
        */
        map.addOverlay(polyline)
     
    }
    
    @objc func removeAnnotation(point: UITapGestureRecognizer) {
        print("\(map.annotations.count) NUMBERS OF ANNOTATIONS")

        var isRemoved: Bool = false

        let pointTouched: CGPoint = point.location(in: map)
        
        let coord =  map.convert(pointTouched, toCoordinateFrom: map)
        let loc: CLLocationCoordinate2D = coord
        
        //let myAnnotationTitle = map.annotations.map({$0.title})
          
        // from coordinate get city name
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: loc.latitude, longitude: loc.longitude), completionHandler: { (placemarks, error) in
            if error != nil {
                print(error)
            } else {
                DispatchQueue.main.async {
                    if let placeMark = placemarks?[0] {
                        
                        if placeMark.locality != nil {
                            
                            for (index, myAnnotation) in self.map.annotations.enumerated() {
                                
                                if myAnnotation.title == placeMark.locality {
                                    isRemoved = true
                                    self.removeOverlays()
                                    self.map.removeAnnotation(myAnnotation)

                                }
                            }
                        }
                        print("\(self.map.annotations.count) NUMBERS OF ANNOTATIONS")

                    }
                }
            }
            
        })
        //let areaSelection = MKCircle(center: coord, radius: 10)
            
        /*
        let selectedAnnotation: [MKAnnotation] = map.selectedAnnotations
        
        for ann in selectedAnnotation {
            
            for allAnnotation in map.annotations {
                if ann.title == allAnnotation.title {
                    print("\(String(describing: ann.title!)) TITLE")
                    
                    
                    for (index, place) in places.enumerated() {
                        if place.title! == ann.title! {
                            print("\(String(describing: place.title))  and \(String(describing: ann.title) )")
                            print("\(place)  and \(index)")
                            places.remove(at: index)
                            print("\(places.count) NEW ARRAY CAPACITY")
                            break
                        }
                    }
                }
            }
            //places.removeFirst()
            print("\(String(describing: ann.title!))  -> REMOVE THIS")
            
            removeOverlays()
            map.removeAnnotation(ann)
        }
        */    
    }
    
    func removeOverlays() {
        for polygon in map.overlays {
            map.removeOverlay(polygon)
        }
    }
    
    func addPolygon() {
        //let coordinates = places.map { $0.coordinate }
        
        //let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        
        var myAnnotations: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        for (index, anno) in map.annotations.enumerated() {
            if anno.title == "My Location" {
                continue
            }
            myAnnotations.append(anno.coordinate)
            print("\(anno.title) <->  \(index)")
        }
        myAnnotations.append(myAnnotations[0])
        let polygon = MKPolygon(coordinates: myAnnotations, count: myAnnotations.count)
        
        map.addOverlay(polygon)
    }
    
    func removePin() {
        for annotation in map.annotations {

            map.removeAnnotation(annotation)
        }
    }
    
    //MARK: Add MKPoint Annotation to the map
    @objc func addOneTapAnnotation(gestureRecognizer: UIGestureRecognizer) {
        
        numbersOfAnnotations = map.annotations.count
        
        let touchPoint = gestureRecognizer.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        
        let geoCoder = CLGeocoder()
               
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler: {(placemarks, error) in
            
            if error != nil {
                print(error!)
            } else {
                DispatchQueue.main.async {
                    if let placeMark = placemarks?[0] {
                        
                        if placeMark.locality != nil {
                            print(placeMark.locality!)
                            let place = Place(title: placeMark.locality!,coordinate: coordinate)

                            if self.numbersOfAnnotations <= 2 {
                                self.map.addAnnotation(place)
                            }
                            
                            if self.numbersOfAnnotations == 2 {
                                self.addPolyline()
                                self.addPolygon()
                            }
                        }
                    }
                }
            }
        })
      
    }
}

func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
    let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
    let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
    
    return from.distance(from: to)
}



extension ViewController: CLLocationManagerDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.polyline.title = overlay.title ?? ""
            renderer.strokeColor = .green
            renderer.lineWidth = 3
            return renderer
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = .red.withAlphaComponent(0.5)
            renderer.polygon.title = overlay.title ?? ""
            return renderer
            
        }
        return MKOverlayRenderer()
    }
}

extension ViewController: MKMapViewDelegate {
    
}
