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

    var activeScrollViewId: Namespace.ID? {
        return horizontalScrollViewsTracking.first(where: { $0.value == true })?.key
    }

    private let padding: CGFloat = 8
    private let gridWidth: CGFloat = 3000
    private let gridHeight: CGFloat = 300
    private let gridSquareSize: CGFloat = 50

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: padding) {
                        horizontalHeaders(safeAreaInsets: proxy.safeAreaInsets)

                        VStack(alignment: .leading, spacing: padding) {
                            horizontalScrollGrid(
                                coordinateSpace: firstHorizontalScrollViewCoordinateSpace,
                                safeAreaInsets: proxy.safeAreaInsets
                            )
                            horizontalScrollGrid(
                                coordinateSpace: secondHorizontalScrollViewCoordinateSpace,
                                safeAreaInsets: proxy.safeAreaInsets
                            )
                        }
                    }
                    topLeftCornerOverlay
                        .lockedInScrollView(
                            axis: .vertical,
                            coordinateSpace: outerScrollViewCoordinateSpace,
                            safeAreaInsets: EdgeInsets(),
                            lockedOffset: .constant(0)
                        )
                }
            }
            .coordinateSpace(name: outerScrollViewCoordinateSpace)
            .clipped()
            .background(Color.white)
        }
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

    @ViewBuilder func horizontalHeaders(safeAreaInsets: EdgeInsets) -> some View {
        ScrollableView(
            $scrollOffset,
            scrollViewsTracking: $horizontalScrollViewsTracking,
            activeScrollView: activeScrollViewId,
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
            .readSize(onChange: { size in
                horizontalHeaderHeight = size.height
            })
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
            safeAreaInsets: EdgeInsets(),
            lockedOffset: .constant(0)
        )
    }

    @ViewBuilder func horizontalScrollGrid(coordinateSpace: String, safeAreaInsets: EdgeInsets) -> some View {
        ScrollableView(
            $scrollOffset,
            scrollViewsTracking: $horizontalScrollViewsTracking,
            activeScrollView: activeScrollViewId,
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
                    safeAreaInsets: safeAreaInsets,
                    lockedOffset: .constant(0)
                )
                .readSize(onChange: { size in
                    verticalHeaderWidth = size.width
                })

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
