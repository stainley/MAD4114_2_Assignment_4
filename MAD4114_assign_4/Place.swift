//
//  Place.swift
//  MAD4114_assign_4
//
//  Created by Stainley A Lebron R on 2023-01-15.
//

import Foundation
import MapKit

class Place: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    var places: [Place]!
    
    init(title: String? = nil, subtitle: String? = nil, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        self.subtitle = subtitle
    }
    
    func setTitle(title: String) {
        self.title = title
    }
    
    func getTitle() -> String? {
        return self.title
    }
 
}
