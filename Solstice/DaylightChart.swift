//
//  DaylightChart.swift
//  Solstice
//
//  Created by Daniel Eden on 12/02/2023.
//

import SwiftUI
import Charts
import Solar
import Charts
import CoreLocation

struct DaylightChart: View {
	var solar: Solar
	var timeZone: TimeZone
	
	@State private var selectedEvent: Solar.Event?
	@State private var currentX: Date?
	
	var eventTypes: [Solar.Phase] = Solar.Phase.allCases
	var includesSummaryTitle = true
	var hideXAxis = false
	
	var summaryFont: Font {
		#if os(watchOS)
		.headline
		#elseif os(macOS)
		.title
		#else
		.title2
		#endif
	}
	
	var markSize: Double = 6
	
	var body: some View {
		VStack(alignment: .leading) {
			if includesSummaryTitle {
				VStack(alignment: .leading) {
					Text(solar.differenceString)
						.font(summaryFont)
						.fontWeight(.semibold)
						.opacity(selectedEvent == nil ? 1 : 0)
						.overlay(alignment: .leading) {
							if let selectedEvent {
								VStack(alignment: .leading) {
									Text(selectedEvent.label)
										.foregroundStyle(.secondary)
									Text("\(selectedEvent.date, style: .time)")
										.font(.title2)
								}
							}
						}
				}
				#if !os(macOS)
				.padding()
				#endif
				.fontDesign(.rounded)
				.fontWeight(.semibold)
			}
			
			
			Chart {
				ForEach(solarEvents) { solarEvent in
					if solarEvent.phase != .currentTime {
						PointMark(
							x: .value("Event Time", solarEvent.date ),
							y: .value("Event", yValue(for: solarEvent.date ))
						)
						.foregroundStyle(pointMarkColor(for: solarEvent.phase))
						.opacity(solarEvent.phase == .night
										 || solarEvent.phase == .day
										 || solarEvent.phase == .sunrise
										 || solarEvent.phase == .sunset ? 0 : 1)
						.symbolSize(markSize * .pi * 2)
					}
				}
			}
			.chartYAxis(.hidden)
			.chartXAxis(hideXAxis ? .hidden : .automatic)
			.chartYScale(domain: -1.2...1.2)
			.chartXScale(domain: solar.startOfDay...solar.endOfDay)
			.chartOverlay { proxy in
				GeometryReader { geo in
					Rectangle()
#if !os(watchOS)
						.fill(.regularMaterial)
#else
						.fill(.tertiary)
					#endif
						.frame(width: geo.size.width, height: 1)
						.offset(y: proxy.position(forY: yValue(for: solar.safeSunrise.withTimeZoneAdjustment(for: timeZone))) ?? 0)
					
					ZStack {
						ZStack {
							Circle()
								.fill(.background)
								.overlay {
									Circle()
										.strokeBorder(style: StrokeStyle(lineWidth: 2))
										.fill(.primary)
								}
								.frame(width: markSize * 2.5, height: markSize * 2.5)
								.position(
									x: proxy.position(forX: timeZoneAdjustedDate) ?? 0,
									y: proxy.position(forY: yValue(for: timeZoneAdjustedDate)) ?? 0
								)
								.shadow(color: .secondary.opacity(0.5), radius: 2)
						}
						.background {
							Rectangle()
								.fill(.clear)
								.background(.background.opacity(0.3))
								.mask {
									LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
								}
						}
						.mask(alignment: .bottom) {
							Rectangle()
								.frame(height: geo.size.height - (proxy.position(forY: yValue(for: solar.safeSunrise.withTimeZoneAdjustment(for: timeZone))) ?? 0))
						}
						
						ZStack {
							Circle()
								.fill(.primary)
								.frame(width: markSize * 2.5, height: markSize * 2.5)
								.position(
									x: proxy.position(forX: timeZoneAdjustedDate) ?? 0,
									y: proxy.position(forY: yValue(for: timeZoneAdjustedDate)) ?? 0
								)
								.shadow(color: .secondary.opacity(0.5), radius: 4)
						}
						.mask(alignment: .top) {
							Rectangle()
								.frame(height: proxy.position(forY: yValue(for: solar.safeSunrise.withTimeZoneAdjustment(for: timeZone))) ?? 0)
						}
					}
					
					if let selectedEvent {
						Rectangle()
							.fill(.primary)
							.frame(width: 2, height: geo.size.height)
							.position(x: proxy.position(forX: selectedEvent.date) ?? 0, y: geo.size.height / 2)
							.overlay {
								Rectangle()
									.stroke(style: StrokeStyle(lineWidth: 1))
									.fill(.background)
									.frame(width: 2, height: geo.size.height)
									.position(x: proxy.position(forX: selectedEvent.date) ?? 0, y: geo.size.height / 2)
							}
					}
					
					Rectangle()
						.fill(Color.clear)
						.contentShape(Rectangle())
					#if os(iOS)
						.gesture(DragGesture()
							.onChanged { value in
								let start = geo[proxy.plotAreaFrame].origin.x
								let xCurrent = value.location.x - start
								
								if let date: Date = proxy.value(atX: xCurrent),
									 let nearestEvent = solarEvents.first(where: { abs($0.date.distance(to: date)) < 60 * 30 && $0.phase != .currentTime }){
									selectedEvent = nearestEvent
								}
							}
							.onEnded { _ in
								selectedEvent = nil
							})
					#elseif os(macOS)
						.onContinuousHover { value in
							switch value {
							case .active(let point):
								let start = geo[proxy.plotAreaFrame].origin.x
								let xCurrent = point.x - start
								
								if let date: Date = proxy.value(atX: xCurrent),
									 let nearestEvent = solarEvents.first(where: { abs($0.date.distance(to: date)) < 60 * 30 && $0.phase != .currentTime }){
									selectedEvent = nearestEvent
								}
							case .ended:
								selectedEvent = nil
							}
						}
					#endif
				}
			}
			.chartBackground { proxy in
				Path { path in
					if let firstPoint = hours.first,
						 let x = proxy.position(forX: firstPoint),
						 let y = proxy.position(forY: yValue(for: firstPoint)) {
						path.move(to: CGPoint(x: x, y: y))
					}
					
					hours.forEach { hour in
						let x = proxy.position(forX: hour) ?? 0
						let y = proxy.position(forY: yValue(for: hour)) ?? 0
						path.addLine(to: CGPoint(x: x, y: y))
					}
					
					if let lastPoint = hours.last,
						 let x = proxy.position(forX: lastPoint),
						 let y = proxy.position(forY: yValue(for: lastPoint)) {
						path.move(to: CGPoint(x: x, y: y))
					}
				}
				.strokedPath(StrokeStyle(lineWidth: markSize, lineCap: .round, lineJoin: .round))
				.fill(.linearGradient(stops: [
					Gradient.Stop(color: .secondary.opacity(0), location: 0),
					Gradient.Stop(color: .secondary.opacity(0.2), location: 2 / 6),
					Gradient.Stop(color: .secondary.opacity(0.6), location: 1),
				], startPoint: .bottom, endPoint: .top))
			}
			.foregroundStyle(.primary)
		}
	}
	
}

extension DaylightChart {
	var formatter: RelativeDateTimeFormatter {
		let formatter = RelativeDateTimeFormatter()
		return formatter
	}
	
	var relativeEventTimeString: String {
		if let selectedEvent,
			 Calendar.autoupdatingCurrent.isDateInToday(selectedEvent.date) {
			return " (\(formatter.localizedString(for: selectedEvent.date, relativeTo: solar.date.withTimeZoneAdjustment(for: timeZone))))"
		}
		return ""
	}
	
	var timeZoneAdjustedDate: Date {
		let date = solar.date
		let components = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute, .second], from: solar.date.withTimeZoneAdjustment(for: timeZone))
		
		return Calendar.autoupdatingCurrent.date(
			bySettingHour: components.hour ?? 0,
			minute: components.minute ?? 0,
			second: components.second ?? 0,
			of: date
		) ?? solar.date.withTimeZoneAdjustment(for: timeZone)
	}
	
	var solarEvents: Array<Solar.Event> {
		solar.events.map { event in
			Solar.Event(label: event.label,
									date: event.date.withTimeZoneAdjustment(for: timeZone),
									phase: event.phase)
		}
		.filter { event in
			eventTypes.contains { phase in
				event?.phase == phase
			}
		}
		.compactMap { $0 }
	}
	
	var hours: Array<Date> {
		stride(from: solar.startOfDay, through: solar.endOfDay, by: 60 * 30).compactMap { $0 }
	}
	
	var startOfDay: Date { solar.startOfDay.withTimeZoneAdjustment(for: timeZone) }
	var endOfDay: Date { solar.endOfDay.withTimeZoneAdjustment(for: timeZone) }
	var dayLength: TimeInterval { startOfDay.distance(to: endOfDay) }
	
	var noonish: Date { startOfDay.addingTimeInterval(dayLength / 2) }
	
	var culminationDelta: TimeInterval { solar.peak.withTimeZoneAdjustment(for: timeZone).distance(to: noonish) }
	
	var daylightProportion: Double { solar.daylightDuration / dayLength }
	
	func pointMarkColor(for eventPhase: Solar.Phase) -> HierarchicalShapeStyle {
		switch eventPhase {
		case .astronomical:
			return .quaternary
		case .nautical:
			return .tertiary
		case .civil:
			return .secondary
		default:
			return .primary
		}
	}
	
	func resetSelectedEvent() {
		selectedEvent = solarEvents.filter {
			$0.phase == .sunset || $0.phase == .sunrise
		}.sorted(by: { a, b in
			a.date.compare(.now) == .orderedDescending
		}).first
	}
	
	func progressValue(for date: Date) -> Double {
		return (date.distance(to: startOfDay) - culminationDelta) / dayLength
	}
	
	func yValue(for date: Date) -> Double {
		return sin(progressValue(for: date) * .pi * 2 - .pi / 2)
	}
}

struct DaylightChart_Previews: PreviewProvider {
	static var previews: some View {
		DaylightChart(
			solar: Solar(
				coordinate: TemporaryLocation.placeholderLocation.coordinate.coordinate
			)!,
			timeZone: .autoupdatingCurrent
		)
	}
}
