//  Created by Filip Kjamilov on 30.10.22.

import SwiftUI

struct ScratchView<ContentView: View, OverlayView: View>: View {
    
    var content: ContentView
    var overlayView: OverlayView
    
    init(onFinish: Binding<Bool>, @ViewBuilder content: @escaping ()->ContentView, @ViewBuilder overlayView: @escaping ()->OverlayView) {
        self.content = content()
        self.overlayView = overlayView()
        self._onFinish = onFinish
    }
    
    @State var startingPoint: CGPoint = .zero
    @State var points: [CGPoint] = []
    
    @GestureState var gestureLocation: CGPoint = .zero
    
    @Binding var onFinish: Bool
    
    var body: some View {
        ZStack {
            overlayView
                .opacity(onFinish ? 0 : 1)
            content
                .mask(
                    ZStack {
                        if !onFinish {
                            ScratchMask(points: points, startingPoint: startingPoint)
                                .stroke(style: StrokeStyle(lineWidth: 50, lineCap: .round, lineJoin: .round))
                        } else {
                            Rectangle()
                        }
                    }
                )
                .animation(.easeInOut, value: onFinish)
                .gesture(
                    DragGesture()
                        .updating($gestureLocation, body: { value, out, _ in
                            out = value.location
                            DispatchQueue.main.async {
                                if startingPoint == .zero {
                                    startingPoint = value.location
                                }
                                
                                points.append(value.location)
                            }
                        })
                        .onEnded({ _ in
                            withAnimation {
                                onFinish = true
                            }
                        })
                )
        }
        .frame(width: 250, height: 150)
        .cornerRadius(20)
        .onChange(of: onFinish) { _ in
            if !onFinish && !points.isEmpty {
                withAnimation(.easeInOut) {
                    resetView()
                }
            }
        }
    }
    
    func resetView() {
        points.removeAll()
        startingPoint = .zero
    }
}

struct ScratchMask: Shape {
    
    var points: [CGPoint]
    var startingPoint: CGPoint
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: startingPoint)
            path.addLines(points)
        }
    }
}
