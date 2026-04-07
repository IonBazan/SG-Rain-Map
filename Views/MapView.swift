// MARK: - MapView
// NSViewRepresentable wrapping MKMapView for precise overlay and user-location control

import SwiftUI
import MapKit
import AppKit

struct MapView: NSViewRepresentable {
    @Binding var radarImage: NSImage?
    @Binding var region: MKCoordinateRegion
    var centerOnUserTrigger: UUID?
    var userLocation: CLLocationCoordinate2D?

    func makeNSView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: false)

        // Add the radar overlay once — only the renderer's image will change
        let overlay = RadarOverlay(
            coordinate: RadarConstants.defaultCenter,
            rect: RadarConstants.boundingMapRect
        )
        mapView.addOverlay(overlay, level: .aboveRoads)

        return mapView
    }

    func updateNSView(_ mapView: MKMapView, context: Context) {
        // Update the renderer's image and force a redraw
        for overlay in mapView.overlays {
            if let radarOverlay = overlay as? RadarOverlay,
               let renderer = mapView.renderer(for: radarOverlay) as? RadarOverlayRenderer {
                renderer.radarImage = radarImage
                renderer.setNeedsDisplay()
            }
        }

        // If the caller bumped centerOnUserTrigger, animate to user location
        if context.coordinator.lastCenterTrigger != centerOnUserTrigger,
           let loc = userLocation {
            context.coordinator.lastCenterTrigger = centerOnUserTrigger
            let centeredRegion = MKCoordinateRegion(center: loc, span: RadarConstants.defaultSpan)
            mapView.setRegion(centeredRegion, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: - Coordinator

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var lastCenterTrigger: UUID?

        init(_ parent: MapView) { self.parent = parent }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let radarOverlay = overlay as? RadarOverlay {
                let renderer = RadarOverlayRenderer(overlay: radarOverlay)
                renderer.radarImage = parent.radarImage
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
