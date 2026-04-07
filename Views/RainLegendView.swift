// MARK: - RainLegendView
// Static color legend matching the official weather.gov.sg rain intensity scale

import SwiftUI

struct RainLegendView: View {
    // Approximate colors from the NEA/MSS dBR palette (light rain → heavy rain)
    private let stops: [(color: Color, label: String)] = [
        (.init(red: 0.40, green: 0.80, blue: 1.00), "Light"),
        (.init(red: 0.00, green: 0.60, blue: 1.00), ""),
        (.init(red: 0.00, green: 1.00, blue: 0.00), "Moderate"),
        (.init(red: 1.00, green: 1.00, blue: 0.00), ""),
        (.init(red: 1.00, green: 0.60, blue: 0.00), "Heavy"),
        (.init(red: 1.00, green: 0.00, blue: 0.00), ""),
        (.init(red: 0.80, green: 0.00, blue: 0.80), "Intense"),
    ]

    var body: some View {
        HStack(spacing: 2) {
            Text("Rain:")
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                ForEach(stops.indices, id: \.self) { i in
                    Rectangle()
                        .fill(stops[i].color)
                        .frame(width: 16, height: 8)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 2))

            Text("Intense")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
