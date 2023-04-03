//
//  CountdownWidget.swift
//  Solstice
//
//  Created by Daniel Eden on 03/04/2023.
//

import WidgetKit
import SwiftUI
import Solar

struct CountdownWidget: Widget {
#if os(iOS)
	static var supportedFamilies: [WidgetFamily] = [.systemSmall, .systemMedium, .accessoryInline, .accessoryRectangular, .accessoryCircular]
#elseif os(macOS)
	static var supportedFamilies: [WidgetFamily] = [.systemSmall, .systemMedium]
#elseif os(watchOS)
	static var supportedFamilies: [WidgetFamily] = [.accessoryInline, .accessoryCircular, .accessoryRectangular, .accessoryCorner]
#endif
	
	var body: some WidgetConfiguration {
		IntentConfiguration(
			kind: SolsticeWidgetKind.CountdownWidget.rawValue,
			intent: ConfigurationIntent.self,
			provider: CountdownWidgetTimelineProvider()
		) { timelineEntry in
			let solar = Solar(for: timelineEntry.date, coordinate: timelineEntry.location.coordinate)!
			return CountdownWidgetView(solar: solar, location: timelineEntry.location)
		}
		.configurationDisplayName("Sunrise/Sunset Countdown")
		.description("See the time remaining until the next sunrise/sunset")
		.supportedFamilies(CountdownWidget.supportedFamilies)
	}
}
