//
//  GlowWattLiveActivities.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 9/23/25.
//
import WidgetKit
import SwiftUI
import ActivityKit

struct GlowWattLiveActivities: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GlowWattAttributes.self) { context in
            
            // Lock screen UI
            GlowWattLockScreen(context: context)

        } dynamicIsland: { context in
            
            /// Dynamic Island UI
            GlowWattDynamicIsland(context)
        }
    }
    
    private func GlowWattDynamicIsland(_ context: ActivityViewContext<GlowWattAttributes>) -> DynamicIsland {
        DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
            }
            DynamicIslandExpandedRegion(.trailing) {
            }
            DynamicIslandExpandedRegion(.center) {
                Text("\(context.state.price, specifier: "%.2f")")
            }
            DynamicIslandExpandedRegion(.bottom) {
                Text(context.state.lastUpdated.description)
            }
        } compactLeading: {
            
        } compactTrailing: {
            
        } minimal: {
            
        }
    }
}

struct GlowWattLockScreen: View {
    
    var priceColor: Color {
        switch context.state.price {
        case ..<4:
            return .green
        case 4..<8:
            return .yellow
        default:
            return .red
        }
    }

    var context : ActivityViewContext<GlowWattAttributes>
    
    var body: some View {
        ZStack {
            priceColor.ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Current Price")
                    Text("\(context.state.price, specifier: "%.2f")¢")
                    Spacer()
                    Link(destination: URL(string: "glowwatt://stop_price_watcher")!) {
                        Image(systemName: "power")
                            .resizable()
                            .frame(width: 12, height: 12)
                    }
                    .widgetAccentable()
                }
                .padding()
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 2)
                .widgetAccentable()
                
                Sparkline(values: context.state.pastPrices)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


#Preview("Lock Screen Preview", as: .content, using: GlowWattAttributes(name: "Aryan"), widget: {
    GlowWattLiveActivities()
}, contentStates: {
    GlowWattAttributes.ContentState(lastUpdated: Date(), price: 5.2, pastPrices: [20, 2, 112, 2, 1])
})


/// A view that renders a sparkline chart, suitable for iOS Lock Screen widgets and Live Activities.
/// It automatically scales the data points to fit its width, regardless of the number of values.
struct Sparkline: View {
    /// The array of data points to render.
    let values: [Double]
    
    // MARK: - Style Constants
    private let lineWidth: CGFloat = 2.0
    private let dotSize: CGFloat = 3.0
    /// To avoid visual clutter, we only show dots if the horizontal space between points is greater than this value.
    private let dotSpacingThreshold: CGFloat = 4.0
    
    var body: some View {
        Canvas { context, size in
            // --- Edge Cases ---
            // We need at least two points to draw a meaningful line, and the min and max
            // values must be different to avoid division by zero.
            guard values.count > 1,
                  let min = values.min(),
                  let max = values.max(),
                  max > min else {
                // If conditions aren't met, draw a simple flat line in the middle.
                // This provides a stable and predictable fallback UI.
                drawFlatLine(context: &context, size: size)
                return
            }
            
            // --- Calculate Drawing Parameters ---
            // This is the key to making the chart responsive. `stepX` becomes smaller as
            // the number of values increases, ensuring the total width is always `size.width`.
            let stepX = size.width / CGFloat(values.count - 1)
            
            // This helper function converts a data value into its corresponding Y-coordinate.
            // It normalizes the value to a 0-1 range and then scales it to the view's height.
            // We subtract from `size.height` because SwiftUI's coordinate system starts at the top-left (0,0).
            func yCoordinate(for value: Double) -> CGFloat {
                let normalizedValue = (value - min) / (max - min)
                return size.height - (CGFloat(normalizedValue) * size.height)
            }
            
            // --- Create the Line Path ---
            var linePath = Path()
            linePath.move(to: CGPoint(x: 0, y: yCoordinate(for: values[0])))
            
            for (index, value) in values.enumerated().dropFirst() {
                let point = CGPoint(x: CGFloat(index) * stepX, y: yCoordinate(for: value))
                linePath.addLine(to: point)
            }
            
            // --- Draw the Line with a Gradient ---
            let gradient = Gradient(colors: [.white, .white.opacity(0.8)])
            context.stroke(
                linePath,
                with: .linearGradient(
                    gradient,
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: 0, y: size.height)
                ),
                lineWidth: lineWidth
            )
            
            // --- Conditionally Draw Dots ---
            // To prevent a cluttered look when you have many data points, we only draw the dots
            // if the space between them is greater than our threshold.
            if stepX > dotSpacingThreshold {
                for (index, value) in values.enumerated() {
                    let point = CGPoint(x: CGFloat(index) * stepX, y: yCoordinate(for: value))
                    let dotRect = CGRect(
                        x: point.x - dotSize / 2,
                        y: point.y - dotSize / 2,
                        width: dotSize,
                        height: dotSize
                    )
                    context.fill(Path(ellipseIn: dotRect), with: .color(.white))
                }
            }
        }
        // A fixed height is generally a good idea for consistency in widgets.
        .frame(height: 24)
    }
    
    /// Draws a simple horizontal line across the middle of the canvas.
    private func drawFlatLine(context: inout GraphicsContext, size: CGSize) {
        var path = Path()
        let y = size.height / 2
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: size.width, y: y))
        context.stroke(path, with: .color(.white.opacity(0.7)), lineWidth: lineWidth)
    }
}
