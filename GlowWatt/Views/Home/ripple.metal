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
half4 wave(float2 position, SwiftUI::Layer layer, float start) {
    float amp = 8.0;
    float freq = 0.06;
    float speed = 4.0;
    float dx = sin(position.y * freq + start * speed) * amp;
    return layer.sample(position + float2(dx, 0.0));
}


//[[ stitchable ]]
//float2 wave(float2 pos, float start)
//{
////    pos.y += sin(start + pos.y);
////    return pos;
//
//    // return OFFSET, not position
//    float amp = 8.0;                // pixels
//    float dy  = sin(start) * amp;   // tiny vertical offset
//    return float2(0.0, dy);
//}
