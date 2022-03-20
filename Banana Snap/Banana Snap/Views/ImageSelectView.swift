//
//  ImageSourceSelectView.swift
//  Banana Snap
//
//  Created by Micah Chollar on 3/18/22.
//

import SwiftUI


struct ImageSelectView: View {
    
    @State private var isPhotoPresenting: Bool = false
    @State private var isCameraPresenting: Bool = false
    @State private var uiImage: UIImage?
    @State private var overlay: [PreviewBox] = []
    @State private var imageSize = CGSize()
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var classifier = Classifier()
    @State private var bananaGrid = BananaGrid(bananaTiles: [])
    @State private var hasResultsToDisplay: Bool = false
    @State private var textFound = " "
    
    var body: some View {
        NavigationView {
            
            VStack{
                HStack{
                    Spacer()
                    Button(action: { isPhotoPresenting.toggle() }) {
                        Label("", systemImage: "photo")
                    }
                    .sheet(isPresented: $isPhotoPresenting, onDismiss: analyzeImage) {
                        ImagePicker(uiImage: $uiImage, isPresenting: $isPhotoPresenting, sourceType: $sourceType)
                    }
                    
                    Spacer()
                    Button(action: { isCameraPresenting.toggle() }) {
                        Label("", systemImage: "camera")
                    }
                    .sheet(isPresented: $isCameraPresenting, onDismiss: analyzeImage) {
                        DocumentScanner(uiImage: $uiImage, isPresenting: $isCameraPresenting)
                    }
                    Spacer()
                }
                .font(.largeTitle)
                .foregroundColor(.blue)
                                
                Rectangle()
                    .strokeBorder()
                    .foregroundColor(.yellow)
                    .overlay(
                        ZStack {
                            if uiImage != nil {
                                Image(uiImage: uiImage!)
                                    .resizable()
                                    .readSize { imSize in
                                        imageSize = imSize
                                    }
                            }
                            ForEach(overlay) { previewBox in
                                ZStack{
                                    Path(previewBox.boundingBox)
                                        .foregroundColor(.red)
                                        .opacity(0.5)
                                    Text(previewBox.text)
                                        .foregroundColor(.white)
                                        .bold()
                                        .position(x: previewBox.boundingBox.midX, y: previewBox.boundingBox.midY)
                                    
                                }
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
            
            .padding()
            .navigationTitle("Banana Snap")
        }
        .navigationViewStyle(.stack) // Without this, you get auto layout warnings for some reason when using .navigationTitle. Not sure this is the actual style we want. Not sure why this fixes the problem either. SwiftUI bug, I guess.
        
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
            
            var newOverlay = [PreviewBox]()
            var textFound = ""
            for text in results {
                textFound += text.topCandidate() + "; "
                
                let resizedBoundingBox = CGRect(x: text.boundingBox.origin.x * imageSize.width,
                                                y: imageSize.height - (text.boundingBox.origin.y * imageSize.height) - (text.boundingBox.height * imageSize.height),
                                                width: text.boundingBox.width * imageSize.width,
                                                height: text.boundingBox.height * imageSize.height)
                let newPreviewBox = PreviewBox(boundingBox: resizedBoundingBox,
                                               text: text.topCandidate(),
                                               id: text.uuid)
                newOverlay.append(newPreviewBox)
            }
            self.overlay = newOverlay
            self.textFound = textFound
            
        }
    }
}

struct PreviewBox: Identifiable {
    var boundingBox: CGRect
    var text: String
    var id: UUID
}

// MARK: - Extension to be able to get size of Image in order to create overlay
extension View {
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

private struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}




struct ImageSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSelectView()
    }
}
