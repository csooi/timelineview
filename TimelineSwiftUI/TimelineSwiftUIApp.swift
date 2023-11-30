//
//  TimelineSwiftUIApp.swift
//  TimelineSwiftUI
//
//  Created by Chien Shing Ooi on 23/11/2023.
//

import SwiftUI

@main
struct TimelineSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            TimelineView(viewModel: TimelineViewModel())
        }
    }
}
