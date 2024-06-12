//
//  ExportViewController.swift
//  Lidar-poc-uikit
//
//  Created by Bahadir Seyfi on 07/06/2024.
//

import UIKit

final class ExportViewController: UIViewController {

    var mainController: PointCloudViewController!
    
    // MARK: - EXPORT
    private var exportData = [URL]()
    private var selectedExport: URL?
    private var selectedExportIdx : Int?
    
    @IBOutlet private weak var exportLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }
    
    private func initData() {
        guard let mainController = mainController else {
            print("mainController is nil")
            return
        }
        
        guard let savedCloudURLs = mainController.renderer?.savedCloudURLs else {
            print("mainController.renderer.savedCloudURLs is nil")
            return
        }
        
        self.exportData = savedCloudURLs
        
        if !exportData.isEmpty {
            print("LINKS: ", exportData)
            exportLabel.text = "\(exportData.count)"
        }
    }
    
    private func exportingData() {
        if !exportData.isEmpty {
            self.selectedExportIdx = exportData.endIndex - 1
            if let selectedExport = exportData[safe: self.selectedExportIdx ?? 0] {
                dismissModal()
                print(selectedExport)
                mainController.export(url: selectedExport)
            } else {
                print("No valid export URL found.")
            }
        }
    }
    
    func dismissModal() { self.dismiss(animated: true, completion: nil) }
    
    @IBAction
    private func exportButtonTapped(_ sender: Any) {
        exportingData()
    }
    
    @IBAction func exportAsOBJ(_ sender: Any) {
        exportingData()
    }
    @IBAction 
    private func dismissAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
