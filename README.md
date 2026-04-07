# SG Rain Map

A clean, native macOS app for live Singapore rain radar — built with SwiftUI and MapKit.

> Inspired by the official [MyENV](https://www.nea.gov.sg/myenv) iOS/Android app and the [MSS Rain Area](https://www.weather.gov.sg/weather-rain-area-50km/) web page, which provide the same radar data on other platforms. This app brings a first-class native experience to macOS.

---

## Screenshots

![Screenshot](/screenshot.png)

---

## Features

- **Live radar overlay** — 50 km rain radar from the Meteorological Service Singapore (MSS), refreshed every 5 minutes
- **Time scrub** — slide through the last ~65 minutes of frames to see how rain is moving
- **Smart frame detection** — uses the NEA Rain Area API to fetch exactly which frames are published; no guessing or probing required
- **Instant scrubbing** — all frames are preloaded in the background so the slider responds immediately
- **Current location** — one tap centers the map on you (requires Location permission)
- **Auto-refresh** — updates in the background every 5 minutes while the window is open
- **Rain intensity legend** — colour scale matching the official NEA/MSS palette
- Keyboard shortcuts: `⌘R` refresh · `⌘L` locate me

---

## Requirements

| Requirement | Version |
|-------------|---------|
| macOS       | 14.0 Sonoma or later |
| Xcode       | 15 or later |
| Swift       | 6 |

---

## Building

1. Clone the repository:
   ```bash
   git clone https://github.com/IonBazan/SG-Rain-Map.git
   cd sg-rain-radar
   ```

2. Open `SG Rain Map.xcodeproj` in Xcode.

3. Select the **SG Rain Map** scheme and your Mac as the run destination.

4. Press `⌘R` to build and run.

> **Note:** The app requires the `com.apple.security.network.client` entitlement (already set in `SG Rain Map.entitlements`) to fetch radar images. No API key or account is needed — all data is publicly available from nea.gov.sg.

---

## Project structure

```
SG Rain Map/
├── Models/
│   ├── Constants.swift              Bounding box, defaults, shared constants
│   ├── MapOverlay.swift           MKOverlay subclass for the radar PNG
│   └── MapOverlayRenderer.swift   CGContext-based overlay renderer
├── Services/
│   └── MapService.swift           NEA API client, frame list, image fetch
├── ViewModels/
│   ├── MapViewModel.swift         State, preloading, auto-refresh
│   └── LocationManager.swift        CLLocationManager wrapper
└── Views/
    ├── ContentView.swift             Main window layout
    ├── MapView.swift                 NSViewRepresentable MKMapView wrapper
    └── RainLegendView.swift          Rain intensity colour scale
```

---

## Data source

Frame availability is determined via the **NEA Rain Area API**:

```
GET https://www.nea.gov.sg/api/RainArea/GetRecentData/{unix_seconds}
```

Returns a JSON array of `{ Url, DateTime, SortingTime }` objects — the exact set of frames currently published. Images are served from `nea.gov.sg`. Timestamps are in **Singapore Standard Time (SGT, UTC+8)**.

The radar bounding box coordinates (`1.156°N–1.475°N`, `103.565°E–104.130°E`) are derived from [cheeaun/rain-geojson-sg](https://github.com/cheeaun/rain-geojson-sg).

---

## Privacy

- **Location** — used only to center the map. Never stored or transmitted.
- **Network** — only connects to `nea.gov.sg` to fetch publicly available radar data.
- No analytics, no tracking, no accounts.

---

## Contributing

Pull requests are welcome. Please open an issue first for larger changes.

1. Fork the repo and create a feature branch.
2. Keep changes focused — one feature or fix per PR.
3. Test on macOS 14 Sonoma and macOS 15 Sequoia if possible.

---

## Acknowledgements

- [National Environment Agency (NEA)](https://www.nea.gov.sg/) — Rain Area API and radar data
- [cheeaun/rain-geojson-sg](https://github.com/cheeaun/rain-geojson-sg) — radar bounding box reference
- Inspired by the official **MyENV** app (iOS/Android) by the National Environment Agency of Singapore

---

## License

[MIT](LICENSE) © 2026 SG Rain Map Contributors
