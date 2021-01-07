//
//  SundialView.swift
//  Solstice
//
//  Created by Daniel Eden on 06/01/2021.
//

import SwiftUI

struct SundialView: View {
  var waveSize = 75.0
  var circleSize: CGFloat = 36.0
  var currentPosition: Double
  var offset = 0.0
  var sunColor = Color.systemYellow
  
  var wave: some View {
    Wave(amplitude: waveSize, frequency: .pi * 2, phase: .pi / 2)
      .trim(from: 0.25, to: 0.75)
      .stroke(Color.opaqueSeparator, lineWidth: 3)
      .offset(y: -1.5)
  }
  
  var sunsetWave1: some View {
    Wave(amplitude: waveSize, frequency: .pi * 2, phase: .pi / 2)
      .trim(from: 0, to: 0.25)
      .stroke(Color.opaqueSeparator.opacity(0.5), lineWidth: 3)
      .offset(y: -1.5)
  }
  
  var sunsetWave2: some View {
    Wave(amplitude: waveSize, frequency: .pi * 2, phase: .pi / 2)
      .trim(from: 0.75, to: 1)
      .stroke(Color.opaqueSeparator.opacity(0.5), lineWidth: 3)
      .offset(y: -1.5)
  }
  
  var body: some View {
    ZStack {
      GeometryReader { geometry in
        ZStack {
          wave
          
          Rectangle()
            .fill(Color.opaqueSeparator)
            .frame(height: 1)
            .offset(y: -1)
          
          Circle()
            .fill(sunColor)
            .frame(width: circleSize)
            .position(x: -circleSize / 2, y: geometry.size.height / 2)
            .offset(
              x: geometry.size.width * CGFloat(currentPosition),
              y: CGFloat(sin((currentPosition - .pi / 4) * .pi * 2) * waveSize))
            .shadow(color: sunColor.opacity(0.6), radius: 10, x: 0.0, y: 0.0)
          
          sunsetWave1
          sunsetWave2
        }.offset(y: CGFloat(offset * waveSize))
      }
    }
  }
}

struct SundialView_Previews: PreviewProvider {
    static var previews: some View {
      SundialView(currentPosition: 0.75)
    }
}
