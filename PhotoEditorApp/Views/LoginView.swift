//
//  LoginView.swift
//  PhotoEditorApp
//
//  Created by Asadbek Yoldoshev on 04/08/24.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift
import Firebase

struct LoginView: View {
    
    @EnvironmentObject var viewModel: LoginViewModel
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        ZStack(alignment: .bottom) {
            BackgroundView()
            
            VStack(alignment: .leading) {
                Text("Sign in to work with \nyour photos now")
                    .font(.title.bold())
                
                HStack(spacing: 8) {
                    SignInButton(viewModel: viewModel)
                    SignInButton(viewModel: viewModel, isGoogle: true)
                }
                
                OtherSignInOptionsButton()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .onAppear {
            withAnimation {
                viewModel.isLoading = false
            }
        }
        .alert(viewModel.errorMessage, isPresented: $viewModel.showAlert) { }
        .overlay {
            if viewModel.isLoading {
                LoadingScreen()
            }
        }
    }
}

@ViewBuilder
func BackgroundView() -> some View {
    GeometryReader { geometry in
        let size = geometry.size
        
        Image(.BG)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .mask {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white,
                                .white.opacity(0.9),
                                .white.opacity(0.6),
                                .white.opacity(0.2),
                                .clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .ignoresSafeArea()
    }
}

@ViewBuilder
func SignInButton(viewModel: LoginViewModel, isGoogle: Bool = false) -> some View {
    ZStack {
        Capsule()
        
        HStack {
            Group {
                if isGoogle {
                    Image("googleIcon")
                        .resizable()
                        .renderingMode(.template)
                } else {
                    Image(systemName: "applelogo")
                        .resizable()
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
            
            Text("\(isGoogle ? "Google" : "Apple") Sign in")
                .font(.callout)
                .lineLimit(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 15)
    }
    .frame(height: 45)
    .padding(.top, 10)
    .overlay {
        if isGoogle {
            GoogleSignInButton {
                viewModel.isLoading = true

                GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.rootController()) { result, error in
                    if let error = error {
                        print(error.localizedDescription)
                        viewModel.isLoading = false
                        return
                    }
                    
                    guard let user = result?.user else {
                        print("Failed to get Google user")
                        viewModel.isLoading = false
                        return
                    }
                    
                    viewModel.logGoogleUser(user: user)
                }
            }
            .clipShape(Capsule())
            .frame(height: 45)
            .padding(.top, 10)
            .blendMode(.overlay)
        } else {
            SignInWithAppleButton { request in
                let nonce = viewModel.randomNonceString()
                viewModel.nonce = nonce
                request.requestedScopes = [.email, .fullName]
                request.nonce = viewModel.sha256(nonce)
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    viewModel.loginWithFirebase(authorization)
                case .failure(let error):
                    viewModel.showError(error.localizedDescription)
                }
            }
            .clipShape(Capsule())
            .frame(height: 45)
            .padding(.top, 10)
            .blendMode(.overlay)
        }
    }
    .clipped()
}


@ViewBuilder
func OtherSignInOptionsButton() -> some View {
    Button(action: {
        // Handle other sign-in options
    }, label: {
        Text("Other Sign in Options")
            .foregroundStyle(Color.primary)
            .frame(height: 45)
            .frame(maxWidth: .infinity)
            .containerShape(.capsule)
            .background {
                Capsule()
                    .stroke(Color.primary, lineWidth: 0.5)
            }
    })
    .padding(.top, 10)
}

#Preview {
    LoginView()
}
