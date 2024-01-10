//
//  DragState.swift
//  GridScrollTest
//
//  Created by Christian Vinterly on 08/01/2024.
//

import Foundation

enum DragState {
   case inactive
   case pressing
   case dragging(location: CGPoint)

   var location: CGPoint {
       switch self {
       case .inactive, .pressing: return .zero
       case .dragging(let location): return location
       }
   }

   var isDragging: Bool {
       switch self {
       case .dragging: return true
       case .pressing, .inactive: return false
       }
   }

   var isPressing: Bool {
       switch self {
       case .inactive: return false
       case .pressing, .dragging: return true
       }
   }
}
