// MARK: - RadarOverlay
// Custom MKOverlay that defines the geographic bounds of the radar PNG on the map

import MapKit

final class RadarOverlay: NSObject, MKOverlay {
    let coordinate: CLLocationCoordinate2D
    let boundingMapRect: MKMapRect

    init(coordinate: CLLocationCoordinate2D, rect: MKMapRect) {
        self.coordinate = coordinate
        self.boundingMapRect = rect
        super.init()
    }
}
