//
//  GridScrollTestApp.swift
//  GridScrollTest
//
//  Created by Christian Vinterly on 02/01/2024.
//

import SwiftUI

@main
struct GridScrollTestApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.white.ignoresSafeArea()

                ContentView()
                    .background(Color.white)
                    .colorScheme(.light)
            }
        }
    }
}
