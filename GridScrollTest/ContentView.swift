//
//  ContentView.swift
//  GridScrollTest
//
//  Created by Christian Vinterly on 02/01/2024.
//

import SwiftUI

struct ContentView: View {
    let coordinateSpace = "container"

    @State private var stickyTopHorizontalFrames: [Namespace.ID: CGRect] = [:]
    @State private var stickyTopVerticalFrames: [Namespace.ID: CGRect] = [:]

    @State private var stickyLeftHorizontalFrames: [Namespace.ID: CGRect] = [:]
    @State private var stickyLeftVerticalFrames: [Namespace.ID: CGRect] = [:]

    @State private var stickyCornerHorizontalFrames: [Namespace.ID: CGRect] = [:]
    @State private var stickyCornerVerticalFrames: [Namespace.ID: CGRect] = [:]

    @State private var stickyTopXOffset: CGFloat = 0
    @State private var stickyLeftYOffset: CGFloat = 0

    private let padding: CGFloat = 8
    private let gridWidth: CGFloat = 3000
    private let gridHeight: CGFloat = 2000
    private let gridSquareSize: CGFloat = 50

    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 0) {
                    horizontalHeaders
                        .padding(.leading, stickyTopXOffset)
                    HStack(alignment: .top, spacing: 0) {
                        verticalHeaders
                        Grid(
                            rows: gridHeight / gridSquareSize,
                            columns: gridWidth / gridSquareSize,
                            size: gridSquareSize,
                            gridColor: .blue
                        )
                    }
                }
                topLeftCornerOverlay
            }
        }
        .coordinateSpace(name: coordinateSpace)
        .useStickyHeaders(stickyRects: $stickyTopHorizontalFrames, preferenceKey: TopMenuHorizontalFramePreference.self)
        .useStickyHeaders(stickyRects: $stickyTopVerticalFrames, preferenceKey: TopMenuVerticalFramePreference.self)
        .useStickyHeaders(stickyRects: $stickyLeftHorizontalFrames, preferenceKey: LeftMenuHorizontalFramePreference.self)
        .useStickyHeaders(stickyRects: $stickyLeftVerticalFrames, preferenceKey: LeftMenuVerticalFramePreference.self)
        .clipped()
        .padding(8)
    }

    @ViewBuilder
    private func header(index: Int) -> some View {
        HStack(alignment: .center, spacing: 4) {
            Image(systemName: "sun.max.fill")
                .imageScale(.medium)
                .foregroundColor(.blue)
            Text("Title \(index)")
                .font(.body)
                .foregroundColor(.blue)
        }
    }

    @ViewBuilder var horizontalHeaders: some View {
        HStack(spacing: gridSquareSize) {
            let numberOfLabels = Int(gridWidth / (3 * gridSquareSize))
            ForEach(0..<numberOfLabels, id: \.self) { index in
                header(index: index)
                    .frame(width: 2 * gridSquareSize, alignment: .leading)
                    .background(Color.white)
                    .stickyHorizontal(
                        stickyRects: stickyTopHorizontalFrames,
                        coordinateSpace: coordinateSpace,
                        preferenceKey: TopMenuHorizontalFramePreference.self,
                        stickyXOffset: $stickyTopXOffset
                    )
            }
        }
        .frame(width: gridWidth, alignment: .leading)
        .padding(.bottom, padding)
        .background(Color.white)
        .stickyVertical(
            stickyRects: stickyTopVerticalFrames,
            coordinateSpace: coordinateSpace,
            preferenceKey: TopMenuVerticalFramePreference.self,
            stickyYOffset: .constant(0)
        )
        .saveHeight(in: $stickyLeftYOffset)
    }

    @ViewBuilder var verticalHeaders: some View {
        VStack(spacing: gridSquareSize) {
            let numberOfLabels = Int(gridHeight / (2 * gridSquareSize))
            ForEach(0..<numberOfLabels, id: \.self) { index in
                header(index: index)
                .frame(height: gridSquareSize)
                .background(Color.white)
                .stickyVertical(
                    stickyRects: stickyLeftVerticalFrames,
                    coordinateSpace: coordinateSpace,
                    preferenceKey: LeftMenuVerticalFramePreference.self,
                    stickyYOffset: $stickyLeftYOffset
                )
            }
        }
        .frame(height: gridHeight, alignment: .top)
        .padding(.trailing, padding)
        .background(Color.white)
        .stickyHorizontal(
            stickyRects: stickyLeftHorizontalFrames,
            coordinateSpace: coordinateSpace,
            preferenceKey: LeftMenuHorizontalFramePreference.self,
            stickyXOffset: .constant(0)
        )
        .saveWidth(in: $stickyTopXOffset)
    }

    @ViewBuilder var topLeftCornerOverlay: some View {
        Rectangle()
            .foregroundColor(.white)
            .frame(width: stickyTopXOffset, height: stickyLeftYOffset)
            .stickyHorizontal(
                stickyRects: stickyCornerHorizontalFrames,
                coordinateSpace: coordinateSpace,
                preferenceKey: CornerHorizontalFramePreference.self,
                stickyXOffset: .constant(0)
            )
            .stickyVertical(
                stickyRects: stickyCornerVerticalFrames,
                coordinateSpace: coordinateSpace,
                preferenceKey: CornerVerticalFramePreference.self,
                stickyYOffset: .constant(0)
            )
    }


}

#Preview {
    ContentView()
}

protocol StickyHeaderPreferenceKey: PreferenceKey {}
extension StickyHeaderPreferenceKey where Value == [Namespace.ID: CGRect] {
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 }
    }
}

struct TopMenuHorizontalFramePreference: StickyHeaderPreferenceKey {
    static var defaultValue: [Namespace.ID: CGRect] = [:]
}

struct TopMenuVerticalFramePreference: StickyHeaderPreferenceKey {
    static var defaultValue: [Namespace.ID: CGRect] = [:]
}

struct LeftMenuHorizontalFramePreference: StickyHeaderPreferenceKey {
    static var defaultValue: [Namespace.ID: CGRect] = [:]
}

struct LeftMenuVerticalFramePreference: StickyHeaderPreferenceKey {
    static var defaultValue: [Namespace.ID: CGRect] = [:]
}

struct CornerHorizontalFramePreference: StickyHeaderPreferenceKey {
    static var defaultValue: [Namespace.ID: CGRect] = [:]
}

struct CornerVerticalFramePreference: StickyHeaderPreferenceKey {
    static var defaultValue: [Namespace.ID: CGRect] = [:]
}

