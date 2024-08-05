//
//  PhotoEditorAppApp.swift
//  PhotoEditorApp
//
//  Created by Asadbek Yoldoshev on 04/08/24.
//

import SwiftUI
import Firebase

@main
struct PhotoEditorAppApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
