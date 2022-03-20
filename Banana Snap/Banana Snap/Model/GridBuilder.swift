//
//  GridBuilder.swift
//  VisionKitTest
//
//  Created by Micah Chollar on 2/7/22.
//

import Foundation
import Vision
import UIKit

struct ObservedLetter {
    var text: String
    var boundingBox: CGRect
}

/// GridBuilder
///
/// Usage.
/// Upon init, either pass in an array of VNRecognizedTextObservation, or ObservedLetter.
/// If the former, it will convert that array to an array of "ObservedLetter" which is a struct containing two elements:
///  - text: String
///  - boundingBox: CGRect
///
///  It will build and return a BananaGrid? object after running "createBananaGrid()"
class GridBuilder {
    
    private var observedLetters = [ObservedLetter]()
    private var observations: [VNRecognizedTextObservation]!
    
    private var grid: [[String]] = [[]]
    private var gridSize: (rows: Int, columns: Int) = (0, 0)
    private var rowYValues = [CGFloat]()
    private var columnXValues = [CGFloat]()
    
    private let ROW_VERTICAL_TOLERANCE: CGFloat = 0.1       // May need to adjust these after testing
    private let COLUMN_HORIZONTAL_TOLERANCE: CGFloat = 0.1  //
    
    init(observations: [VNRecognizedTextObservation]) {
        self.observations = observations
        convertTextObservationsToLetters()
    }
    
    init(observedLetters: [ObservedLetter]) {
        self.observedLetters = observedLetters
    }
    
    func createBananaGrid() -> BananaGrid? {
        guard !observedLetters.isEmpty else {
            print("No observations found")
            return nil
        }
        findGridSize()
        fillGridWithBlanks()
        buildGrid()
        printGrid()
        
        return convertGridToBananaGrid()
    }
    
    private func convertTextObservationsToLetters() {
        
        for observation in observations {
            
            let text = filteredWord(observation.topCandidate())
            
            if text.count == 1 {
                let observedLetter = ObservedLetter(text: text, boundingBox: observation.boundingBox)
                observedLetters.append(observedLetter)
            } else {
                let multiLetters = breakApartWord(observation)
                for letter in multiLetters {
                    observedLetters.append(letter)
                }
            }
        }
    }
          
    private func breakApartWord(_ observation: VNRecognizedTextObservation) -> [ObservedLetter] {
        guard let observedWord = observation.topCandidates(1).first?.string
        else {
            return []
        }
        let text = filteredWord(observedWord)
        
        let newBoxes = calculateIndividualBoxesFor(observation, wordLength: text.count)
        
        var observedLetters = [ObservedLetter]()
        
        for (index, letter) in text.enumerated() {
            let newObservedLetter = ObservedLetter(text: "\(letter)", boundingBox: newBoxes[index])
            observedLetters.append(newObservedLetter)
        }

        return observedLetters
    }
    
    private func filteredWord(_ word: String) -> String {
        var text = word.components(separatedBy: CharacterSet.punctuationCharacters).joined()
        text = text.components(separatedBy: " ").joined()
        return text
    }
    
    private func calculateIndividualBoxesFor(_ observation: VNRecognizedTextObservation, wordLength: Int) -> [CGRect] {
        
        let wordWidth = observation.boundingBox.width
        let wordHeight = observation.boundingBox.height
        let wordBottom = observation.bottomLeft.y
        let wordLeftX = observation.bottomLeft.x
        let letterWidth = wordWidth / CGFloat(wordLength)
        
        var newBoxes = [CGRect]()
        
        for i in 0 ..< wordLength {
            let newBox = CGRect(x: wordLeftX + (CGFloat(i) * letterWidth),
                                y: wordBottom,
                                width: letterWidth,
                                height: wordHeight)
            newBoxes.append(newBox)
        }
        
        return newBoxes
        
    }
       
    private func findGridSize() {
        
        let rows = countRows()
        let columns = countColumns()
        
        gridSize = (rows, columns)
        
    }
    
    private func countRows() -> Int {
        
        let verticalSortedObservations = observedLetters.sorted {
            $0.boundingBox.midY < $1.boundingBox.midY
        }
        
        rowYValues = [CGFloat]()
        var prevYValue = verticalSortedObservations.first!.boundingBox.midY
        rowYValues.append(prevYValue)
        
        for obs in verticalSortedObservations {
            if prevYValue + ROW_VERTICAL_TOLERANCE < obs.boundingBox.midY {
                rowYValues.append(obs.boundingBox.midY)
                prevYValue = obs.boundingBox.midY
            }
        }
        
        print("countRows found: \(rowYValues.count) rows")
        return rowYValues.count
    }
    
    private func countColumns() -> Int {
        let horizontalSortedObservations = observedLetters.sorted {
            $0.boundingBox.midX < $1.boundingBox.midX
        }
        
        columnXValues = [CGFloat]()
        var prevXValue = horizontalSortedObservations.first!.boundingBox.midX
        columnXValues.append(prevXValue)
        
        for obs in horizontalSortedObservations {
            if prevXValue + COLUMN_HORIZONTAL_TOLERANCE < obs.boundingBox.midX {
                columnXValues.append(obs.boundingBox.midX)
                prevXValue = obs.boundingBox.midX
            }
        }
        
        print("countColumns found: \(columnXValues.count) columns")
        return columnXValues.count
    }
    
    
    private func fillGridWithBlanks() {
        
        grid = [[String]](repeating: [String](repeating: "", count: gridSize.columns), count: gridSize.rows)
    }
    
    private func buildGrid() {
        for observation in observedLetters {
            let row = closestRowIndexFor(observedLetter: observation)
            let column = closestColumnIndexFor(observedLetter: observation)
            
            grid[row][column] = observation.text
            
        }
    }
    
    private func closestRowIndexFor(observedLetter: ObservedLetter) -> Int {
        var index = gridSize.rows
        for value in rowYValues {
            if value + ROW_VERTICAL_TOLERANCE > observedLetter.boundingBox.midY &&
                value - ROW_VERTICAL_TOLERANCE < observedLetter.boundingBox.midY {
                return index - 1
            } else {
                index -= 1
            }
        }
        print("Unable to find closest row for observation: \(observedLetter)")
        return -1
    }
    
    private func closestColumnIndexFor(observedLetter: ObservedLetter) -> Int {
        var index = 0
        for value in columnXValues {
            if value + COLUMN_HORIZONTAL_TOLERANCE > observedLetter.boundingBox.midX &&
                value - COLUMN_HORIZONTAL_TOLERANCE < observedLetter.boundingBox.midX {
                return index
            } else {
                index += 1
            }
        }
        print("Unable to find closest column for observation: \(observedLetter)")
        return -1
    }

    private func printGrid() {
        
        for row in grid {
            for column in row {
                print(column + " ")
            }
            print("\n")
        }
    }
    
    private func convertGridToBananaGrid() -> BananaGrid? {
        
        var bananaTiles = [[BananaTile]]()
        
        for row in grid {
            var newTileRow = [BananaTile]()
            for element in row {
                newTileRow.append(BananaTile(letter: element))
            }
            bananaTiles.append(newTileRow)
        }
        
        return BananaGrid(bananaTiles: bananaTiles)
    }
}

extension VNRecognizedTextObservation {
    func topCandidate() -> String {
        if let text = self.topCandidates(1).first?.string {
            return text
        } else {
            return ""
        }
    }
}
