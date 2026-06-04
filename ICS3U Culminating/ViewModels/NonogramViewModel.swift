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
 */
@Observable
class NonogramViewModel {
    
    // MARK: - Stored properties
    
    // The current puzzle being played. 
    var puzzle: Nonogram
    
    // Tracks the current difficulty level
    var difficulty: String = "Easy"
    
    // Tracks the name of the selected puzzle
    var selectedPuzzleName: String = "Heart"
    
    // MARK: - Computed properties
    
    // Returns the list of puzzles for the current difficulty
    var currentPuzzleList: [Nonogram] {
        if difficulty == "Easy" {
            return PuzzleLibrary.easyPuzzles
        } else if difficulty == "Medium" {
            return PuzzleLibrary.mediumPuzzles
        } else {
            return PuzzleLibrary.hardPuzzles
        }
    }
    
    // MARK: - Initializer
    
    /**
     Creates a new view model and starts with the first Easy puzzle.
     */
    init() {
        self.puzzle = PuzzleLibrary.easyPuzzles[0]
        self.selectedPuzzleName = self.puzzle.name
    }
    
    // MARK: - Functions
    
    /**
     Updates the difficulty and loads the first puzzle of that difficulty.
     */
    func changeDifficulty(to newDifficulty: String) {
        self.difficulty = newDifficulty
        
        // When difficulty changes, load the first puzzle in the new list
        let firstPuzzle = currentPuzzleList[0]
        loadPuzzle(firstPuzzle)
    }
    
    /**
     Loads a specific puzzle by its name within the current difficulty list.
     */
    func changePuzzle(to puzzleName: String) {
        for puzzle in currentPuzzleList {
            if puzzle.name == puzzleName {
                loadPuzzle(puzzle)
                return
            }
        }
    }
    
    /**
     Loads a new puzzle instance and updates the tracked name.
     */
    func loadPuzzle(_ newPuzzle: Nonogram) {
        self.puzzle = newPuzzle
        self.selectedPuzzleName = newPuzzle.name
    }
    
    /**
     Toggles the state of a specific cell in the grid.
     */
    func toggleCell(atRow row: Int, atColumn column: Int) {
        if row >= 0 && row < puzzle.grid.count {
            if column >= 0 && column < puzzle.grid[row].count {
                let currentState: CellState = puzzle.grid[row][column]
                var nextState: CellState = .empty
                
                if currentState == .empty {
                    nextState = .filled
                } else if currentState == .filled {
                    nextState = .marked
                } else if currentState == .marked {
                    nextState = .empty
                }
                
                puzzle.grid[row][column] = nextState
            }
        }
    }
    
    /**
     Resets the entire grid to the 'empty' state.
     */
    func resetPuzzle() {
        let rowCount = puzzle.grid.count
        let colCount = puzzle.grid.isEmpty ? 0 : puzzle.grid[0].count
        
        var newGrid: [[CellState]] = []
        for _ in 0..<rowCount {
            var newRow: [CellState] = []
            for _ in 0..<colCount {
                newRow.append(.empty)
            }
            newGrid.append(newRow)
        }
        puzzle.grid = newGrid
    }
}
