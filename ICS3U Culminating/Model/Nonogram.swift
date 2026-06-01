//
//  Nonogram.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation

/**
 The Nonogram structure manages the state and logic of a single puzzle.
 It handles the user's progress (grid), the target image (solution),
 and automatically calculates the numerical clues for rows and columns.
 */
struct Nonogram {
    
    // MARK: - Stored properties
    
    // The current state of the grid as the user plays.
    // This is a 2D array where grid[row][column] gives the state of a cell.
    var grid: [[CellState]]
    
    // The correct solution for the puzzle. 
    // 'true' means the cell should be filled, 'false' means it should be empty.
    let solution: [[Bool]]
    
    // The numerical clues displayed for each row (e.g., [2, 1] means a block of 2 and a block of 1).
    let rowClues: [[Int]]
    
    // The numerical clues displayed for each column.
    let columnClues: [[Int]]
    
    // MARK: - Initializer
    
    /**
     Initializes a new Nonogram puzzle with a given solution.
     The grid is automatically created with 'empty' cells, and clues are calculated.
     */
    init(solution: [[Bool]]) {
        self.solution = solution
        
        // Determine dimensions based on the solution grid
        let rowCount: Int = solution.count
        let columnCount: Int = solution.isEmpty ? 0 : solution[0].count
        
        // Initialize the playable grid as entirely 'empty'
        var newGrid: [[CellState]] = []
        for _ in 0..<rowCount {
            var row: [CellState] = []
            for _ in 0..<columnCount {
                row.append(.empty)
            }
            newGrid.append(row)
        }
        self.grid = newGrid
        
        // Automatically derive clues from the solution so level creators don't have to provide them manually
        self.rowClues = Nonogram.calculateRowClues(for: solution)
        self.columnClues = Nonogram.calculateColumnClues(for: solution)
    }
    
    // MARK: - Computed properties
    
    /**
     Checks if the player has correctly solved the puzzle.
     The puzzle is solved if every '.filled' cell in the grid matches a 'true' in the solution,
     and every 'true' in the solution is '.filled' in the grid.
     */
    var isSolved: Bool {
        for rowIndex in 0..<solution.count {
            for columnIndex in 0..<solution[rowIndex].count {
                let cellIsFilled: Bool = grid[rowIndex][columnIndex] == .filled
                let solutionIsFilled: Bool = solution[rowIndex][columnIndex]
                
                // If the player's cell state doesn't match the required solution state, they haven't won yet
                if cellIsFilled != solutionIsFilled {
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: - Functions
    
    /**
     Calculates clues for every row in the solution.
     A "clue" is an array of integers representing consecutive runs of 'true' values.
     */
    private static func calculateRowClues(for solution: [[Bool]]) -> [[Int]] {
        var allRowClues: [[Int]] = []
        
        for row in solution {
            var clues: [Int] = []
            var currentRun: Int = 0
            
            for isFilled in row {
                if isFilled {
                    // We found a filled cell, so increase the current run count
                    currentRun += 1
                } else {
                    // We hit an empty cell. If we were counting a run, save it as a clue.
                    if currentRun > 0 {
                        clues.append(currentRun)
                        currentRun = 0
                    }
                }
            }
            
            // If the row ended while we were still counting a run, save it.
            if currentRun > 0 {
                clues.append(currentRun)
            }
            
            // Standard nonograms show a '0' for completely empty rows.
            if clues.isEmpty {
                clues.append(0)
            }
            
            allRowClues.append(clues)
        }
        
        return allRowClues
    }
    
    /**
     Calculates clues for every column in the solution.
     Works similarly to row calculation but iterates through column indices first.
     */
    private static func calculateColumnClues(for solution: [[Bool]]) -> [[Int]] {
        guard !solution.isEmpty else { return [] }
        
        let rowCount: Int = solution.count
        let columnCount: Int = solution[0].count
        var allColumnClues: [[Int]] = []
        
        for columnIndex in 0..<columnCount {
            var clues: [Int] = []
            var currentRun: Int = 0
            
            for rowIndex in 0..<rowCount {
                let isFilled: Bool = solution[rowIndex][columnIndex]
                
                if isFilled {
                    currentRun += 1
                } else {
                    if currentRun > 0 {
                        clues.append(currentRun)
                        currentRun = 0
                    }
                }
            }
            
            if currentRun > 0 {
                clues.append(currentRun)
            }
            
            if clues.isEmpty {
                clues.append(0)
            }
            
            allColumnClues.append(clues)
        }
        
        return allColumnClues
    }
}

// MARK: - Example puzzles

extension Nonogram {
    // A simple 5x5 pattern for testing
    static let example5x5 = Nonogram(solution: [
        [false, true, true, true, false],
        [true, true, false, true, true],
        [true, false, false, false, true],
        [true, true, false, true, true],
        [false, true, true, true, false]
    ])
    
    // A larger 10x10 pattern (resembling a circle)
    static let example10x10 = Nonogram(solution: [
        [false, false, false, true, true, true, true, false, false, false],
        [false, false, true, true, true, true, true, true, false, false],
        [false, true, true, false, false, false, false, true, true, false],
        [true, true, false, false, false, false, false, false, true, true],
        [true, true, false, false, false, false, false, false, true, true],
        [true, true, false, false, false, false, false, false, true, true],
        [true, true, false, false, false, false, false, false, true, true],
        [false, true, true, false, false, false, false, true, true, false],
        [false, false, true, true, true, true, true, true, false, false],
        [false, false, false, true, true, true, true, false, false, false]
    ])
}
