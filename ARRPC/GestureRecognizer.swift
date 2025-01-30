//
//  GestureRecognizer.swift
//  ARRPC
//
//  Created by Lakshay Gupta on 14/01/25.
//



import Vision
import CoreML
import SwiftUI

class GestureRecognizer {
    
    private var model: VNCoreMLModel

    init() {
        guard let mlModel = try? RockPaperScizzors(configuration: MLModelConfiguration()).model else {
            fatalError("Failed to load CoreML model")
        }
        self.model = try! VNCoreMLModel(for: mlModel)
    }

    func recognizeGesture(from pixelBuffer: CVPixelBuffer, completion: @escaping (String?) -> Void) {
        let request = VNCoreMLRequest(model: model) { request, _ in
            if let results = request.results as? [VNClassificationObservation], let topResult = results.first {
                completion(topResult.identifier)
            } else {
                completion(nil)
            }
        }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}
