//
//  ShareSolarChartView.swift
//  Solstice
//
//  Created by Daniel Eden on 04/03/2025.
//

import SwiftUI
import Solar

struct ShareSolarChartView<Location: AnyLocation>: View {
	@Environment(\.dismiss) var dismiss
	@EnvironmentObject var timeMachine: TimeMachine
	
	var solar: Solar
	var location: Location
	
	@State var chartAppearance: DaylightChart.Appearance = .graphical
	@State var chartRenderedAsImage: Image?
	@State var imageData: Data?
	
	@State var showLocationName = true
	
	var animated: Bool {
		chartRenderedAsImage != nil
	}
	
	@ViewBuilder
	var daylightChartView: some View {
		DaylightChart(
			solar: solar,
			timeZone: location.timeZone,
			appearance: chartAppearance, scrubbable: true,
			markSize: chartMarkSize
		)
		.if(chartAppearance == .graphical) { content in
			content
				.background {
					SkyGradient(solar: solar)
				}
		}
	}
	
	var deps: [AnyHashable] {
		[showLocationName, solar.date, location, chartAppearance]
	}
	
	private let igStoriesUrl: URL? = URL(string: "instagram-stories://share?source_application=me.daneden.Solstice")
	
	var body: some View {
		NavigationStack {
		List {
			VStack {
				if let chartRenderedAsImage {
					chartRenderedAsImage
						.resizable()
						.aspectRatio(contentMode: .fit)
						.rotation3DEffect(Angle(degrees: animated ? -10 : 10), axis: (x: 0, y: 1, z: 0), perspective: 0.2)
						.rotation3DEffect(Angle(degrees: animated ? -10 : 10), axis: (x: 1, y: 0, z: 0), perspective: 0.2)
						.shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 8)
						.animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animated)
				} else {
					ProgressView()
				}
			}
			.padding()
			.aspectRatio(1, contentMode: .fit)
			
			
			Section {
				Picker(selection: $chartAppearance) {
					ForEach(DaylightChart.Appearance.allCases, id: \.self) { appearance in
						Text(appearance.description)
					}
				} label: {
					Text("Chart appearance")
				}
				.pickerStyle(.segmented)
				
				Toggle(isOn: $showLocationName) {
					Text("Show location name")
				}
			}
			
			#if os(iOS)
			if let igStoriesUrl,
				 UIApplication.shared.canOpenURL(igStoriesUrl) {
				Button {
					guard let url = URL(string: "instagram-stories://share?source_application=me.daneden.Solstice") else {
						return
					}
					
					let solarGradient = SkyGradient(solar: solar)
					
					let pasteboardItems = [[
						"com.instagram.sharedSticker.stickerImage": imageData,
						"com.instagram.sharedSticker.backgroundTopColor": solarGradient.stops.first?.toHex(),
						"com.instagram.sharedSticker.backgroundBottomColor": solarGradient.stops.last?.toHex()
					]]
					
					UIPasteboard.general.setItems(pasteboardItems, options: [.expirationDate: Date().addingTimeInterval(60 * 5)])
					
					UIApplication.shared.open(url)
				} label: {
					Label {
						Text("Share to Instagram Story")
					} icon: {
						Image(.instagram)
					}
				}
				.buttonStyle(.bordered)
				.listRowSeparator(.hidden)
			}
			
			#endif
		}
		.listStyle(.plain)
		.toolbar {
			if let chartRenderedAsImage {
				ToolbarItem(placement: .primaryAction) {
					ShareLink(
						item: chartRenderedAsImage,
						preview: SharePreview("Daylight in \(location.title ?? "Current Location")", image: chartRenderedAsImage)
					)
				}
			}
			
			ToolbarItem(placement: .cancellationAction) {
				Button("Close", systemImage: "xmark") {
					dismiss()
				}
			}
		}
		.navigationTitle("Share image")
		.task(id: deps) {
			self.chartRenderedAsImage = buildChartRenderedAsImage()
		}
	}
	}
	
	func buildChartRenderedAsImage() -> Image? {
		let view = VStack(alignment: .leading, spacing: 0) {
			Label("Solstice", image: "Solstice.SFSymbol")
				.font(.headline)
				.scenePadding()
			
			daylightChartView
			
			HStack {
				VStack(alignment: .leading) {
					if showLocationName {
						Group {
							if let title = location.title {
								Text(title)
							} else {
								Text("Current Location")
							}
						}
						.font(.headline)
					}
					
					let duration = solar.daylightDuration.localizedString
					Text("\(duration) of daylight")
						.foregroundStyle(.secondary)
				}
				
				Spacer()
				
				VStack(alignment: .trailing) {
					Label("\(solar.safeSunrise, style: .time)", systemImage: "sunrise")
					Label("\(solar.safeSunset, style: .time)", systemImage: "sunset")
				}
				.foregroundStyle(.secondary)
			}
			.scenePadding()
		}
			.background(in: .rect(cornerRadius: 20, style: .continuous))
			.frame(width: 450, height: 450)
		
		let imageRenderer = ImageRenderer(content: view)
		imageRenderer.scale = 3
		imageRenderer.isOpaque = false
		
		#if os(macOS)
		guard let image = imageRenderer.nsImage,
					let data = image.pngData(),
					let nsImage = NSImage(data: data) else {
			return nil
		}
		
		imageData = data
		
		return Image(nsImage: nsImage)
		#else
		guard let image = imageRenderer.uiImage,
					let data = image.pngData(),
					let uiImage = UIImage(data: data) else {
			return nil
		}
		
		imageData = data
		
		return Image(uiImage: uiImage)
		#endif
	}
}

#Preview {
		ShareSolarChartView(solar: .init(coordinate: TemporaryLocation.placeholderLondon.coordinate)!, location: TemporaryLocation.placeholderLondon)
		.environmentObject(TimeMachine.preview)
}
