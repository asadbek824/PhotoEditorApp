//
//  ContentView.swift
//  PhotoEditorApp
//
//  Created by Asadbek Yoldoshev on 04/08/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var loginViewModel = LoginViewModel()
    @StateObject var photoEditorViewModel = PhotoEditorViewModel()
    @AppStorage("log_Status") private var logStatus: Bool = false
    
    var body: some View {
        VStack {
            if logStatus {
                PhotoEditorView()
                    .environmentObject(photoEditorViewModel)
            } else {
                LoginView()
                    .environmentObject(loginViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}

