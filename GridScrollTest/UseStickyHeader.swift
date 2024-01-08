//
//  UseStickyHeader.swift
//  GridScrollTest
//
//  Created by Christian Vinterly on 08/01/2024.
//

import Foundation
import SwiftUI

struct UseStickyHeaders<P: PreferenceKey>: ViewModifier where P.Value == [Namespace.ID: CGRect] {
    @Binding var stickyRects: [Namespace.ID: CGRect]
    let preferenceKey: P.Type

    func body(content: Content) -> some View {
        content
            .onPreferenceChange(preferenceKey.self, perform: {
                stickyRects = $0
            })
    }
}

extension View {
    func useStickyHeaders<P: PreferenceKey>(
        stickyRects: Binding<[Namespace.ID: CGRect]>,
        preferenceKey: P.Type
    ) -> some View where P.Value == [Namespace.ID: CGRect] {
        modifier(UseStickyHeaders(stickyRects: stickyRects, preferenceKey: preferenceKey))
    }
}
