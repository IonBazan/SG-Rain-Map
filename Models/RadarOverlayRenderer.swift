// MARK: - RadarOverlayRenderer
// Renders the radar PNG image into the MKMapView overlay at the correct geographic position

import MapKit
import AppKit

final class RadarOverlayRenderer: MKOverlayRenderer {
    var radarImage: NSImage?

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let image = radarImage,
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }

        let drawRect = self.rect(for: overlay.boundingMapRect)
        guard drawRect.intersects(self.rect(for: mapRect)) else { return }

        context.saveGState()
        context.setAlpha(RadarConstants.radarAlpha)

        // CGContext origin is bottom-left; flip vertically so the PNG renders right-side up
        context.translateBy(x: drawRect.minX, y: drawRect.minY + drawRect.height)
        context.scaleBy(x: 1.0, y: -1.0)

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: drawRect.width, height: drawRect.height))

        context.restoreGState()
    }
}
