import MetalUI
import MetalKit

class BasicMetalView: MTKView, MetalPresenting {
  var renderer: MetalRendering!
  
  required init() {
    super.init(frame: .zero, device: MTLCreateSystemDefaultDevice())
    configure(device: device)
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configureMTKView() {
    colorPixelFormat = .bgra8Unorm
    // Our clear color, can be set to any color
    clearColor = MTLClearColor(red: 1, green: 0.57, blue: 0.25, alpha: 1)
  }
  
  func renderer(forDevice device: MTLDevice) -> MetalRendering {
    BasicMetalRenderer(vertices: [
      MetalRenderingVertex(position: SIMD3(0,1,0), color: SIMD4(1,0,0,1)),
      MetalRenderingVertex(position: SIMD3(-1,-1,0), color: SIMD4(0,1,0,1)),
      MetalRenderingVertex(position: SIMD3(1,-1,0), color: SIMD4(0,0,1,1))
    ], device: device)
  }
}
