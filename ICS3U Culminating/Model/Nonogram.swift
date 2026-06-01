//
//  Nonogram.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation

struct Nonogram {
    
    // MARK: - Stored properties
    
    // The current state of the grid being played by the user
    var grid: [[CellState]]
    
    // The correct solution for the puzzle
    let solution: [[Bool]]
    
    // The clues for each row
    let rowClues: [[Int]]
    
    // The clues for each column
    let columnClues: [[Int]]
    
    // MARK: - Initializer
    
    init(solution: [[Bool]]) {
        self.solution = solution
        
        // Initialize the grid with empty cells, matching the dimensions of the solution
        let rowCount: Int = solution.count
        let columnCount: Int = solution.isEmpty ? 0 : solution[0].count
        
        var newGrid: [[CellState]] = []
        for _ in 0..<rowCount {
            var row: [CellState] = []
            for _ in 0..<columnCount {
                row.append(.empty)
            }
            newGrid.append(row)
        }
        self.grid = newGrid
        
        // Calculate clues from the solution
        self.rowClues = Nonogram.calculateRowClues(for: solution)
        self.columnClues = Nonogram.calculateColumnClues(for: solution)
    }
    
    // MARK: - Computed properties
    
    // Check if the current grid matches the solution
    var isSolved: Bool {
        for rowIndex in 0..<solution.count {
            for columnIndex in 0..<solution[rowIndex].count {
                let cellIsFilled: Bool = grid[rowIndex][columnIndex] == .filled
                let solutionIsFilled: Bool = solution[rowIndex][columnIndex]
                
                if cellIsFilled != solutionIsFilled {
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: - Functions
    
    // Calculate row clues based on the solution grid
    private static func calculateRowClues(for solution: [[Bool]]) -> [[Int]] {
        var allRowClues: [[Int]] = []
        
        for row in solution {
            var clues: [Int] = []
            var currentRun: Int = 0
            
            for isFilled in row {
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
            
            // If the row is empty, we should still show a "0" or an empty clue set
            // Nonograms usually show a single 0 for empty rows/columns
            if clues.isEmpty {
                clues.append(0)
            }
            
            allRowClues.append(clues)
        }
        
        return allRowClues
    }
    
    // Calculate column clues based on the solution grid
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
    static let example5x5 = Nonogram(solution: [
        [false, true, true, true, false],
        [true, true, false, true, true],
        [true, false, false, false, true],
        [true, true, false, true, true],
        [false, true, true, true, false]
    ])
    
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
