//
//  ClockWeatherWidgetBundle.swift
//  ClockWeatherWidget
//
//  Created by Mark Mayne on 6/16/25.
//

import WidgetKit
import SwiftUI

@main
struct ClockWeatherWidgetBundle: WidgetBundle {
    var body: some Widget {
        ClockWeatherWidget()
        ClockWeatherWidgetControl()
        ClockWeatherWidgetLiveActivity()
    }
}
