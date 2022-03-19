//
//  ImageSourceSelectView.swift
//  Banana Snap
//
//  Created by Micah Chollar on 3/18/22.
//

import SwiftUI

struct ImageSelectView: View {
    
    @State var isPresenting: Bool = false
    @State var uiImage: UIImage?
    @State var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var classifier = Classifier()
    @State var bananaGrid = BananaGrid(bananaTiles: [])
    @State var hasResultsToDisplay: Bool = false
    
    var body: some View {
        NavigationView {
            
            VStack{
                HStack{
                    Spacer()
                    Image(systemName: "photo")
                        .onTapGesture {
                            isPresenting = true
                            sourceType = .photoLibrary
                        }
                    Spacer()
                    Image(systemName: "camera")
                        .onTapGesture {
                            isPresenting = true
                            sourceType = .camera
                        }
                    Spacer()
                }
                .font(.largeTitle)
                .foregroundColor(.blue)
                                
                Rectangle()
                    .strokeBorder()
                    .foregroundColor(.yellow)
                    .overlay(
                            Group {
                              if uiImage != nil {
                                Image(uiImage: uiImage!)
                                  .resizable()
                                  .scaledToFit()
                              }
                            }
                          )
//                NavigationLink(destination: BoardView(bananaGrid: bananaGrid), isActive: $hasResultsToDisplay) {
                NavigationLink(destination: BoardView(bananaGrid: bananaGrid)) {
                    Text("Snap!")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!hasResultsToDisplay)
                
            }
            
            .sheet(isPresented: $isPresenting, onDismiss: analyzeImage) {
                ImagePicker(uiImage: $uiImage, isPresenting: $isPresenting, sourceType: $sourceType)
            }
            .padding()
            .navigationTitle("Banana Snap")
        }
        
    }
    
    private func analyzeImage() {
        guard let image = uiImage else { return }
        classifier.detect(uiImage: image)
        if let results = classifier.results {
            let gridBuilder = GridBuilder(observations: results)
            if let grid = gridBuilder.findBananaGrid() {
                bananaGrid = grid
                hasResultsToDisplay = true
            }
        }
    }
}

struct ImageSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSelectView()
    }
}
