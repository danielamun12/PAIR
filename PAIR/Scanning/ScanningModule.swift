//
//  Scanning.swift
//  PAIR
//
//  Created by Daniela Munoz on 4/21/24.
//

import Foundation
import SwiftUI
import Vision

func processImage(_ image: UIImage) -> [VNRecognizedTextObservation]? {
    guard let cgImage = image.cgImage else {
        return nil
    }
    
    // Create request handler
    let myRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    
    // Create request
    let request = VNRecognizeTextRequest()
    
    // Select the recognition level
    request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
    
    // Set the revision
    request.revision = VNRecognizeTextRequestRevision1
    
    // Control language correction
    request.usesLanguageCorrection = true
    
    do {
        // Send the request to the request handler
        try myRequestHandler.perform([request])
        return request.results
    } catch let error as NSError {
        print("Failed: \(error)")
        return nil
    }
}

func observationsToString(observations: [VNRecognizedTextObservation]) -> [String] {
    var stringResults: [String] = []
    // Iterate over the line results
    for currentObservation in observations {
        let topCandidate = currentObservation.topCandidates(1)
        if let recognizedText = topCandidate.first {
            stringResults.append(recognizedText.string)
        }
    }
    return stringResults
}


public func visualization(_ image: UIImage, observations: [VNDetectedObjectObservation]) -> UIImage {
    var transform = CGAffineTransform.identity
        .scaledBy(x: 1, y: -1)
        .translatedBy(x: 1, y: -image.size.height)
    transform = transform.scaledBy(x: image.size.width, y: image.size.height)

    UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0)
    let context = UIGraphicsGetCurrentContext()

    image.draw(in: CGRect(origin: .zero, size: image.size))
    context?.saveGState()

    context?.setLineWidth(2)
    context?.setLineJoin(CGLineJoin.round)
    context?.setStrokeColor(UIColor.black.cgColor)
    context?.setFillColor(red: 0, green: 1, blue: 0, alpha: 0.3)

    observations.forEach { observation in
        let bounds = observation.boundingBox.applying(transform)
        context?.addRect(bounds)
    }

    context?.drawPath(using: CGPathDrawingMode.fillStroke)
    context?.restoreGState()
    let resultImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resultImage!
}

func extractReceiptInfo(receipt: [String]) -> (String, String, [String: Double], Double, Double, Double) {
    let storeName = receipt[0]
    
    let datePattern = "\\d{1,2}/\\d{1,2}/\\d{2,4}"
    let dateRegex = try! NSRegularExpression(pattern: datePattern)
    let dateString = receipt.joined(separator: " ")
    let dateMatch = dateRegex.firstMatch(in: dateString, options: [], range: NSRange(location: 0, length: dateString.utf16.count))
    var date = ""
    if dateMatch != nil {
        date = (dateString as NSString).substring(with: dateMatch!.range)
    }
    var subtotal = 0.0
    var total = 0.0
    var tax = 0.0
    var items = [String: Double]()
    for i in 2..<receipt.count {
        let pricePattern = "^\\$?\\d+\\.\\d{2}$"
        let priceRegex = try! NSRegularExpression(pattern: pricePattern)
        let priceMatch = priceRegex.firstMatch(in: receipt[i], options: [], range: NSRange(location: 0, length: receipt[i].utf16.count))
        if priceMatch != nil {
            let itemName = receipt[i-1]
            var itemPrice = receipt[i]
            if itemPrice.first == "$" {
                itemPrice.removeFirst()
            }
            items[itemName] = Double(itemPrice)
        } else if receipt[i] == "TOTAL" || receipt[i] == "Total" {
            var totalString = receipt[i+1]
            if totalString.first == "$" {
                totalString.removeFirst()
                total = Double(totalString) ?? 0.0
            }
        } else if receipt[i] == "SUBTOTAL" || receipt[i] == "Subtotal" {
            var subtotalString = receipt[i+1]
            if subtotalString.first == "$" {
                subtotalString.removeFirst()
                subtotal = Double(subtotalString) ?? 0.0
            }
        } else if receipt[i] == "TAX" || receipt[i] == "Tax" {
            var taxString = receipt[i+1]
            if taxString.first == "$" {
                taxString.removeFirst()
                tax = Double(taxString) ?? 0.0
            }
        }
    }
    items.removeValue(forKey: "Total")
    items.removeValue(forKey: "TOTAL")
    items.removeValue(forKey: "Subtotal")
    items.removeValue(forKey: "SUBTOTAL")
    items.removeValue(forKey: "Tax")
    items.removeValue(forKey: "TAX")
    
    return (storeName, date, items, subtotal, tax, total)
}

func trimNonLetters(_ input: String) -> String {
    // Regular expression pattern to match non-alphabetic characters at the beginning/end
    let pattern = "^[^a-zA-Z]+|[^a-zA-Z]+$"
    
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: input.utf16.count)
        
        // Replace non-alphabetic characters at the beginning/end with empty string
        let trimmed = regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: "")
        
        return trimmed
    } catch {
        print("Error creating regular expression: \(error)")
        return input // Return original string in case of error
    }
}
