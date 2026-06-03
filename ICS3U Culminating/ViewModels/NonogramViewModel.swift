//
//  NonogramViewModel.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation

/**
 The View Model acts as the intermediary between the Nonogram Model (data)
 and the SwiftUI Views (the visual interface).
 
 It uses the @Observable macro so that any SwiftUI view using an instance
 of this class will automatically update whenever the puzzle state changes.
 */
@Observable
class NonogramViewModel {
    
    // MARK: - Stored properties
    
    // The current puzzle being played. 
    // This contains the grid, clues, and solution.
    var puzzle: Nonogram
    
    // MARK: - Initializer
    
    /**
     Creates a new view model with a specific puzzle.
     If no puzzle is provided, it defaults to the example 5x5 pattern.
     */
    init(puzzle: Nonogram = Nonogram.example5x5) {
        self.puzzle = puzzle
    }
    
    // MARK: - Functions
    
    /**
     Loads a new puzzle into the view model.
     */
    func loadPuzzle(_ newPuzzle: Nonogram) {
        self.puzzle = newPuzzle
    }
    
    /**
     Toggles the state of a specific cell in the grid.
     
     In a Nonogram game, the cycle for a cell usually goes:
     empty -> filled -> marked (X) -> empty
     
     - Parameters:
       - row: The vertical index of the cell
       - column: The horizontal index of the cell
     */
    func toggleCell(atRow row: Int, atColumn column: Int) {
        // Ensure the coordinates are within the valid range of the grid
        // to prevent the app from crashing.
        if row >= 0 && row < puzzle.grid.count {
            if column >= 0 && column < puzzle.grid[row].count {
                
                // Get the current state of the cell
                let currentState: CellState = puzzle.grid[row][column]
                
                // Determine the next state based on the current one
                var nextState: CellState = .empty
                
                if currentState == .empty {
                    nextState = .filled
                } else if currentState == .filled {
                    nextState = .marked
                } else if currentState == .marked {
                    nextState = .empty
                }
                
                // Update the grid with the new state
                puzzle.grid[row][column] = nextState
            }
        }
    }
    
    /**
     Resets the entire grid to the 'empty' state so the player can start over.
     */
    func resetPuzzle() {
        var newGrid: [[CellState]] = []
        
        // Loop through every row in the current grid
        for row in puzzle.grid {
            var newRow: [CellState] = []
            
            // Loop through every cell in that row
            for _ in row {
                // Add an 'empty' state for every cell
                newRow.append(.empty)
            }
            
            // Add the newly created empty row to our new grid
            newGrid.append(newRow)
        }
        
        // Replace the old grid with our fresh, empty one
        puzzle.grid = newGrid
    }
}
