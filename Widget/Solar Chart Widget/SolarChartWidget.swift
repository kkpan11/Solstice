//
//  SolarChartWidget.swift
//  Solstice
//
//  Created by Daniel Eden on 12/04/2023.
//

#if !os(macOS)
import WidgetKit
import SwiftUI

struct SolarChartWidget: Widget {
	static var supportedFamilies: [WidgetFamily] = [.accessoryRectangular]
	
	var body: some WidgetConfiguration {
		IntentConfiguration(
			kind: SolsticeWidgetKind.SolarChartWidget.rawValue,
			intent: ConfigurationIntent.self,
			provider: SolarChartWidgetTimelineProvider()
		) { timelineEntry in
			SolarChartWidgetView(entry: timelineEntry)
				.widgetURL(timelineEntry.location?.url)
		}
		.configurationDisplayName("Solar Chart")
		.description("Follow the sun's journey throughout the day")
		.supportedFamilies(Self.supportedFamilies)
	}
}
#endif
