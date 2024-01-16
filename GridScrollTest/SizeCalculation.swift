//
//  SizeCalculation.swift
//  GridScrollTest
//
//  Created by Christian Vinterly on 03/01/2024.
//

import Foundation
import SwiftUI

struct SizeCalculator: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear.onAppear { size = proxy.size}
                }
            )
    }
}

struct WidthCalculator: ViewModifier {
    @Binding var width: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear.onAppear { width = proxy.size.width }
                }
            )
    }
}

struct HeightCalculator: ViewModifier {
    @Binding var height: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear.onAppear { height = proxy.size.height }
                }
            )
    }
}

extension View {
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }

    func saveWidth(in width: Binding<CGFloat>) -> some View {
        modifier(WidthCalculator(width: width))
    }

    func saveHeight(in height: Binding<CGFloat>) -> some View {
        modifier(HeightCalculator(height: height))
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
                    .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                        onChange(geometryProxy.size)
                    }
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
