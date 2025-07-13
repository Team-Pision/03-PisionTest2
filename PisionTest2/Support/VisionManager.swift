//
//  VisionManager.swift
//  PisionTest2
//
//  Created by 여성일 on 7/13/25.
//

import Foundation
import Vision

final class VisionManager {
  private let request = VNDetectFaceLandmarksRequest()
  private let sequenceHandler = VNSequenceRequestHandler()
  
  var onFaceDetection: ((_ observation: [VNFaceObservation], _ yaws: [Double], _ rolls: [Double]) -> Void)?
  
  func process(pixelBuffer: CVPixelBuffer) {
    do {
      try sequenceHandler.perform([request], on: pixelBuffer)
      
      guard let result = request.results else { return }
      
      var yaws: [Double] = []
      var rolls: [Double] = []
      
      for face in result { 
        if let yaw = face.yaw?.doubleValue {
          yaws.append(yaw * 180 / .pi)
        }
        
        if let roll = face.roll?.doubleValue {
          rolls.append(roll * 180 / .pi)
        }
      }
    
      onFaceDetection?(result, yaws, rolls)
    } catch {
      print("Log: Vision 처리 에러")
    }
  }
}
