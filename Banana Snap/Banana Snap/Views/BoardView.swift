//
//  BoardView.swift
//  Banana Snap
//
//  Created by Micah Chollar on 3/18/22.
//

import SwiftUI

struct BoardView: View {
    var bananaGrid: BananaGrid
    
    var body: some View {

        VStack {
            ForEach(bananaGrid.bananaTiles, id: \.self) { array in
                HStack {
                    ForEach(array) { element in
                        BananaTileView(letter: element.letter ?? "_")
                            .aspectRatio(1.0, contentMode: .fit)
                    }
                }
            }
        }
        .padding()
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        
        let bananaGrid = BananaGrid(bananaTiles: [
            [BananaTile(letter: "A"),
             BananaTile(letter: "B"),
             BananaTile(letter: "C")],
            [BananaTile(letter: "D"),
             BananaTile(letter: "E"),
             BananaTile(letter: "F")],
            [BananaTile(letter: "G"),
             BananaTile(letter: "H"),
             BananaTile(letter: "I")],
        ])
        
        BoardView(bananaGrid: bananaGrid)
    }
}
