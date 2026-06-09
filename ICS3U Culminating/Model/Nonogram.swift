//
//  Nonogram.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation

/**
 DATA MODEL: Nonogram
 --------------------
 This structure demonstrates different types of arrays.
 */
struct Nonogram: Identifiable {
    
    // MARK: - Stored properties
    
    let id = UUID() // Unique identifier
    let name: String // Simple String data
    
    /**
     [2D ARRAY EXAMPLE]
     'grid' is a 2D Array of custom types.
     It stores the user's progress. Think of it as a table with rows and columns.
     */
    var grid: [[CellState]]
    
    /**
     [2D ARRAY EXAMPLE]
     'solution' is a 2D Array of Booleans.
     It represents the target image (true = pixel, false = empty).
     */
    let solution: [[Bool]]
    
    /**
     [NESTED ARRAY EXAMPLE]
     These are arrays containing arrays of integers.
     They store the logic numbers for the rows and columns.
     */
    let rowClues: [[Int]]
    let columnClues: [[Int]]
    
    // MARK: - Initializer
    
    init(name: String, solution: [[Bool]]) {
        self.name = name
        self.solution = solution
        
        let rowCount: Int = solution.count
        var maxColumnCount: Int = 0
        for row in solution {
            if row.count > maxColumnCount {
                maxColumnCount = row.count
            }
        }
        
        // POPULATING A 2D ARRAY
        var newGrid: [[CellState]] = []
        for _ in 0..<rowCount {
            var gridRow: [CellState] = []
            for _ in 0..<maxColumnCount {
                gridRow.append(.empty)
            }
            newGrid.append(gridRow)
        }
        self.grid = newGrid
        
        self.rowClues = Nonogram.calculateRowClues(for: solution)
        self.columnClues = Nonogram.calculateColumnClues(for: solution, maxColumns: maxColumnCount)
    }
    
    // MARK: - Array Traversal
    
    /**
     isSolved: Traversing the 2D array
     Uses nested loops to visit every index in the 2D grid list.
     */
    var isSolved: Bool {
        let checkRowCount = min(grid.count, solution.count)
        for rowIndex in 0..<checkRowCount {
            for columnIndex in 0..<grid[rowIndex].count {
                if (grid[rowIndex][columnIndex] == .filled) != solution[rowIndex][columnIndex] {
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: - Array Logic
    
    private static func calculateRowClues(for solution: [[Bool]]) -> [[Int]] {
        var allRowClues: [[Int]] = []
        for row in solution {
            var clues: [Int] = []
            var currentRun: Int = 0
            for isFilled in row {
                if isFilled {
                    currentRun += 1
                } else if currentRun > 0 {
                    clues.append(currentRun) // Appending data to a 1D array
                    currentRun = 0
                }
            }
            if currentRun > 0 { clues.append(currentRun) }
            if clues.isEmpty { clues.append(0) }
            allRowClues.append(clues) // Adding a 1D array to a 2D array
        }
        return allRowClues
    }
    
    private static func calculateColumnClues(for solution: [[Bool]], maxColumns: Int) -> [[Int]] {
        var allColumnClues: [[Int]] = []
        let rowCount = solution.count
        for columnIndex in 0..<maxColumns {
            var clues: [Int] = []
            var currentRun: Int = 0
            for rowIndex in 0..<rowCount {
                let row = solution[rowIndex]
                if columnIndex < row.count {
                    if row[columnIndex] {
                        currentRun += 1
                    } else if currentRun > 0 {
                        clues.append(currentRun)
                        currentRun = 0
                    }
                } else if currentRun > 0 {
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

// MARK: - Raw Puzzle Data (Broken into smaller pieces)

/**
 RAW DATA ARRAYS
 ---------------
 Instead of one massive list, we break every pattern into its own 2D array variable.
 This makes it much easier to explain individual shapes like "The Heart".
 */
struct RawPuzzleData {
    
    // 5x5 DATA
    static let heart: [[Bool]] = [
        [false, true, false, true, false],
        [true, true, true, true, true],
        [true, true, true, true, true],
        [false, true, true, true, false],
        [false, false, true, false, false]
    ]
    
    static let arrow: [[Bool]] = [
        [false, false, true, false, false],
        [false, true, true, true, false],
        [true, true, true, true, true],
        [false, false, true, false, false],
        [false, false, true, false, false]
    ]
    
    static let letterX: [[Bool]] = [
        [true, false, false, false, true],
        [false, true, false, true, false],
        [false, false, true, false, false],
        [false, true, false, true, false],
        [true, false, false, false, true]
    ]
    
    static let checkmark: [[Bool]] = [
        [false, false, false, false, true],
        [false, false, false, true, true],
        [true, false, true, true, false],
        [false, true, true, false, false],
        [false, false, false, false, false]
    ]
    
    // 15x15 DATA (Example)
    static let house: [[Bool]] = [
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
    ]
    
    // Add more here as needed...
}

// MARK: - Puzzle Library (Assembled from raw data)

struct PuzzleLibrary {
    /**
     [1D ARRAY EXAMPLE]
     'easyPuzzles' is a 1D Array of 'Nonogram' objects.
     */
    static let easyPuzzles: [Nonogram] = [
        Nonogram(name: "Heart", solution: RawPuzzleData.heart),
        Nonogram(name: "Arrow", solution: RawPuzzleData.arrow),
        Nonogram(name: "Letter X", solution: RawPuzzleData.letterX),
        Nonogram(name: "Checkmark", solution: RawPuzzleData.checkmark)
    ]
    
    static let mediumPuzzles: [Nonogram] = [
        Nonogram(name: "Smiley", solution: [[false, false, true, true, true, true, true, true, false, false],[false, true, false, false, false, false, false, false, true, false],[true, false, true, false, false, false, false, true, false, true],[true, false, false, false, false, false, false, false, false, true],[true, false, true, false, false, false, false, true, false, true],[true, false, false, true, true, true, true, false, false, true],[true, false, false, false, false, false, false, false, false, true],[false, true, false, false, false, false, false, false, true, false],[false, false, true, true, true, true, true, true, false, false],[false, false, false, false, false, false, false, false, false, false]])
    ]
    
    static let hardPuzzles: [Nonogram] = [
        Nonogram(name: "House", solution: RawPuzzleData.house)
    ]
}
