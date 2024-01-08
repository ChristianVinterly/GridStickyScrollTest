//
//  AlternativeScrollViewSolution.swift
//  GridScrollTest
//
//  Created by Christian Vinterly on 04/01/2024.
//

import Foundation
import SwiftUI

struct AlternativeContentView: View {

    let columns = 20
    let rows = 30

    @State private var offset = CGPoint.zero

    var body: some View {

        HStack(alignment: .top, spacing: 0) {

            VStack(alignment: .leading, spacing: 0) {
                // empty corner
                Color.clear.frame(width: 70, height: 50)
                ScrollView([.vertical]) {
                    rowsHeader
                        .offset(y: offset.y)
                }
                .disabled(true)
            }
            VStack(alignment: .leading, spacing: 0) {
                ScrollView([.horizontal]) {
                    colsHeader
                        .offset(x: offset.x)
                }
                .disabled(true)

                table
                    .coordinateSpace(name: "scroll")
            }
        }
        .padding()
    }

    var colsHeader: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(0..<columns, id: \.self) { col in
                Text("COL \(col)")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .frame(width: 70, height: 50)
                    .border(Color.blue)
            }
        }
    }

    var rowsHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<rows, id: \.self) { row in
                Text("ROW \(row)")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .frame(width: 70, height: 50)
                    .border(Color.blue)
            }
        }
    }

    var table: some View {
        ScrollViewReader { cellProxy in
            ScrollView([.vertical, .horizontal]) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(alignment: .top, spacing: 0) {
                            ForEach(0..<columns, id: \.self) { col in
                                // Cell
                                Text("(\(row), \(col))")
                                    .frame(width: 70, height: 50)
                                    .border(Color.blue)
                                    .id("\(row)_\(col)")
                            }
                        }
                    }
                }
                .background( GeometryReader { geo in
                    Color.clear
                        .preference(key: ViewOffsetKey.self, value: geo.frame(in: .named("scroll")).origin)
                })
                .onPreferenceChange(ViewOffsetKey.self) { value in
                    print("offset >> \(value)")
                    offset = value
                }

                // Use the following to scroll to the first cell (top leading corner of the table) when opened

                .onAppear {
                    cellProxy.scrollTo("0_0")
                }
            }
        }
    }
}


struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGPoint
    static var defaultValue = CGPoint.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.x += nextValue().x
        value.y += nextValue().y
    }
}
