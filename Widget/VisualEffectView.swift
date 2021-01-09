//
//  VisualEffectView.swift
//  WidgetExtension
//
//  Created by Daniel Eden on 08/01/2021.
//

import SwiftUI

struct VisualEffectView: View {
  var effect: UIVisualEffect?
  var body: some View {
    Rectangle().fill(Color.secondarySystemBackground)
  }
  
  typealias SystemMaterial = EmptyView
  typealias SystemInvertedRuleMaterial = EmptyView
}

struct VisualEffectView_Previews: PreviewProvider {
    static var previews: some View {
        VisualEffectView()
    }
}