//
//  MainView.swift
//  PisionTest1
//
//  Created by 여성일 on 7/9/25.
//

import AVFoundation
import SwiftUI
import CoreML

struct MainView: View {
  @State private var currentState = "Snooze"
  @StateObject private var viewModel: MainViewModel
  
  init(viewModel: MainViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
}

extension MainView {
  var body: some View {
    ZStack {
      Color.clear.ignoresSafeArea()
      
      VStack {
        CameraView(session: viewModel.session)
        
        VStack {
          Text("rolls: \(viewModel.rollAngles)") // 고개를 좌/우로 기울이는 동작
          Text("yaw: \(viewModel.yawAngles)") // 고개를 좌/우로 도리도리 하는 동작
        }
        .font(.headline)
      }
    }
    .onAppear {
      viewModel.start()
    }
    .onDisappear {
      viewModel.stop()
    }
  }
}

#Preview {
  MainView(viewModel: MainViewModel())
}
