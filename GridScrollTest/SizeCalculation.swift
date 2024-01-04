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
                    Color.clear
                        .onAppear {
                            size = proxy.size
                        }
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
                    Color.clear
                        .onAppear {
                            width = proxy.size.width
                        }
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
                    Color.clear
                        .onAppear {
                            height = proxy.size.height
                        }
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

