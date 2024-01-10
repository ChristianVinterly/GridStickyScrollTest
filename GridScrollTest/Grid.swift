//
//  Grid.swift
//  GridScrollTest
//
//  Created by Christian Vinterly on 03/01/2024.
//

import Foundation
import SwiftUI

struct Grid: View {
    let rows: CGFloat
    let columns: CGFloat
    let size: CGFloat
    let gridColor: Color

    @GestureState private var dragState = DragState.inactive
    @State var selectedColumn: Int?

    var body: some View {
        let width = columns * size
        let height = rows * size

        ZStack {
            GridShape(
                rows: rows,
                columns: columns,
                size: size
            )
            .inset(by: 1)
            .stroke(lineWidth: 0.5)
            .stroke(gridColor)
            .frame(width: width, height: height)

            if let selectedColumn = selectedColumn {
                GridSelectedColumnShape(
                    rows: rows,
                    columns: columns,
                    size: size,
                    selectedColumn: selectedColumn
                )
                .inset(by: 1)
                .fill(Color.blue.opacity(0.3))
                .frame(width: width, height: height)
            }
        }

        .background(Color.white)
        .onTapGesture {}
        .gesture(
            LongPressGesture(minimumDuration: 0.2, maximumDistance: 0)
                .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
                .updating($dragState, body: { value, dragState, transaction in
                    switch value {
                    case .first:
                        dragState = .pressing
                        print("Pressing")
                    case .second(true, let drag):
                        guard let location = drag?.location else {
                            DispatchQueue.main.async {
                                selectedColumn = nil
                            }
                            return
                        }
                        dragState = .dragging(location: location)
                        print("Dragging: \(location)")

                        let width = (columns * size) - 1

                        let column = Int(min(max(location.x, 0), width) / size)
                        DispatchQueue.main.async {
                            selectedColumn = column
                        }
                    default:
                        break
                    }
                })
        )
    }
}

struct GridShape: InsettableShape {
    let rows: CGFloat
    let columns: CGFloat
    let size: CGFloat
    var insetAmount = 0.0

    func inset(by amount: CGFloat) -> some InsettableShape {
        var grid = self
        grid.insetAmount += amount
        return grid
    }

    func path(in rect: CGRect) -> Path {
        let width = (columns * size) - (insetAmount * 2)
        let height = (rows * size) - (insetAmount * 2)
        let xSpacing = width / columns
        let ySpacing = height / rows
        
        var path = Path()

        for index in 0...Int(columns) {
            let vOffset: CGFloat = CGFloat(index) * xSpacing + insetAmount
            path.move(to: CGPoint(x: vOffset, y: insetAmount))
            path.addLine(to: CGPoint(x: vOffset, y: height))
        }
        for index in 0...Int(rows) {
            let hOffset: CGFloat = CGFloat(index) * ySpacing + insetAmount
            path.move(to: CGPoint(x: insetAmount, y: hOffset))
            path.addLine(to: CGPoint(x: width, y: hOffset))
        }

        return path
    }
}

struct GridSelectedColumnShape: InsettableShape {
    let rows: CGFloat
    let columns: CGFloat
    let size: CGFloat
    let selectedColumn: Int
    var insetAmount = 0.0

    func inset(by amount: CGFloat) -> some InsettableShape {
        var grid = self
        grid.insetAmount += amount
        return grid
    }

    func path(in rect: CGRect) -> Path {
        let width = (columns * size) - (insetAmount * 2)
        let height = (rows * size) - (insetAmount * 2)
        let xSpacing = width / columns

        var path = Path()

        let startX: CGFloat = CGFloat(selectedColumn) * xSpacing + insetAmount
        let endX: CGFloat = CGFloat(selectedColumn + 1) * xSpacing + insetAmount
        path.move(to: CGPoint(x: startX, y: insetAmount))
        path.addLine(to: CGPoint(x: startX, y: height))
        path.addLine(to: CGPoint(x: endX, y: height))
        path.addLine(to: CGPoint(x: endX, y: insetAmount))
        path.closeSubpath()

        print("Path: \(path)")

        return path
    }
}
