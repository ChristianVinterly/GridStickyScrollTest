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
    @State var touchLocation: CGPoint?
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
        .overlay(
            LongPressOverlay(touchLocation: $touchLocation)
            .frame(width: width, height: height)
        )
        .onTapGesture {}
        .onChange(of: touchLocation, perform: { value in
            updateSelectedColumn()
        })
    }

    private func updateSelectedColumn() {
        guard let touchLocation = touchLocation else {
            selectedColumn = nil
            return
        }

        let width = (columns * size) - 1

        let column = Int(min(max(touchLocation.x, 0), width) / size)
        selectedColumn = column
    }
}
