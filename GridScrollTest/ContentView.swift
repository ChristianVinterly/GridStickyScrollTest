//
//  ContentView.swift
//  GridScrollTest
//
//  Created by Christian Vinterly on 02/01/2024.
//

import SwiftUI

struct ContentView: View {
    let horizontalHeaderScrollViewCoordinateSpace = "horizontalHeaderScrollViewCoordinateSpace"
    let firstScrollViewCoordinateSpace = "firstScrollViewCoordinateSpace"
    let secondScrollViewCoordinateSpace = "secondScrollViewCoordinateSpace"

    @State private var stickyTopHorizontalFrames: [Namespace.ID: CGRect] = [:]
    @State private var stickyTopVerticalFrames: [Namespace.ID: CGRect] = [:]

    @State private var stickyLeftHorizontalFrames: [Namespace.ID: CGRect] = [:]

    @State private var stickyTopXOffset: CGFloat = 0
    @State private var stickyLeftYOffset: CGFloat = 0

    @State private var scrollOffset = CGPoint.zero
    @State private var verticalScrollOffset = CGPoint.zero

    private let padding: CGFloat = 8
    private let gridWidth: CGFloat = 3000
    private let gridHeight: CGFloat = 200
    private let gridSquareSize: CGFloat = 50
    private let headerHeight: CGFloat = 24

    var body: some View {
        ScrollView([.vertical], showsIndicators: true) {
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: padding) {
                    ScrollableView($scrollOffset, animationDuration: 0, axis: .horizontal) {
                        horizontalHeaders
                            .frame(height: headerHeight)
                            .padding(.leading, stickyTopXOffset)
                    }
                    .frame(height: stickyLeftYOffset)
                    .coordinateSpace(name: horizontalHeaderScrollViewCoordinateSpace)
                    .useStickyHeaders(
                        stickyRects: $stickyTopHorizontalFrames,
                        preferenceKey: TopMenuHorizontalFramePreference.self
                    )
                    .useStickyHeaders(
                        stickyRects: $stickyTopVerticalFrames,
                        preferenceKey: TopMenuVerticalFramePreference.self
                    )

                    VStack(alignment: .leading, spacing: padding) {
                        ScrollableView($scrollOffset, animationDuration: 0, axis: .horizontal) {
                            HStack(alignment: .top, spacing: 0) {
                                verticalHeaders(coordinateSpace: firstScrollViewCoordinateSpace)
                                Grid(
                                    rows: gridHeight / gridSquareSize,
                                    columns: gridWidth / gridSquareSize,
                                    size: gridSquareSize,
                                    gridColor: .blue
                                )
                            }
                        }
                        .coordinateSpace(name: firstScrollViewCoordinateSpace)
                        .useStickyHeaders(
                            stickyRects: $stickyLeftHorizontalFrames,
                            preferenceKey: LeftMenuHorizontalFramePreference.self
                        )
                        .frame(height: gridHeight)

                        ScrollableView($scrollOffset, animationDuration: 0, axis: .horizontal) {
                            HStack(alignment: .top, spacing: 0) {
                                verticalHeaders(coordinateSpace: secondScrollViewCoordinateSpace)
                                Grid(
                                    rows: gridHeight / gridSquareSize,
                                    columns: gridWidth / gridSquareSize,
                                    size: gridSquareSize,
                                    gridColor: .blue
                                )
                            }
                        }
                        .coordinateSpace(name: secondScrollViewCoordinateSpace)
                        .useStickyHeaders(
                            stickyRects: $stickyLeftHorizontalFrames,
                            preferenceKey: LeftMenuHorizontalFramePreference.self
                        )
                        .frame(height: gridHeight)
                    }
                }
                topLeftCornerOverlay
            }
            .background(Color.red)
        }
        .clipped()
        .background(Color.white)
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
        .fixedSize(horizontal: false, vertical: true)
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
                        coordinateSpace: horizontalHeaderScrollViewCoordinateSpace,
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
            coordinateSpace: horizontalHeaderScrollViewCoordinateSpace,
            preferenceKey: TopMenuVerticalFramePreference.self,
            stickyYOffset: .constant(0)
        )
        .saveHeight(in: $stickyLeftYOffset)
    }

    @ViewBuilder func verticalHeaders(coordinateSpace: String) -> some View {
        VStack(spacing: gridSquareSize) {
            let numberOfLabels = Int(gridHeight / (2 * gridSquareSize))
            ForEach(0..<numberOfLabels, id: \.self) { index in
                header(index: index)
                .frame(height: gridSquareSize)
                .background(Color.white)
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
