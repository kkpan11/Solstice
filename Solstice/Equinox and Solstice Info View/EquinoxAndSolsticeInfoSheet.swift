//
//  InformationSheetView.swift
//  Solstice
//
//  Created by Daniel Eden on 22/03/2023.
//

import SwiftUI

struct EquinoxAndSolsticeInfoSheet: View {
	var body: some View {
		GeometryReader { geometry in
			Form {
				Section {
					EarthSceneKitView(height: min(geometry.size.width, 400))
				}
				
				Section {
					EquinoxAndSolsticeDescriptions()
				} footer: {
					Text("Imagery Source: [NASA Visible Earth Catalog](https://visibleearth.nasa.gov/collection/1484/blue-marble)")
				}
			}
			.formStyle(.grouped)
			.navigationTitle("Equinox and Solstice")
		}
	}
}

struct InformationSheetView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationStack {
			EquinoxAndSolsticeInfoSheet()
		}
	}
}
