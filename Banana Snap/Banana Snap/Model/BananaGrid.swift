//
//  BananaGrid.swift
//  VisionKitTest
//
//  Created by Micah Chollar on 2/11/22.
//

import Foundation

struct BananaTile: Identifiable, Hashable {
    var letter: String?
    let id = UUID()
}

struct BananaGrid {
    
    var bananaTiles: [[BananaTile]]
    var gridSize: (rows: Int, columns: Int) {
        get {
            if let firstRow = bananaTiles.first {
                let columnCount = firstRow.count
                return (bananaTiles.count, columnCount)
            } else {
                return (0, 0)
            }
        }
    }
    
    
    
}
