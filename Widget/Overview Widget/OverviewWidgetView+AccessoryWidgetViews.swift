//
//  OverviewWidgetView+AccessoryWidgetViews.swift
//  Solstice
//
//  Created by Daniel Eden on 03/04/2023.
//

#if !os(macOS)
import SwiftUI
import WidgetKit
import Solar
import Suite

extension OverviewWidgetView {
	struct AccessoryCircularView: View {
		@Environment(\.widgetRenderingMode) var renderingMode
		var solar: Solar
		var location: SolsticeWidgetLocation
		
		var body: some View {
			DaylightChart(
				solar: solar,
				timeZone: location.timeZone,
				showEventTypes: false,
				appearance: renderingMode == .fullColor ? .graphical : .simple,
				includesSummaryTitle: false,
				hideXAxis: true,
				markSize: 2.5
			)
			.widgetAccentable()
			.background { AccessoryWidgetBackground() }
			.mask(Circle())
			.widgetLabel {
				Label(solar.daylightDuration.localizedString, systemImage: "sun.max")
			}
		}
	}
	
	struct AccessoryRectangularView: View {
		var isAfterTodaySunset: Bool
		var location: SolsticeWidgetLocation?
		var relevantSolar: Solar?
		var comparisonSolar: Solar?
		
		var body: some View {
			HStack {
				VStack(alignment: .leading) {
					Text("\(Image(systemName: "sun.max")) Daylight \(isAfterTodaySunset ? Text("Tomorrow") : Text("Today"))")
						.font(.headline)
						.widgetAccentable()
						.imageScale(.small)
						.allowsTightening(true)
						.contentTransition(.interpolate)
					
					if let relevantSolar {
						Text(relevantSolar.daylightDuration.localizedString)
							.contentTransition(.numericText())
						
						Group {
							if let comparisonSolar {
								let difference = relevantSolar.daylightDuration - comparisonSolar.daylightDuration
								Text("\(difference >= 0 ? "+" : "-")\(Duration.seconds(abs(difference)).formatted(.units(maximumUnitCount: 2)))")
							} else {
								Text(relevantSolar.safeSunrise...relevantSolar.safeSunset)
							}
						}
						.foregroundStyle(.secondary)
						.modify { content in
							if #available(iOS 17, watchOS 10, macOS 14, *) {
								content
									.transition(.blurReplace)
							} else {
								content
							}
						}
					}
				}
				
				Spacer(minLength: 0)
			}
			.minimumScaleFactor(0.9)
		}
	}
}
#endif
