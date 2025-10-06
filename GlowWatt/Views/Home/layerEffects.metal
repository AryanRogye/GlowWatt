//
//  ripple.metal
//  GlowWatt
//
//  Created by Aryan Rogye on 10/5/25.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

[[ stitchable ]]
half4 layerDistortion(
                      float2 position,
                      SwiftUI::Layer layer,
                      float2 origin,
                      float time,
                      float amplitude,
                      float frequency,
                      float decay,
                      float speed
                      ) {
    // distance from center
    float dist  = length(position - origin);
    
    // ripple delay per pixel distance
    float delay = dist / max(speed, 1e-3);
    time = max(0.0, time - delay);
    
    float ripple = amplitude * sin(frequency * time) * exp(-decay * time);
    
    float2 dir = (dist > 0.0) ? normalize(position - origin) : float2(0.0);
    float2 newPos = position + ripple * dir;
    
    half4 color = layer.sample(newPos);
    color.rgb += 0.3 * (ripple / max(amplitude, 1e-3)) * color.a; // subtle highlight
    return color;
}
