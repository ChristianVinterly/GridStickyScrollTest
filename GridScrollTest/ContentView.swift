//
//  ContentView.swift
//  GridScrollTest
//
//  Created by Christian Vinterly on 02/01/2024.
//

import SwiftUI

struct ContentView: View {
    let outerScrollViewCoordinateSpace = "outerScrollViewCoordinateSpace"
    let horizontalHeaderScrollViewCoordinateSpace = "horizontalHeaderScrollViewCoordinateSpace"
    let firstHorizontalScrollViewCoordinateSpace = "firstHorizontalScrollViewCoordinateSpace"
    let secondHorizontalScrollViewCoordinateSpace = "secondHorizontalScrollViewCoordinateSpace"

    @State private var stickyTopHorizontalFrames: [Namespace.ID: CGRect] = [:]

    @State private var verticalHeaderWidth: CGFloat = 0
    @State private var horizontalHeaderHeight: CGFloat = 0

    @State private var scrollOffset = CGPoint.zero

    @State var horizontalScrollViewsTracking: [Namespace.ID: Bool?] = [:]

    private let padding: CGFloat = 8
    private let gridWidth: CGFloat = 3000
    private let gridHeight: CGFloat = 300
    private let gridSquareSize: CGFloat = 50

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: padding) {
                    horizontalHeaders

                    VStack(alignment: .leading, spacing: padding) {
                        horizontalScrollGrid(coordinateSpace: firstHorizontalScrollViewCoordinateSpace)
                        horizontalScrollGrid(coordinateSpace: secondHorizontalScrollViewCoordinateSpace)
                    }
                }
                topLeftCornerOverlay
                    .lockedInScrollView(
                        axis: .vertical,
                        coordinateSpace: outerScrollViewCoordinateSpace,
                        lockedOffset: .constant(0)
                    )
            }
        }
        .coordinateSpace(name: outerScrollViewCoordinateSpace)
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
    }

    @ViewBuilder var horizontalHeaders: some View {
        ScrollableView(
            $scrollOffset,
            scrollViewsTracking: $horizontalScrollViewsTracking,
            animationDuration: 0,
            showsScrollIndicator: false,
            axis: .horizontal
        ) {
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
                            stickyXOffset: $verticalHeaderWidth
                        )
                }
            }
            .frame(width: gridWidth, alignment: .leading)
            .padding(.bottom, padding)
            .background(Color.white)
            .saveHeight(in: $horizontalHeaderHeight)
            .padding(.leading, verticalHeaderWidth)
        }
        .frame(height: horizontalHeaderHeight)
        .coordinateSpace(name: horizontalHeaderScrollViewCoordinateSpace)
        .useStickyHeaders(
            stickyRects: $stickyTopHorizontalFrames,
            preferenceKey: TopMenuHorizontalFramePreference.self
        )
        .lockedInScrollView(
            axis: .vertical,
            coordinateSpace: outerScrollViewCoordinateSpace,
            lockedOffset: .constant(0)
        )
    }

    @ViewBuilder func horizontalScrollGrid(coordinateSpace: String) -> some View {
        ScrollableView(
            $scrollOffset,
            scrollViewsTracking: $horizontalScrollViewsTracking,
            animationDuration: 0,
            showsScrollIndicator: false,
            axis: .horizontal
        ) {
            HStack(alignment: .top, spacing: 0) {
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
                .lockedInScrollView(
                    axis: .horizontal,
                    coordinateSpace: coordinateSpace,
                    lockedOffset: .constant(0)
                )
                .saveWidth(in: $verticalHeaderWidth)

                Grid(
                    rows: gridHeight / gridSquareSize,
                    columns: gridWidth / gridSquareSize,
                    size: gridSquareSize,
                    gridColor: .blue
                )
            }
        }
        .coordinateSpace(name: coordinateSpace)
        .frame(height: gridHeight)
    }

    @ViewBuilder var topLeftCornerOverlay: some View {
        Rectangle()
            .foregroundColor(.white)
            .frame(width: verticalHeaderWidth, height: horizontalHeaderHeight)
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
