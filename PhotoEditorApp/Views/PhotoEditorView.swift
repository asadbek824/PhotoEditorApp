//
//  PhotoEditorView.swift
//  PhotoEditorApp
//
//  Created by Asadbek Yoldoshev on 05/08/24.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct PhotoEditorView: View {
    
    @EnvironmentObject var vm: PhotoEditorViewModel
    @AppStorage("log_Status") private var logStatus: Bool = false
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    if let _ = UIImage(data: vm.imageData) {
                        
                        DrawingScreen()
                            .environmentObject(vm)
                            .toolbar(content: {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button {
                                        vm.cancelImageEditing()
                                    } label: {
                                        Image(systemName: "xmark")
                                    }
                                }
                            })
                    } else {
                        Button(action: {
                            vm.showImagePicker.toggle()
                        }, label: {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.black)
                                .frame(width: 70, height: 70)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.07), radius: 5, x: 5, y: 5)
                                .shadow(color: Color.black.opacity(0.07), radius: 5, x: -5, y: -5)
                        })
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    try? Auth.auth().signOut()
                                    GIDSignIn.sharedInstance.signOut()
                                    withAnimation(.easeInOut) {
                                        logStatus = false
                                    }
                                } label: {
                                    Text("LogOut")
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Image Editor")
            }
            
            if vm.addNewBox {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                
                TextField("Type Here", text: $vm.textBoxes[vm.currentIndex].text)
                    .font(.system(size: 35, weight: vm.textBoxes[vm.currentIndex].isBold ? .bold : .regular))
                    .foregroundColor(vm.textBoxes[vm.currentIndex].textColor)
                    .colorScheme(.dark)
                    .padding()
                
                HStack {
                    Button(action: {
                        vm.textBoxes[vm.currentIndex].isAdded = true
                        vm.toolPicker.setVisible(true, forFirstResponder: vm.canvas)
                        vm.canvas.becomeFirstResponder()
                        
                        withAnimation {
                            vm.addNewBox = false
                        }
                    }, label: {
                        Text("Add")
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding()
                    })
                    
                    Spacer()
                    
                    Button(action: vm.cancelTextView, label: {
                        Text("Cancel")
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding()
                    })
                }
                .overlay {
                    HStack(spacing: 15) {
                        ColorPicker("", selection: $vm.textBoxes[vm.currentIndex].textColor)
                            .labelsHidden()
                        
                        Button {
                            vm.textBoxes[vm.currentIndex].isBold.toggle()
                        } label: {
                            Text(vm.textBoxes[vm.currentIndex].isBold ? "Normal" : "Bold")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .sheet(isPresented: $vm.showImagePicker, content: {
            ImagePicker(showPicker: $vm.showImagePicker, imageData: $vm.imageData)
        })
        .alert(isPresented: $vm.showAlert, content: {
            Alert(title: Text("Message"), message: Text(vm.message), dismissButton: .destructive(Text("Ok")))
        })
    }
}

#Preview {
    PhotoEditorView()
}
