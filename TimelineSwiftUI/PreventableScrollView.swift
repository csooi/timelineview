//
//  PreventableScrollView.swift
//  TimelineSwiftUI
//
//  Created by Sean Philips on 02/10/2024.
//

import Foundation
import SwiftUI

struct PreventableScrollView<Content>: View where Content: View {
    @Binding var canScroll: Bool
    var content: () -> Content
    
    var body: some View {
        if canScroll {
            ScrollView(.vertical, showsIndicators: false, content: content)
        } else {
            content()
        }
    }
}
