//
//  StickyLocked.swift
//  GridScrollTest
//
//  Created by Christian Vinterly on 15/01/2024.
//

import Foundation
import SwiftUI

struct LockedInScrollView: ViewModifier {
    enum Axis {
        case horizontal
        case vertical
    }
    let axis: Axis
    let coordinateSpace: String
    let safeAreaInsets: EdgeInsets

    @Binding var lockedOffset: CGFloat
    @State private var frame: CGRect = .zero

    var isLocked: Bool {
        switch axis {
        case .horizontal: return frame.minX != lockedOffset + safeAreaInsets.leading
        case .vertical: return frame.minY != lockedOffset + safeAreaInsets.top
        }
    }

    var offset: CGFloat {
        guard isLocked else { return lockedOffset }
        switch axis {
        case .horizontal: return -frame.minX + lockedOffset + safeAreaInsets.leading
        case .vertical: return -frame.minY + lockedOffset + safeAreaInsets.top
        }
    }

    func body(content: Content) -> some View {
        content
            .offset(x: axis == .horizontal ? offset : 0, y: axis == .vertical ? offset : 0)
            .zIndex(isLocked ? .infinity : 0)
            .overlay(GeometryReader { proxy in
                let newFrame = proxy.frame(in: .named(coordinateSpace))
                Color.clear
                    .onAppear { frame = newFrame }
                    .onChange(of: newFrame) { frame = $0 }
            })
    }
}

extension View {
    func lockedInScrollView(
        axis: LockedInScrollView.Axis,
        coordinateSpace: String,
        safeAreaInsets: EdgeInsets,
        lockedOffset: Binding<CGFloat>
    ) -> some View {
        modifier(
            LockedInScrollView(
                axis: axis,
                coordinateSpace: coordinateSpace,
                safeAreaInsets: safeAreaInsets,
                lockedOffset: lockedOffset
            )
        )
    }
}
