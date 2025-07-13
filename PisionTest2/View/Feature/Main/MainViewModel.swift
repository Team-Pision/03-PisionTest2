//
//  MainViewModel.swift
//  PisionTest2
//
//  Created by 여성일 on 7/13/25.
//

import SwiftUI
import AVFoundation
import Vision

final class MainViewModel: ObservableObject {
  @Published var yawAngles: [Double] = []
  @Published var rollAngles: [Double] = []
  @Published var predictedLabel: String = "-"
  @Published var predictionConfidence: Double = 0.0

  private let mlManager = MLManager()!
  private let cameraManager = CameraManager()
  
  var session: AVCaptureSession {
    cameraManager.session
  }
  
  init() {
    cameraManager.requestAndCheckPermissions()
    
    cameraManager.onYawsUpdate = { [weak self] yaws in
      self?.yawAngles = yaws
    }
    
    cameraManager.onRollsUpdate = { [weak self] rolls in
      self?.rollAngles = rolls
    }
    
    cameraManager.onPoseUpdate = { [weak self] pose in
      print("포즈 업데이트 진입")
      self?.mlManager.addPoseObservation(from: pose)
    }
    
    mlManager.onPrediction = { [weak self] label, confidence in
      self?.predictedLabel = label
      self?.predictionConfidence = confidence
    }
  }
  
  func start() {
    cameraManager.startSession()
  }
  
  func stop() {
    cameraManager.stopSession()
  }
}
