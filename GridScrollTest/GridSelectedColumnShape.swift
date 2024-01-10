//
//  GridSelectedColumnShape.swift
//  GridScrollTest
//
//  Created by Christian Vinterly on 10/01/2024.
//

import Foundation
import SwiftUI

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

        return path
    }
}
