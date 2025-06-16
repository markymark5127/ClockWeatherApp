//
//  ClockWeatherWidgetLiveActivity.swift
//  ClockWeatherWidget
//
//  Created by Mark Mayne on 6/16/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ClockWeatherWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ClockWeatherWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ClockWeatherWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ClockWeatherWidgetAttributes {
    fileprivate static var preview: ClockWeatherWidgetAttributes {
        ClockWeatherWidgetAttributes(name: "World")
    }
}

extension ClockWeatherWidgetAttributes.ContentState {
    fileprivate static var smiley: ClockWeatherWidgetAttributes.ContentState {
        ClockWeatherWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ClockWeatherWidgetAttributes.ContentState {
         ClockWeatherWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ClockWeatherWidgetAttributes.preview) {
   ClockWeatherWidgetLiveActivity()
} contentStates: {
    ClockWeatherWidgetAttributes.ContentState.smiley
    ClockWeatherWidgetAttributes.ContentState.starEyes
}
