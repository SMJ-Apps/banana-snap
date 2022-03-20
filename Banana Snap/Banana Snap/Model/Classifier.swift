//
//  Classifier.swift
//  Banana Snap
//
//  Created by Micah Chollar on 3/18/22.
//

import CoreML
import Vision
import UIKit


class Classifier {
    
    private(set) var results: [VNRecognizedTextObservation]?
    private var ocrRequest: VNRecognizeTextRequest!
    
    init() {
        configureOCR()
    }
    
    private func configureOCR() {

        ocrRequest = VNRecognizeTextRequest { [weak self] (request, error) in
            self?.ocrRequestCompletion(request, error: error)
        }
        ocrRequest.recognitionLevel = .accurate
        ocrRequest.recognitionLanguages = ["en-US", "en-GB"]
        ocrRequest.usesLanguageCorrection = true
        let aScalars = "A".unicodeScalars
        let aCode = aScalars[aScalars.startIndex].value

        let characters: [Character] = (0..<26).map {
            i in Character(UnicodeScalar(aCode + i)!)
        }
        var letters = characters.map{"\($0)"}
        letters += ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        ocrRequest.customWords = letters
    }
    
    private func ocrRequestCompletion(_ request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            return
        }

        var ocrText = ""
        for observation in observations {
            let text = observation.topCandidate()
            ocrText += text + "\n"
        }
        print("Results found: " + ocrText)

        results = observations
    }
    
    func detect(uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([self.ocrRequest])
        } catch let error {
            print(error)
            //TODO: Maybe display error to user
        }
    }
}
