//
//  MainViewModel.swift
//  PisionTest2
//
//  Created by 여성일 on 7/13/25.
//

import SwiftUI
import AVFoundation

final class MainViewModel: ObservableObject {
  @Published var yawAngles: [Double] = []
  @Published var rollAngles: [Double] = []
  
  let cameraManager = CameraManager()
  
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
  }
  
  func start() {
    cameraManager.startSession()
  }
  
  func stop() {
    cameraManager.stopSession()
  }
}
