//
//  ViewController.swift
//  Lidar-poc-uikit
//
//  Created by Bahadir Seyfi on 07/06/2024.
//

import UIKit
import Metal
import MetalKit
import ARKit

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction
    private func navigateButtonActiom(_ sender: UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : PointCloudViewController = storyboard.instantiateViewController(withIdentifier: "Main") as! PointCloudViewController

        let navigationController = UINavigationController(rootViewController: vc)

        self.present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - RenderDestinationProvider
protocol RenderDestinationProvider {
    var currentRenderPassDescriptor: MTLRenderPassDescriptor? { get }
    var currentDrawable: CAMetalDrawable? { get }
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
    var sampleCount: Int { get set }
}

extension SCNNode {
    func cleanup() {
        for child in childNodes {
            child.cleanup()
        }
        self.geometry = nil
    }
}

extension MTKView: RenderDestinationProvider {
    
}

