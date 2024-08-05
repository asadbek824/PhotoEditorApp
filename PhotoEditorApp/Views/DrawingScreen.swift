//
//  DrawingScreen.swift
//  PhotoEditorApp
//
//  Created by Asadbek Yoldoshev on 05/08/24.
//

import SwiftUI
import PencilKit

struct DrawingScreen: View {
    
    @EnvironmentObject var vm: PhotoEditorViewModel
    
    var body: some View {
        ZStack {
            GeometryReader { proxy -> AnyView in
                let size = proxy.frame(in: .global)
                
                DispatchQueue.main.async {
                    if vm.rect == .zero {
                        vm.rect = size
                    }
                }
                
                return AnyView(
                    ZStack {
                        CanvasView(canvas: $vm.canvas, imageData: $vm.imageData, toolPicker: $vm.toolPicker, rect: size.size)
                        
                        ForEach(vm.textBoxes.indices, id: \.self) { index in
                            let box = vm.textBoxes[index]
                            
                            Text(box.text)
                                .font(.system(size: 30))
                                .fontWeight(box.isBold ? .bold : .none)
                                .foregroundColor(box.textColor)
                                .offset(box.offset)
                                .gesture(DragGesture()
                                    .onChanged { value in
                                        let translation = value.translation
                                        vm.textBoxes[index].offset = CGSize(width: box.lastOffset.width + translation.width, height: box.lastOffset.height + translation.height)
                                    }
                                    .onEnded { _ in
                                        vm.textBoxes[index].lastOffset = vm.textBoxes[index].offset
                                    }
                                )
                                .onLongPressGesture {
                                    vm.toolPicker.setVisible(false, forFirstResponder: vm.canvas)
                                    vm.canvas.resignFirstResponder()
                                    vm.currentIndex = index
                                    withAnimation {
                                        vm.addNewBox = true
                                    }
                                }
                        }
                    }
                )
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    vm.saveImage()
                } label: {
                    Text("save")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    vm.textBoxes.append(TextBox())
                    vm.currentIndex = vm.textBoxes.count - 1
                    
                    withAnimation {
                        vm.addNewBox.toggle()
                    }
                    
                    vm.toolPicker.setVisible(false, forFirstResponder: vm.canvas)
                    vm.canvas.resignFirstResponder()
                } label: {
                    Image(systemName: "plus")
                }
            }
        })
    }
}

struct CanvasView: UIViewRepresentable {
    
    @Binding var canvas: PKCanvasView
    @Binding var imageData: Data
    @Binding var toolPicker: PKToolPicker
    
    var rect: CGSize
    
    func makeUIView(context: Context) -> PKCanvasView {
        
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
        canvas.drawingPolicy = .anyInput
        
        if let image = UIImage(data: imageData) {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            
            let subView = canvas.subviews[0]
            subView.addSubview(imageView)
            subView.sendSubviewToBack(imageView)
            
            toolPicker.setVisible(true, forFirstResponder: canvas)
            toolPicker.addObserver(canvas)
            canvas.becomeFirstResponder()
        }
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        
    }
}
