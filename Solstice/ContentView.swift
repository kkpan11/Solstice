//
//  ContentView.swift
//  Solstice
//
//  Created by Daniel Eden on 29/09/2022.
//

import SwiftUI
import CoreData
import Solar

struct ContentView: View {
	@AppStorage(Preferences.listViewSortDimension) private var itemSortDimension
	@AppStorage(Preferences.listViewSortOrder) private var itemSortOrder
	@AppStorage(Preferences.listViewShowComplication) private var showComplication
	@Environment(\.openWindow) private var openWindow
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	
	@SceneStorage("selectedLocation") private var selectedLocation: String?
	
	@Environment(\.scenePhase) private var scenePhase
	@EnvironmentObject var currentLocation: CurrentLocation
	
	@StateObject var timeMachine = TimeMachine()
	@StateObject var locationSearchService = LocationSearchService()
	
	@State private var settingsViewOpen = false
	@State private var sidebarVisibility = NavigationSplitViewVisibility.doubleColumn
	
	@FetchRequest(sortDescriptors: []) private var items: FetchedResults<SavedLocation>
			
	var body: some View {
			NavigationSplitView(columnVisibility: $sidebarVisibility) {
				SidebarListView()
					.toolbar {
						toolbarItems
					}
				#if os(macOS)
					.navigationSplitViewColumnWidth(256)
				#endif
			} detail: {
				Group {
					switch selectedLocation {
					case currentLocation.id:
						DetailView(location: currentLocation)
					case .some(let id):
						if let item = items.first(where: { $0.uuid?.uuidString == id }) {
							DetailView(location: item)
						} else {
							placeholderView
						}
					case .none:
						placeholderView
					}
				}
			}
			.navigationSplitViewStyle(.balanced)
			.sheet(item: $locationSearchService.location) { value in
					NavigationStack {
						DetailView(location: value)
					}
					#if os(macOS)
					.frame(minWidth: 600, minHeight: 400)
					#endif
					.timeMachineOverlay()
			}
			.environmentObject(locationSearchService)
			.timeMachineOverlay()
			.environmentObject(timeMachine)
			.onContinueUserActivity(DetailView<SavedLocation>.userActivity) { userActivity in
				if let selection = userActivity.targetContentIdentifier {
					selectedLocation = selection
				}
			}
			.onContinueUserActivity(DetailView<CurrentLocation>.userActivity) { userActivity in
				if userActivity.targetContentIdentifier == currentLocation.id {
					selectedLocation = currentLocation.id
				}
			}
			.resolveDeepLink(Array(items))
			.overlay {
				TimelineView(.everyMinute) { timelineContext in
					Color.clear.task(id: timelineContext.date) {
						timeMachine.referenceDate = timelineContext.date
					}
				}
			}
		#if os(iOS)
			.sheet(isPresented: $settingsViewOpen) {
				SettingsView()
			}
		#endif
	}
	
	private var placeholderView: some View {
		Image(.solstice)
			.resizable()
			.foregroundStyle(.quaternary)
			.frame(width: 100, height: 100)
			.aspectRatio(contentMode: .fit)
	}
	
	@ToolbarContentBuilder
	private var toolbarItems: some ToolbarContent {
		ToolbarItem {
			Menu {
				Menu {
					Picker(selection: $itemSortDimension.animation()) {
						Text("Timezone")
							.tag(Preferences.SortingFunction.timezone)
						
						Text("Daylight duration")
							.tag(Preferences.SortingFunction.daylightDuration)
					} label: {
						Text("Sort by")
					}
					
					Picker(selection: $itemSortOrder.animation()) {
						Text("Ascending")
							.tag(SortOrder.forward)
						
						Text("Descending")
							.tag(SortOrder.reverse)
					} label: {
						Text("Order")
					}
				} label: {
					Label("Sort locations", systemImage: "arrow.up.arrow.down.circle")
				}
				
				Toggle(isOn: $showComplication.animation()) {
					Text("Show chart in list")
				}
			} label: {
				Label("View options", systemImage: "eye.circle")
			}
		}
		
#if os(visionOS)
		ToolbarItem {
			Button {
				openWindow(id: "settings")
			} label: {
				Label("Settings", systemImage: "gearshape")
			}
		}
#elseif !os(macOS)
		ToolbarItem {
			Button {
				settingsViewOpen = true
			} label: {
				Label("Settings", systemImage: "gearshape")
			}
		}
#endif
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
			.environmentObject(TimeMachine.preview)
			.environmentObject(CurrentLocation())
	}
}
