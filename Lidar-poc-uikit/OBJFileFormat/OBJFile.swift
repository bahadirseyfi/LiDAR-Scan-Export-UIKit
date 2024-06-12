//
//  OBJFile.swift
//  Lidar-poc-uikit
//
//  Created by Bahadir Seyfi on 11/06/2024.
//

import Foundation

struct OBJFile {
    static func write(fileName: String, cpuParticlesBuffer: inout [CPUParticle]) throws -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docs.appendingPathComponent(fileName).appendingPathExtension("obj")
        
        var objString = "# OBJ file\n"
        
        // Vertexleri yaz
        for particle in cpuParticlesBuffer {
            let position = particle.position
            objString += "v \(position.x) \(position.y) \(position.z)\n"
        }
        
        // Yüzeyleri yaz (opsiyonel, yüzey oluşturmak isterseniz)
        // örneğin: "f 1 2 3\n"
        
        do {
            try objString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            throw error
        }
        
        return fileURL
    }
}
