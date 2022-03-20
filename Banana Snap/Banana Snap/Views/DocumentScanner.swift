//
//  DocumentScanner.swift
//  Banana Snap
//
//  Created by Micah Chollar on 3/20/22.
//

import Foundation
import SwiftUI
import VisionKit

struct DocumentScanner: UIViewControllerRepresentable {
    
    @Binding var uiImage: UIImage?
    @Binding var isPresenting: Bool
    
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentScanner = VNDocumentCameraViewController()
        documentScanner.delegate = context.coordinator
        return documentScanner
        
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate, UINavigationControllerDelegate {
        
        let parent: DocumentScanner
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.isPresenting = false
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            parent.uiImage = scan.imageOfPage(at: 0)
            parent.isPresenting = false
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print(error)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.uiImage = info[.originalImage] as? UIImage
            parent.isPresenting = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresenting = false
        }
        
        init(_ documentScanner: DocumentScanner) {
            self.parent = documentScanner
        }
    }
    
    
}
