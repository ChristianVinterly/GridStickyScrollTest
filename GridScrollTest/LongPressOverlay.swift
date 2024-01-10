//
//  LongPressOverlay.swift
//  GridScrollTest
//
//  Created by Christian Vinterly on 10/01/2024.
//

import Foundation
import SwiftUI
import UIKit

// iOS 14 does not support SwiftUI LongPressGesture with tap location info
struct LongPressOverlay: UIViewRepresentable {
    @Binding var touchLocation: CGPoint?

    func makeUIView(context: UIViewRepresentableContext<LongPressOverlay>) -> UIView {
        let view = UIView(frame: .zero)

        let longPress = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.longPressed)
        )
        longPress.minimumPressDuration = 0.25

        view.addGestureRecognizer(longPress)
        return view
    }

    class Coordinator: NSObject {
        @Binding var touchLocation: CGPoint?

        init(touchLocation: Binding<CGPoint?>) {
            self._touchLocation = touchLocation
        }

        @objc func longPressed(gesture: UILongPressGestureRecognizer) {
            let point = gesture.location(in: gesture.view)

            switch gesture.state {
            case .began, .changed, .possible:
                touchLocation = point
            case .ended, .cancelled, .failed:
                touchLocation = nil
            case .recognized: break
            @unknown default: break
            }
        }
    }

    func makeCoordinator() -> LongPressOverlay.Coordinator {
        return Coordinator(touchLocation: _touchLocation)
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LongPressOverlay>) {}
}
