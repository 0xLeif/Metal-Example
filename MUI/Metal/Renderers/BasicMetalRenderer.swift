import MetalUI
import MetalKit

struct Vertex {
  var position: SIMD3<Float>
  var color: SIMD4<Float>
}

struct ModelConstraints {
  var modelMatrix = matrix_identity_float4x4
}

final class BasicMetalRenderer: NSObject, MetalRendering {
  var commandQueue: MTLCommandQueue?
  var renderPipelineState: MTLRenderPipelineState?
  var vertexBuffer: MTLBuffer?
  
  var vertices: [MetalRenderingVertex] = []
  
  var modelConstraints = ModelConstraints()
  
  func createCommandQueue(device: MTLDevice) {
    commandQueue = device.makeCommandQueue()
  }
  
  func createPipelineState(
    withLibrary library: MTLLibrary?,
    forDevice device: MTLDevice
  ) {
    // Our vertex function name
    let vertexFunction = library?.makeFunction(name: "basic_vertex_function")
    // Our fragment function name
    let fragmentFunction = library?.makeFunction(name: "basic_fragment_function")
    // Create basic descriptor
    let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
    // Attach the pixel format that si the same as the MetalView
    renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    // Attach the shader functions
    renderPipelineDescriptor.vertexFunction = vertexFunction
    renderPipelineDescriptor.fragmentFunction = fragmentFunction
    
    // Create the VertexDescriptor
    let vertexDescriptor = MTLVertexDescriptor()
    vertexDescriptor.attributes[0].bufferIndex = 0
    vertexDescriptor.attributes[0].format = .float3
    vertexDescriptor.attributes[0].offset = 0
    
    vertexDescriptor.attributes[1].bufferIndex = 0
    vertexDescriptor.attributes[1].format = .float4
    vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD4<Float>>.size
    
    vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
    
    // Create the PipelineState
    renderPipelineDescriptor.vertexDescriptor = vertexDescriptor
    
    // Try to update the state of the renderPipeline
    do {
      renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func createBuffers(device: MTLDevice) {
    vertexBuffer = device.makeBuffer(bytes: vertices,
                                     length: MemoryLayout<MetalRenderingVertex>.stride * vertices.count,
                                     options: [])
  }
  
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    
  }
  
  var color: Float = 0
  func draw(in view: MTKView) {
    // Get the current drawable and descriptor
    guard let drawable = view.currentDrawable,
          let renderPassDescriptor = view.currentRenderPassDescriptor,
          let commandQueue = commandQueue,
          let renderPipelineState = renderPipelineState else {
            return
          }
    
    let deltaTime = 1 / Float(view.preferredFramesPerSecond)
    rotate(angle: deltaTime, axis: SIMD3<Float>(0,0,1))
    
    // Create a buffer from the commandQueue
    let commandBuffer = commandQueue.makeCommandBuffer()
    let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
    commandEncoder?.setRenderPipelineState(renderPipelineState)
    // Pass in the vertexBuffer into index 0
    commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    
    
    commandEncoder?.setVertexBytes(&modelConstraints, length: MemoryLayout<ModelConstraints>.stride, index: 1)
    
    // Draw primitive at vertextStart 0
    commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    
    commandEncoder?.endEncoding()
    commandBuffer?.present(drawable)
    commandBuffer?.commit()
  }
  
  func rotate(angle: Float, axis: SIMD3<Float>) {
    modelConstraints.modelMatrix.rotate(angle: angle, axis: axis)
  }
}
