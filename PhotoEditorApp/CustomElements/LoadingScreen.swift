//
//  LoadingScreen.swift
//  PhotoEditorApp
//
//  Created by Asadbek Yoldoshev on 05/08/24.
//

import SwiftUI

struct LoadingScreen: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            
            ProgressView()
                .frame(width: 45, height: 45)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 5))
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoadingScreen()
}
