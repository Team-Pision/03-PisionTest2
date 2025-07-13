//
//  CameraManager.swift
//  PisionTest1
//
//  Created by 여성일 on 7/9/25.
//

import AVFoundation
import SwiftUI
import Vision

final class CameraManager: NSObject, ObservableObject {
  let session = AVCaptureSession()
  
  private let videoOutput = AVCaptureVideoDataOutput()
  private var isSeesionConfigured = false
  private let sessionQueue = DispatchQueue(label: "CameraSessionQueue")
  
  private let visionManager = VisionManager()
  
  var onYawsUpdate: (([Double]) -> Void)?
  var onRollsUpdate: (([Double]) -> Void)?
  
  override init() {
    super.init()
    
    visionManager.onFaceDetection = { [weak self] _, yaws, rolls in
      DispatchQueue.main.async {
        self?.onYawsUpdate?(yaws)
        self?.onRollsUpdate?(rolls)
      }
    }
  }
  
  func startSession() {
    sessionQueue.async {
      if !self.session.isRunning {
        self.session.startRunning()
      }
    }
  }
  
  func stopSession() {
    sessionQueue.async {
      if self.session.isRunning {
        self.session.stopRunning()
      }
    }
  }
  
  func requestAndCheckPermissions() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
        if granted {
          self?.configureSessionIfNeeded()
        } else {
          print("사용자가 카메라 접근을 거부했습니다.")
        }
      }
      
    case .authorized:
      configureSessionIfNeeded()
      
    case .restricted, .denied:
      print("카메라 접근이 제한되었거나 거부됨")
      
    @unknown default:
      print("알 수 없는 권한 상태")
    }
  }
}

extension CameraManager {
  private func configureSession() {
    session.beginConfiguration()
    session.sessionPreset = .high
    
    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera ,for: .video, position: .front),
          let input = try? AVCaptureDeviceInput(device: device),
          session.canAddInput(input) else {
      print("Log: 카메라 인풋 설정 실패")
      session.commitConfiguration()
      return
    }
    session.addInput(input)
    
    if session.canAddOutput(videoOutput) {
      videoOutput.videoSettings = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
      ]
      videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
      videoOutput.alwaysDiscardsLateVideoFrames = true
      session.addOutput(videoOutput)
      
      if #available(iOS 17.0, *) {
        videoOutput.connections.first?.videoRotationAngle = 0
      } else {
        videoOutput.connections.first?.videoOrientation = .portrait
      }
      
      session.commitConfiguration()
    }
    
    session.commitConfiguration()
  }
  
  private func configureSessionIfNeeded() {
    guard !isSeesionConfigured else {
      print("이미 세션이 구성되어 있음")
      return
    }
    isSeesionConfigured = true
    configureSession()
  }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    visionManager.process(pixelBuffer: pixelBuffer)
  }
}
