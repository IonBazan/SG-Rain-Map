// MARK: - LocationManager
// Wraps CLLocationManager for macOS whenInUse authorization and user-location centering

import CoreLocation
import MapKit
import Observation

@Observable
@MainActor
final class LocationManager: NSObject {
    var userLocation: CLLocationCoordinate2D?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var centerOnUserTrigger: UUID?          // bump this to signal MapView to re-center

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorized, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    func centerOnUser() {
        requestLocation()
        if userLocation != nil {
            centerOnUserTrigger = UUID()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.userLocation = loc.coordinate
            self.centerOnUserTrigger = UUID()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Non-fatal — user location is optional
        print("[LocationManager] Failed: \(error.localizedDescription)")
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorized || manager.authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }
}
