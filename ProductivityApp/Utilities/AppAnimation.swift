//
//  AppAnimation.swift
//  ProductivityApp
//
//  Created by Connor Hammond on 11/2/25.
//

import SwiftUI

enum AppAnimation {
    static let quick = Animation.easeInOut(duration: 0.15)
    static let standard = Animation.easeInOut(duration: 0.25)
    static let slow = Animation.easeInOut(duration: 0.35)
    static let springQuick = Animation.spring(response: 0.3, dampingFraction: 0.85)
    static let springStandard = Animation.spring(response: 0.4, dampingFraction: 0.85)
}
