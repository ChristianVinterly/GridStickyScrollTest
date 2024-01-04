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

    var body: some View {
        let width = columns * size
        let height = rows * size

        LazyVGrid(columns: /*@START_MENU_TOKEN@*/[GridItem(.fixed(20))]/*@END_MENU_TOKEN@*/, pinnedViews: PinnedScrollableViews content: {
            /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
            /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
        })

        GridShape(
            rows: rows,
            columns: columns,
            size: size
        )
        .inset(by: 1)
        .stroke(lineWidth: 0.5)
        .stroke(gridColor)
        .frame(width: width, height: height)
        .background(Color.white)
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
