//
//  LoginViewModel.swift
//  PhotoEditorApp
//
//  Created by Asadbek Yoldoshev on 05/08/24.
//

import SwiftUI
import CryptoKit
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn

public class LoginViewModel: ObservableObject {
    
    @Published var errorMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var nonce: String?
    @AppStorage("log_Status") var logStatus: Bool = false
    
    public init() { }
    
    func showError(_ message: String) {
        errorMessage = message
        showAlert.toggle()
        isLoading = false
    }
    
    func loginWithFirebase(_ authorization: ASAuthorization) {

        isLoading = true
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = nonce else {
                showError("Cannot process your request")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                showError("Cannot process your request")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                showError("Cannot process your request")
                return
            }
            
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    self.showError(error.localizedDescription)
                    return
                }
                
                self.logStatus = true
                self.isLoading = false
            }
        }
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func logGoogleUser(user: GIDGoogleUser) {
        Task {
            do {
                guard let idToken = user.idToken?.tokenString else {
                    showError("Missing Google ID Token")
                    isLoading = false
                    return
                }
                let accessToken = user.accessToken.tokenString

                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                try await Auth.auth().signIn(with: credential)

                
                isLoading = true
                
                await MainActor.run {
                    withAnimation(.easeInOut) {
                        logStatus = true
                    }
                }
            } catch {
                await MainActor.run {
                    showError(error.localizedDescription)
                    isLoading = false  
                }
            }
        }
    }
}

extension UIApplication {
    
    func rootController() -> UIViewController {
        guard let window = connectedScenes.first as? UIWindowScene else { return .init() }
        guard let viewcontroller = window.windows.last?.rootViewController else { return .init() }
         
        return viewcontroller
    }
}
