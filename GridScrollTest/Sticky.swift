//
//  Sticky.swift
//  GridScrollTest
//
//  Created by Christian Vinterly on 03/01/2024.
//

import Foundation
import SwiftUI

struct Sticky<P: PreferenceKey>: ViewModifier where P.Value == [Namespace.ID: CGRect] {
    enum Axis {
        case horizontal
        case vertical
    }
    let axis: Axis
    var stickyRects: [Namespace.ID: CGRect]

    let coordinateSpace: String
    let key: P.Type

    @Binding var stickyOffset: CGFloat
    @State private var frame: CGRect = .zero
    @Namespace private var id

    var isSticking: Bool {
        switch axis {
        case .horizontal: return frame.minX < stickyOffset
        case .vertical: return frame.minY < stickyOffset
        }
    }

    var offsetX: CGFloat {
        guard isSticking else { return 0 }

        var offset = -frame.minX + stickyOffset
        if let other = stickyRects.first(where: { (key, value) in
            key != id && value.minX > frame.minX && value.minX < (frame.width + stickyOffset)
        }) {
            offset -= frame.width + stickyOffset - other.value.minX
        }
        return offset
    }

    var offsetY: CGFloat {
        guard isSticking else { return 0 }

        var offset = -frame.minY + stickyOffset
        if let other = stickyRects.first(where: { key, value in
            key != id && value.minY > frame.minY && value.minY < (frame.height + stickyOffset)
        }) {
            offset -= frame.height + stickyOffset - other.value.minY
        }
        return offset
    }

    func body(content: Content) -> some View {
        content
            .offset(x: axis == .horizontal ? offsetX : 0, y: axis == .vertical ? offsetY : 0)
            .zIndex(isSticking ? .infinity : 0)
            .overlay(GeometryReader { proxy in
                let newFrame = proxy.frame(in: .named(coordinateSpace))
                Color.clear
                    .onAppear { frame = newFrame }
                    .onChange(of: newFrame) { frame = $0 }
                    .preference(key: key.self, value: [id: frame])
            })
    }
}

extension View {
    func stickyVertical<P: PreferenceKey>(
        stickyRects: [Namespace.ID: CGRect],
        coordinateSpace: String,
        preferenceKey: P.Type,
        stickyYOffset: Binding<CGFloat>
    ) -> some View where P.Value == [Namespace.ID: CGRect] {
        modifier(
            Sticky(
                axis: .vertical,
                stickyRects: stickyRects,
                coordinateSpace: coordinateSpace,
                key: preferenceKey,
                stickyOffset: stickyYOffset
            )
        )
    }

    func stickyHorizontal<P: PreferenceKey>(
        stickyRects: [Namespace.ID: CGRect],
        coordinateSpace: String,
        preferenceKey: P.Type,
        stickyXOffset: Binding<CGFloat>
    ) -> some View where P.Value == [Namespace.ID: CGRect] {
        modifier(
            Sticky(
                axis: .horizontal,
                stickyRects: stickyRects,
                coordinateSpace: coordinateSpace,
                key: preferenceKey,
                stickyOffset: stickyXOffset
            )
        )
    }
}
