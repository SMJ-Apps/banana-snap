//
//  ImageSourceSelectView.swift
//  Banana Snap
//
//  Created by Micah Chollar on 3/18/22.
//

import SwiftUI

struct ImageSelectView: View {
    
    @State private var isPresenting: Bool = false
    @State private var uiImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var classifier = Classifier()
    @State private var bananaGrid = BananaGrid(bananaTiles: [])
    @State private var hasResultsToDisplay: Bool = false
    @State private var textFound = ""
    
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
                Text(textFound)
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
        .navigationViewStyle(.stack) // Without this, you get auto layout warnings for some reason when using .navigationTitle. Not sure this is the actual style we want. Not sure why this fixes the problem either.
        
    }
    
    private func analyzeImage() {
        guard let image = uiImage else { return }
        classifier.detect(uiImage: image)
        if let results = classifier.results {
            let gridBuilder = GridBuilder(observations: results)
            if let grid = gridBuilder.createBananaGrid() {
                bananaGrid = grid
                hasResultsToDisplay = true
            }
            
            var textFound = ""
            for text in results {
                textFound += text.topCandidate() + "; "
            }
            self.textFound = textFound
            
        }
    }
}

struct ImageSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSelectView()
    }
}
