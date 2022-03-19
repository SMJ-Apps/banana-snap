//
//  BananaTileView.swift
//  VisionKitTest
//
//  Created by Micah Chollar on 2/11/22.
//

import SwiftUI

struct BananaTileView: View {
    
    var letter: String
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(letter == "" ? .clear : .yellow)
            Text(letter)
                .foregroundColor(.black)
                .padding(10)
                .font(.system(size: 500))
                .minimumScaleFactor(0.01)

        }
    }
}

struct BananaTileView_Previews: PreviewProvider {
    static var previews: some View {
        BananaTileView(letter: "A")
            
    }
}
