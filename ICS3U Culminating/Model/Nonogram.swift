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
struct Nonogram: Identifiable {
    
    // MARK: - Stored properties
    
    // Unique identifier so SwiftUI can distinguish different puzzle instances
    let id = UUID()
    
    // The name of the puzzle
    let name: String
    
    // The current state of the grid as the user plays.
    var grid: [[CellState]]
    
    // The correct solution for the puzzle. 
    let solution: [[Bool]]
    
    // The numerical clues displayed for each row.
    let rowClues: [[Int]]
    
    // The numerical clues displayed for each column.
    let columnClues: [[Int]]
    
    // MARK: - Initializer
    
    /**
     Initializes a new Nonogram puzzle with a name and a given solution.
     Includes extreme safety checks to ensure the grid is perfectly formed.
     */
    init(name: String, solution: [[Bool]]) {
        self.name = name
        self.solution = solution
        
        // 1. Determine the maximum dimensions safely (handles "jagged" arrays)
        let rowCount: Int = solution.count
        var maxColumnCount: Int = 0
        for row in solution {
            if row.count > maxColumnCount {
                maxColumnCount = row.count
            }
        }
        
        // 2. Initialize the playable grid as entirely 'empty'
        // We ensure every row has the exact same number of columns to prevent indexing crashes
        var newGrid: [[CellState]] = []
        for _ in 0..<rowCount {
            var gridRow: [CellState] = []
            for _ in 0..<maxColumnCount {
                gridRow.append(.empty)
            }
            newGrid.append(gridRow)
        }
        self.grid = newGrid
        
        // 3. Automatically derive clues with safety boundary checks
        self.rowClues = Nonogram.calculateRowClues(for: solution)
        self.columnClues = Nonogram.calculateColumnClues(for: solution, maxColumns: maxColumnCount)
    }
    
    // MARK: - Computed properties
    
    /**
     Checks if the player has correctly solved the puzzle.
     Uses defensive indexing to prevent crashes.
     */
    var isSolved: Bool {
        let checkRowCount = min(grid.count, solution.count)
        for rowIndex in 0..<checkRowCount {
            let gridRow = grid[rowIndex]
            let solutionRow = solution[rowIndex]
            let checkColCount = min(gridRow.count, solutionRow.count)
            
            for columnIndex in 0..<checkColCount {
                let cellIsFilled: Bool = gridRow[columnIndex] == .filled
                let solutionIsFilled: Bool = solutionRow[columnIndex]
                
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
     */
    private static func calculateRowClues(for solution: [[Bool]]) -> [[Int]] {
        var allRowClues: [[Int]] = []
        for row in solution {
            var clues: [Int] = []
            var currentRun: Int = 0
            for isFilled in row {
                if isFilled {
                    currentRun += 1
                } else if currentRun > 0 {
                    clues.append(currentRun)
                    currentRun = 0
                }
            }
            if currentRun > 0 { clues.append(currentRun) }
            if clues.isEmpty { clues.append(0) }
            allRowClues.append(clues)
        }
        return allRowClues
    }
    
    /**
     Calculates clues for every column. 
     Uses 'maxColumns' and safety checks to prevent index-out-of-bounds.
     */
    private static func calculateColumnClues(for solution: [[Bool]], maxColumns: Int) -> [[Int]] {
        var allColumnClues: [[Int]] = []
        let rowCount = solution.count
        
        for columnIndex in 0..<maxColumns {
            var clues: [Int] = []
            var currentRun: Int = 0
            for rowIndex in 0..<rowCount {
                let row = solution[rowIndex]
                
                // Safety check: Does this row actually have this column?
                if columnIndex < row.count {
                    if row[columnIndex] {
                        currentRun += 1
                    } else if currentRun > 0 {
                        clues.append(currentRun)
                        currentRun = 0
                    }
                } else if currentRun > 0 {
                    // Treat missing columns in short rows as 'false'
                    clues.append(currentRun)
                    currentRun = 0
                }
            }
            if currentRun > 0 { clues.append(currentRun) }
            if clues.isEmpty { clues.append(0) }
            allColumnClues.append(clues)
        }
        return allColumnClues
    }
}

// MARK: - Puzzle Library

struct PuzzleLibrary {
    
    // EASY (5x5)
    static let easyPuzzles: [Nonogram] = [
        Nonogram(name: "Heart", solution: [
            [false, true, false, true, false],
            [true, true, true, true, true],
            [true, true, true, true, true],
            [false, true, true, true, false],
            [false, false, true, false, false]
        ]),
        Nonogram(name: "Arrow", solution: [
            [false, false, true, false, false],
            [false, true, true, true, false],
            [true, true, true, true, true],
            [false, false, true, false, false],
            [false, false, true, false, false]
        ]),
        Nonogram(name: "Letter X", solution: [
            [true, false, false, false, true],
            [false, true, false, true, false],
            [false, false, true, false, false],
            [false, true, false, true, false],
            [true, false, false, false, true]
        ]),
        Nonogram(name: "Checkmark", solution: [
            [false, false, false, false, true],
            [false, false, false, true, true],
            [true, false, true, true, false],
            [false, true, true, false, false],
            [false, false, false, false, false]
        ]),
        Nonogram(name: "Small Square", solution: [
            [true, true, true, true, true],
            [true, false, false, false, true],
            [true, false, false, false, true],
            [true, false, false, false, true],
            [true, true, true, true, true]
        ]),
        Nonogram(name: "Cross", solution: [
            [false, false, true, false, false],
            [false, false, true, false, false],
            [true, true, true, true, true],
            [false, false, true, false, false],
            [false, false, true, false, false]
        ])
    ]
    
    // MEDIUM (10x10)
    static let mediumPuzzles: [Nonogram] = [
        Nonogram(name: "Smiley", solution: [
            [false, false, true, true, true, true, true, true, false, false],
            [false, true, false, false, false, false, false, false, true, false],
            [true, false, true, false, false, false, false, true, false, true],
            [true, false, false, false, false, false, false, false, false, true],
            [true, false, true, false, false, false, false, true, false, true],
            [true, false, false, true, true, true, true, false, false, true],
            [true, false, false, false, false, false, false, false, false, true],
            [false, true, false, false, false, false, false, false, true, false],
            [false, false, true, true, true, true, true, true, false, false],
            [false, false, false, false, false, false, false, false, false, false]
        ]),
        Nonogram(name: "Invader", solution: [
            [false, false, true, false, false, false, false, true, false, false],
            [false, false, false, true, false, false, true, false, false, false],
            [false, false, true, true, true, true, true, true, false, false],
            [false, true, true, false, true, true, false, true, true, false],
            [true, true, true, true, true, true, true, true, true, true],
            [true, false, true, true, true, true, true, true, false, true],
            [true, false, true, false, false, false, false, true, false, true],
            [false, false, false, true, true, true, true, false, false, false],
            [false, false, false, false, false, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false]
        ]),
        Nonogram(name: "Diamond", solution: [
            [false, false, false, false, true, true, false, false, false, false],
            [false, false, false, true, true, true, true, false, false, false],
            [false, false, true, true, true, true, true, true, false, false],
            [false, true, true, true, true, true, true, true, true, false],
            [true, true, true, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, true, true, true, true],
            [false, true, true, true, true, true, true, true, true, false],
            [false, false, true, true, true, true, true, true, false, false],
            [false, false, false, true, true, true, true, false, false, false],
            [false, false, false, false, true, true, false, false, false, false]
        ]),
        Nonogram(name: "Tree", solution: [
            [false, false, false, false, true, true, false, false, false, false],
            [false, false, false, true, true, true, true, false, false, false],
            [false, false, true, true, true, true, true, true, false, false],
            [false, true, true, true, true, true, true, true, true, false],
            [false, false, true, true, true, true, true, true, false, false],
            [false, true, true, true, true, true, true, true, true, false],
            [true, true, true, true, true, true, true, true, true, true],
            [false, false, false, true, true, true, true, false, false, false],
            [false, false, false, true, true, true, true, false, false, false],
            [false, false, false, true, true, true, true, false, false, false]
        ]),
        Nonogram(name: "Plus", solution: [
            [false, false, false, false, true, true, false, false, false, false],
            [false, false, false, false, true, true, false, false, false, false],
            [false, false, false, false, true, true, false, false, false, false],
            [false, false, false, false, true, true, false, false, false, false],
            [true, true, true, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, true, true, true, true],
            [false, false, false, false, true, true, false, false, false, false],
            [false, false, false, false, true, true, false, false, false, false],
            [false, false, false, false, true, true, false, false, false, false],
            [false, false, false, false, true, true, false, false, false, false]
        ]),
        Nonogram(name: "Frames", solution: [
            [true, true, true, true, true, true, true, true, true, true],
            [true, false, false, false, false, false, false, false, false, true],
            [true, false, true, true, true, true, true, true, false, true],
            [true, false, true, false, false, false, false, true, false, true],
            [true, false, true, false, false, false, false, true, false, true],
            [true, false, true, false, false, false, false, true, false, true],
            [true, false, true, false, false, false, false, true, false, true],
            [true, false, true, true, true, true, true, true, false, true],
            [true, false, false, false, false, false, false, false, false, true],
            [true, true, true, true, true, true, true, true, true, true]
        ])
    ]
    
    // HARD (15x15)
    static let hardPuzzles: [Nonogram] = [
        Nonogram(name: "House", solution: [
            [false, false, false, false, false, false, false, true, false, false, false, false, false, false, false],
            [false, false, false, false, false, false, true, true, true, false, false, false, false, false, false],
            [false, false, false, false, false, true, true, true, true, true, false, false, false, false, false],
            [false, false, false, false, true, true, true, true, true, true, true, false, false, false, false],
            [false, false, false, true, true, true, true, true, true, true, true, true, false, false, false],
            [false, false, true, true, true, true, true, true, true, true, true, true, true, false, false],
            [false, true, true, true, true, true, true, true, true, true, true, true, true, true, false],
            [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],
            [false, true, true, true, true, true, true, true, true, true, true, true, true, true, false],
            [false, true, true, false, false, false, true, true, true, false, false, false, true, true, false],
            [false, true, true, false, false, false, true, true, true, false, false, false, true, true, false],
            [false, true, true, true, true, true, true, true, true, true, true, true, true, true, false],
            [false, true, true, false, false, false, true, true, true, false, false, false, true, true, false],
            [false, true, true, false, false, false, true, true, true, false, false, false, true, true, false],
            [false, true, true, true, true, true, true, true, true, true, true, true, true, true, false]
        ]),
        Nonogram(name: "Robot", solution: [
            [false, false, false, false, true, true, true, true, true, false, false, false, false, false, false],
            [false, false, false, false, true, true, true, true, true, false, false, false, false, false, false],
            [false, false, false, false, true, false, true, false, true, false, false, false, false, false, false],
            [false, false, false, false, true, true, true, true, true, false, false, false, false, false, false],
            [false, false, false, true, true, true, true, true, true, true, false, false, false, false, false],
            [false, true, true, true, true, true, true, true, true, true, true, true, false, false, false],
            [false, true, false, true, true, true, true, true, true, true, false, true, false, false, false],
            [false, true, false, true, true, true, true, true, true, true, false, true, false, false, false],
            [false, true, true, true, true, true, true, true, true, true, true, true, false, false, false],
            [false, false, false, true, true, true, true, true, true, true, false, false, false, false, false],
            [false, false, false, true, true, true, true, true, true, true, false, false, false, false, false],
            [false, false, false, true, true, false, false, false, true, true, false, false, false, false, false],
            [false, false, false, true, true, false, false, false, true, true, false, false, false, false, false],
            [false, false, false, true, true, false, false, false, true, true, false, false, false, false, false],
            [false, false, true, true, true, false, false, false, true, true, true, false, false, false, false]
        ]),
        Nonogram(name: "Landscape", solution: [
            [false, false, false, false, false, false, false, false, false, false, false, true, true, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, true, true, true, false],
            [false, false, false, false, false, false, false, false, false, true, true, true, true, true, true],
            [false, false, false, false, false, false, false, false, true, true, true, true, true, true, true],
            [false, false, false, false, true, false, false, true, true, true, true, true, true, true, true],
            [false, false, false, true, true, true, false, true, true, true, true, true, true, true, true],
            [false, false, true, true, true, true, true, true, true, true, true, true, true, true, true],
            [false, true, true, true, true, true, true, true, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],
            [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
            [false, true, true, true, true, true, true, true, true, true, true, true, true, true, false],
            [false, true, true, true, true, true, true, true, true, true, true, true, true, true, false],
            [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
            [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
        ]),
        Nonogram(name: "Cat", solution: [
            [true, false, false, false, false, false, false, false, false, false, false, false, false, false, true],
            [true, true, false, false, false, false, false, false, false, false, false, false, false, true, true],
            [true, true, true, false, false, false, false, false, false, false, false, false, true, true, true],
            [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],
            [true, true, false, false, true, true, true, true, true, true, true, false, false, true, true],
            [true, true, false, false, true, false, true, true, true, false, true, false, false, true, true],
            [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],
            [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],
            [true, true, true, true, true, false, false, false, false, false, true, true, true, true, true],
            [false, true, true, true, true, true, true, true, true, true, true, true, true, true, false],
            [false, false, true, true, true, true, true, true, true, true, true, true, true, false, false],
            [false, false, false, true, true, true, true, true, true, true, true, true, false, false, false],
            [false, false, false, false, true, true, true, true, true, true, true, false, false, false, false],
            [false, false, false, false, false, true, true, true, true, true, false, false, false, false, false]
        ]),
        Nonogram(name: "Big Heart", solution: [
            [false, false, true, true, false, false, false, false, false, true, true, false, false, false, false],
            [false, true, true, true, true, false, false, false, true, true, true, true, false, false, false],
            [true, true, true, true, true, true, false, true, true, true, true, true, true, false, false],
            [true, true, true, true, true, true, true, true, true, true, true, true, true, false, false],
            [true, true, true, true, true, true, true, true, true, true, true, true, true, false, false],
            [false, true, true, true, true, true, true, true, true, true, true, true, false, false, false],
            [false, false, true, true, true, true, true, true, true, true, true, false, false, false, false],
            [false, false, false, true, true, true, true, true, true, true, false, false, false, false, false],
            [false, false, false, false, true, true, true, true, true, false, false, false, false, false, false],
            [false, false, false, false, false, true, true, true, false, false, false, false, false, false],
            [false, false, false, false, false, false, true, false, false, false, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
        ]),
        Nonogram(name: "Checkboard", solution: [
            [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true],
            [false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],
            [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true],
            [false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],
            [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true],
            [false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],
            [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true],
            [false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],
            [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true],
            [false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],
            [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true],
            [false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],
            [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true],
            [false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],
            [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true]
        ])
    ]
}
