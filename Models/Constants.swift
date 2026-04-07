// MARK: - Constants
// Bounding box derived from cheeaun/rain-geojson-sg and confirmed against weather.gov.sg 50km radar

import MapKit

enum RadarConstants {
    // 50km radar coverage bounding box (SGT-based, confirmed April 2026)
    static let northWest = CLLocationCoordinate2D(latitude: 1.475, longitude: 103.565)
    static let southEast = CLLocationCoordinate2D(latitude: 1.156, longitude: 104.130)

    static var boundingMapRect: MKMapRect {
        let topLeft = MKMapPoint(northWest)
        let bottomRight = MKMapPoint(southEast)
        // MKMapKit: x increases eastward, y increases southward (origin at north pole)
        return MKMapRect(
            x: topLeft.x,
            y: topLeft.y,
            width: bottomRight.x - topLeft.x,
            height: bottomRight.y - topLeft.y
        )
    }

    static let defaultCenter = CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)

    // Radar image opacity
    static let radarAlpha: CGFloat = 0.7

    // Auto-refresh interval
    static let refreshInterval: TimeInterval = 300

    // weather.gov.sg 50 km radar image base URL
    // Full pattern: dpsri_70km_<YYYYMMDDHHmm>0000dBR.dpsri.png  (timestamps in SGT)
    static let radarBaseURL = "https://www.weather.gov.sg/files/rainarea/50km/v2/"

    // Number of frames to generate (24 × 5 min = 2 hours)
    static let frameCount = 24
}
