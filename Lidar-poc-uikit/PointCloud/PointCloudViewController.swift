//
//  PointCloudViewController.swift
//  Lidar-poc-uikit
//
//  Created by Bahadir Seyfi on 07/06/2024.
//

import UIKit
import ARKit
import Metal
import MetalKit
import CoreImage

final class PointCloudViewController: UIViewController, ARSessionDelegate {

    @IBOutlet private weak var scanButtonUI: UIButton!
    @IBOutlet private weak var mtkView: MTKView!
    @IBOutlet weak var saveButtonUI: UIButton!
    
    //  MARK: - ARKIT
    private var session = ARSession()
    var alphaTexture: MTLTexture?
    
    
    // MARK: - Metal
    private let device = MTLCreateSystemDefaultDevice()!
    private var commandQueue: MTLCommandQueue!
    private var matteGenerator: ARMatteGenerator!
    
    lazy private var textureCache: CVMetalTextureCache = {
        var cache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &cache)
        return cache!
    }()
    
    private var texture: MTLTexture!
    var renderer: Renderer!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a world-tracking configuration, and
        // enable the scene depth frame-semantic.
        let configuration = ARWorldTrackingConfiguration()
        configuration.frameSemantics = [.sceneDepth, .smoothedSceneDepth]
        // Run the view's session
        session.run(configuration)
        
        // The screen shouldn't dim during AR experiences.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidLoad() {
        func initMatteGenerator() {
            matteGenerator = ARMatteGenerator(device: device, matteResolution: .half)
        }
        func initMetal() {
            commandQueue = device.makeCommandQueue()
            mtkView.device = device
            mtkView.framebufferOnly = false
            mtkView.delegate = self
        }
        func buildConfigure() -> ARWorldTrackingConfiguration {
            let configuration = ARWorldTrackingConfiguration()
            
            configuration.environmentTexturing = .automatic
            if type(of: configuration).supportsFrameSemantics(.sceneDepth) {
                configuration.frameSemantics = .sceneDepth
            }
            
            return configuration
        }
        func runARSession() {
           
            session.delegate = self
        }
        func createTexture() {
            let width = mtkView.currentDrawable!.texture.width
            let height = mtkView.currentDrawable!.texture.height
            
            let colorDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: mtkView.colorPixelFormat,
                                                                     width: height, height: width, mipmapped: false)
            colorDesc.usage = MTLTextureUsage(rawValue: MTLTextureUsage.renderTarget.rawValue | MTLTextureUsage.shaderRead.rawValue)
            
        }
        
        if let view = mtkView {
            view.device = device
            view.backgroundColor = UIColor.clear
            // we need this to enable depth test
            view.depthStencilPixelFormat = .depth32Float
            view.contentScaleFactor = 1
            view.delegate = self
            // Configure the renderer to draw to the view
            renderer = Renderer(session: session,
                                metalDevice: device,
                                renderDestination: view)
            renderer.drawRectResized(size: view.bounds.size)
        }
        
        super.viewDidLoad()
        initMatteGenerator()
        initMetal()
        createTexture()
    }
    
    // MARK: - IBACTION's
    
    @IBAction
    private func exportButtonAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Storyboard adını gerektiği gibi değiştirin
        if let exportController = storyboard.instantiateViewController(withIdentifier: "ExportViewController") as? ExportViewController {
            exportController.mainController = self
            present(exportController, animated: true, completion: nil)
        }
    }
    
    @IBAction func scanButtonAction(_ sender: UIButton) {
        renderer.isInViewSceneMode = !renderer.isInViewSceneMode
        if !renderer.isInViewSceneMode {
            renderer.showParticles = true
            self.setShowSceneButtonStyle(isScanning: true)
        } else {
            self.setShowSceneButtonStyle(isScanning: false)
        }
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        
        let fileName = "scanMarxact"
        /*
        let format = "Ascii"
            .lowercased(with: .none)
            .split(separator: " ")
            .joined(separator: "_")
        
        
        renderer.saveAsPlyFile(fileName: fileName,
                               beforeGlobalThread: [startSaving],
                               afterGlobalThread: [endSaving],
                               errorCallback: onSaveError,
                               format: format)
        */
        renderer.saveAsObjFile(fileName: fileName,
                               beforeGlobalThread: [startSaving],
                               afterGlobalThread: [endSaving],
                               errorCallback: onSaveError)
    }
    
    private func startSaving() {
        print("Saving start")
    }
    
    private func endSaving() {
        print("EndSaving")
    }
    
    func onSaveError(error: XError) {
        
    }
}

extension PointCloudViewController {
    private func setShowSceneButtonStyle(isScanning: Bool) -> Void {
        if isScanning {
            scanButtonUI.setTitle("stop scan", for: .normal)
            saveButtonUI.isHidden = true
        } else {
            scanButtonUI.setTitle("scan", for: .normal)
            saveButtonUI.isHidden = false
        }
    }
    
    func export(url: URL) -> Void {
        present(
            UIActivityViewController(
                activityItems: [url as Any],
                applicationActivities: .none),
            animated: true)
    }
}

extension PointCloudViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.drawRectResized(size: size)
    }
    
    // Called whenever the view needs to render
    func draw(in view: MTKView) {
        renderer.draw()
    }
}
