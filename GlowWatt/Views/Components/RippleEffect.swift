//
//  RippleEffect.swift
//  Shaders
//
//  Created by Aryan Rogye on 10/6/25.
//

import SwiftUI

struct RippleModifier: ViewModifier {
    var origin : CGPoint
    var elapsedTime : TimeInterval
    
    var amplitude: Double
    var frequency: Double
    var decay: Double
    var speed: Double
    
    nonisolated init(
        origin: CGPoint,
        elapsedTime: TimeInterval,
        amplitude: Double,
        frequency: Double,
        decay: Double,
        speed: Double
    ) {
        self.origin = origin
        self.elapsedTime = elapsedTime
        self.amplitude = amplitude
        self.frequency = frequency
        self.decay = decay
        self.speed = speed
    }
    
    func body(content: Content) -> some View {
        content
            .layerEffect(
                ShaderLibrary.ripple(
                    .float2(origin),
                    .float(elapsedTime),
                    .float(amplitude),
                    .float(frequency),
                    .float(decay),
                    .float(speed)
                ),
                maxSampleOffset: .zero
            )
    }
}

@MainActor
struct RippleEffect<T: Equatable>: ViewModifier {
    
    var shouldActivate: Bool
    var trigger : T
    var origin  : CGPoint
    var duration: TimeInterval = 0.6
    var amplitude: Double = 20
    var frequency: Double = 20
    var decay: Double = 8
    var speed: Double = 1200
    
    func body(content: Content) -> some View {
        content
            .keyframeAnimator(initialValue: 0.0, trigger: trigger) {
                [origin] view, elepasedTime in
                view.modifier(
                    RippleModifier(
                        origin : origin,
                        elapsedTime: elepasedTime,
                        amplitude: amplitude,
                        frequency: frequency,
                        decay: decay,
                        speed: speed
                    )
                )
            } keyframes: { _ in
                MoveKeyframe(0)
                LinearKeyframe(duration, duration: duration)
            }
    }
}

