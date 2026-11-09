//
//  WallectWidgetLiveActivity.swift
//  WallectWidget
//
//  Created by IWAN HARLI on 06/04/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WallectWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct WallectWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WallectWidgetAttributes.self) { context in
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

extension WallectWidgetAttributes {
    fileprivate static var preview: WallectWidgetAttributes {
        WallectWidgetAttributes(name: "World")
    }
}

extension WallectWidgetAttributes.ContentState {
    fileprivate static var smiley: WallectWidgetAttributes.ContentState {
        WallectWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: WallectWidgetAttributes.ContentState {
         WallectWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: WallectWidgetAttributes.preview) {
   WallectWidgetLiveActivity()
} contentStates: {
    WallectWidgetAttributes.ContentState.smiley
    WallectWidgetAttributes.ContentState.starEyes
}
