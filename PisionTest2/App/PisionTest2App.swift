//
//  PisionTest2App.swift
//  PisionTest2
//
//  Created by 여성일 on 7/13/25.
//

import SwiftUI

@main
struct PisionTest2App: App {
  var body: some Scene {
    WindowGroup {
      MainView(viewModel: MainViewModel())
    }
  }
}
