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
 This structure demonstrates advanced use of ARRAYS and NESTED LOOPS.
 A Nonogram is essentially a collection of data stored in grids.
 */
struct Nonogram: Identifiable {
    
    // MARK: - Stored properties (ARRAY DECLARATION)
    
    // A unique ID to help SwiftUI track this specific puzzle object.
    let id = UUID()
    
    // String data to name the puzzle.
    let name: String
    
    /**
     1. THE PLAYABLE GRID (2D ARRAY DECLARATION)
     ------------------------------------------
     This is a "List of Lists". The outer array represents ROWS, 
     and the inner arrays represent individual CELLS in those rows.
     Type: [[CellState]] (An array containing arrays of CellState values).
     */
    var grid: [[CellState]]
    
    /**
     2. THE ANSWER KEY (2D ARRAY DECLARATION)
     ----------------------------------------
     A 2D array of Booleans that tells us exactly which cells MUST be filled.
     'true' = pixel, 'false' = blank.
     */
    let solution: [[Bool]]
    
    /**
     3. THE CLUES (NESTED ARRAY DECLARATION)
     ---------------------------------------
     Since a single row might have multiple clues (like [2, 1, 3]), 
     we need an array of arrays to store them all.
     */
    let rowClues: [[Int]]
    let columnClues: [[Int]]
    
    // MARK: - Initializer (ARRAY INITIALIZATION & POPULATION)
    
    init(name: String, solution: [[Bool]]) {
        self.name = name
        self.solution = solution
        
        // STEP 1: Determine Dimensions.
        // Array count property is used to find how many items are in the list.
        let rowCount: Int = solution.count
        var maxColumnCount: Int = 0
        for row in solution {
            // Using the .count property of an array inside a loop
            if row.count > maxColumnCount {
                maxColumnCount = row.count
            }
        }
        
        /**
         STEP 2: ARRAY INITIALIZATION
         ----------------------------
         We initialize 'newGrid' as an empty 2D array using the '[]' syntax.
         This creates the container, but it doesn't have any data yet.
         */
        var newGrid: [[CellState]] = []
        
        /**
         STEP 3: ARRAY POPULATION (NESTED LOOPS)
         ---------------------------------------
         We use two loops to fill our empty 2D array.
         This ensures every cell exists before the user tries to click it.
         */
        for _ in 0..<rowCount {
            // 3a. Initialize a single "Row" array (1D array)
            var gridRow: [CellState] = []
            
            for _ in 0..<maxColumnCount {
                // 3b. Add data to the 1D array using .append()
                gridRow.append(.empty)
            }
            
            // 3c. Add the finished 1D row to the master 2D 'newGrid' array
            newGrid.append(gridRow)
        }
        
        // Final Assignment: The fully populated array is saved to the struct.
        self.grid = newGrid
        
        // We populate the clue arrays by calling our processing functions below.
        self.rowClues = Nonogram.calculateRowClues(for: solution)
        self.columnClues = Nonogram.calculateColumnClues(for: solution, maxColumns: maxColumnCount)
    }
    
    // MARK: - Computed properties (ARRAY TRAVERSAL)
    
    /**
     isSolved: ARRAY TRAVERSAL LOGIC
     -------------------------------
     To check the win condition, we must "traverse" (walk through) two 2D arrays 
     simultaneously and compare their values at the exact same row/column indices.
     */
    var isSolved: Bool {
        // We loop through the master list (rows)...
        for rowIndex in 0..<grid.count {
            // ...then we loop through the items in that specific row (columns).
            for columnIndex in 0..<grid[rowIndex].count {
                
                // ACCESSING DATA: We use grid[row][column] to find a specific value.
                let userFilled = grid[rowIndex][columnIndex] == .filled
                let solutionTarget = solution[rowIndex][columnIndex]
                
                // Logic Comparison: If any pair of cells don't match, the puzzle isn't solve.
                if userFilled != solutionTarget {
                    return false
                }
            }
        }
        return true // Traversal complete with zero mismatches!
    }
    
    // MARK: - Clue Calculation Functions (ARRAY PROCESSING)
    
    private static func calculateRowClues(for solution: [[Bool]]) -> [[Int]] {
        // Declaring a 2D array for result storage.
        var allRowClues: [[Int]] = []
        
        for row in solution {
            // Declaring a 1D array to hold numbers for this specific row.
            var clues: [Int] = []
            var currentRun: Int = 0
            
            for isFilled in row {
                if isFilled {
                    currentRun += 1
                } else if currentRun > 0 {
                    // Populating the 1D clues array.
                    clues.append(currentRun)
                    currentRun = 0
                }
            }
            if currentRun > 0 { clues.append(currentRun) }
            if clues.isEmpty { clues.append(0) }
            
            // Populating the 2D master clues array.
            allRowClues.append(clues)
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

// MARK: - Puzzle Library (ARRAY OF OBJECTS)

struct PuzzleLibrary {
    
    /**
     static let easyPuzzles: [Nonogram]
     This is a 1D Array containing CUSTOM OBJECTS.
     It acts as the primary data source for the application's level selection.
     */
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
    
    // The same logic applies to mediumPuzzles and hardPuzzles arrays below...
    static let mediumPuzzles: [Nonogram] = [
        Nonogram(name: "Smiley", solution: [[false, false, true, true, true, true, true, true, false, false],[false, true, false, false, false, false, false, false, true, false],[true, false, true, false, false, false, false, true, false, true],[true, false, false, false, false, false, false, false, false, true],[true, false, true, false, false, false, false, true, false, true],[true, false, false, true, true, true, true, false, false, true],[true, false, false, false, false, false, false, false, false, true],[false, true, false, false, false, false, false, false, true, false],[false, false, true, true, true, true, true, true, false, false],[false, false, false, false, false, false, false, false, false, false]]),
        Nonogram(name: "Invader", solution: [[false, false, true, false, false, false, false, true, false, false],[false, false, false, true, false, false, true, false, false, false],[false, false, true, true, true, true, true, true, false, false],[false, true, true, false, true, true, false, true, true, false],[true, true, true, true, true, true, true, true, true, true],[true, false, true, true, true, true, true, true, false, true],[true, false, true, false, false, false, false, true, false, true],[false, false, false, true, true, true, true, false, false, false],[false, false, false, false, false, false, false, false, false, false],[false, false, false, false, false, false, false, false, false, false]]),
        Nonogram(name: "Diamond", solution: [[false, false, false, false, true, true, false, false, false, false],[false, false, false, true, true, true, true, false, false, false],[false, false, true, true, true, true, true, true, false, false],[false, true, true, true, true, true, true, true, true, false],[true, true, true, true, true, true, true, true, true, true],[true, true, true, true, true, true, true, true, true, true],[false, true, true, true, true, true, true, true, true, false],[false, false, true, true, true, true, true, true, false, false],[false, false, false, true, true, true, true, false, false, false],[false, false, false, false, true, true, false, false, false, false]]),
        Nonogram(name: "Tree", solution: [[false, false, false, false, true, true, false, false, false, false],[false, false, false, true, true, true, true, false, false, false],[false, false, true, true, true, true, true, true, false, false],[false, true, true, true, true, true, true, true, true, false],[false, false, true, true, true, true, true, true, false, false],[false, true, true, true, true, true, true, true, true, false],[true, true, true, true, true, true, true, true, true, true],[false, false, false, true, true, true, true, false, false, false],[false, false, false, true, true, true, true, false, false, false],[false, false, false, true, true, true, true, false, false, false]]),
        Nonogram(name: "Plus", solution: [[false, false, false, false, true, true, false, false, false, false],[false, false, false, false, true, true, false, false, false, false],[false, false, false, false, true, true, false, false, false, false],[false, false, false, false, true, true, false, false, false, false],[true, true, true, true, true, true, true, true, true, true],[true, true, true, true, true, true, true, true, true, true],[false, false, false, false, true, true, false, false, false, false],[false, false, false, false, true, true, false, false, false, false],[false, false, false, false, true, true, false, false, false, false],[false, false, false, false, true, true, false, false, false, false]]),
        Nonogram(name: "Frames", solution: [[true, true, true, true, true, true, true, true, true, true],[true, false, false, false, false, false, false, false, false, true],[true, false, true, true, true, true, true, true, false, true],[true, false, true, false, false, false, false, true, false, true],[true, false, true, false, false, false, false, true, false, true],[true, false, true, false, false, false, false, true, false, true],[true, false, true, false, false, false, false, true, false, true],[true, false, true, true, true, true, true, true, false, true],[true, false, false, false, false, false, false, false, false, true],[true, true, true, true, true, true, true, true, true, true]])
    ]
    
    static let hardPuzzles: [Nonogram] = [
        Nonogram(name: "House", solution: [[false, false, false, false, false, false, false, true, false, false, false, false, false, false, false],[false, false, false, false, false, false, true, true, true, false, false, false, false, false, false],[false, false, false, false, false, true, true, true, true, true, false, false, false, false, false],[false, false, false, false, true, true, true, true, true, true, true, false, false, false, false],[false, false, false, true, true, true, true, true, true, true, true, true, false, false, false],[false, false, true, true, true, true, true, true, true, true, true, true, true, false, false],[false, true, true, true, true, true, true, true, true, true, true, true, true, true, false],[true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],[false, true, true, true, true, true, true, true, true, true, true, true, true, true, false],[false, true, true, false, false, false, true, true, true, false, false, false, true, true, false],[false, true, true, false, false, false, true, true, true, false, false, false, true, true, false],[false, true, true, true, true, true, true, true, true, true, true, true, true, true, false],[false, true, true, false, false, false, true, true, true, false, false, false, true, true, false],[false, true, true, false, false, false, true, true, true, false, false, false, true, true, false],[false, true, true, true, true, true, true, true, true, true, true, true, true, true, false]]),
        Nonogram(name: "Robot", solution: [[false, false, false, false, true, true, true, true, true, false, false, false, false, false, false],[false, false, false, false, true, true, true, true, true, false, false, false, false, false, false],[false, false, false, false, true, false, true, false, true, false, false, false, false, false, false],[false, false, false, false, true, true, true, true, true, false, false, false, false, false, false],[false, false, false, true, true, true, true, true, true, true, false, false, false, false, false],[false, true, true, true, true, true, true, true, true, true, true, true, false, false, false],[false, true, false, true, true, true, true, true, true, true, false, true, false, false, false],[false, true, false, true, true, true, true, true, true, true, false, true, false, false, false],[false, true, true, true, true, true, true, true, true, true, true, true, false, false, false],[false, false, false, true, true, true, true, true, true, true, false, false, false, false, false],[false, false, false, true, true, true, true, true, true, true, false, false, false, false, false],[false, false, false, true, true, false, false, false, true, true, false, false, false, false, false],[false, false, false, true, true, false, false, false, true, true, false, false, false, false, false],[false, false, false, true, true, false, false, false, true, true, false, false, false, false, false],[false, false, true, true, true, false, false, false, true, true, true, false, false, false, false]]),
        Nonogram(name: "Landscape", solution: [[false, false, false, false, false, false, false, false, false, false, false, true, true, false, false],[false, false, false, false, false, false, false, false, false, false, true, true, true, true, false],[false, false, false, false, false, false, false, false, false, true, true, true, true, true, true],[false, false, false, false, false, false, false, false, true, true, true, true, true, true, true],[false, false, false, false, true, false, false, true, true, true, true, true, true, true, true],[false, false, false, true, true, true, false, true, true, true, true, true, true, true, true],[false, false, true, true, true, true, true, true, true, true, true, true, true, true, true],[false, true, true, true, true, true, true, true, true, true, true, true, true, true, true],[true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],[true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],[false, true, true, true, true, true, true, true, true, true, true, true, true, true, false],[false, true, true, true, true, true, true, true, true, true, true, true, true, true, false],[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],[true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]]),
        Nonogram(name: "Cat", solution: [[true, false, false, false, false, false, false, false, false, false, false, false, false, false, true],[true, true, false, false, false, false, false, false, false, false, false, false, false, true, true],[true, true, true, false, false, false, false, false, false, false, false, false, true, true, true],[true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],[true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],[true, true, false, false, true, true, true, true, true, true, true, false, false, true, true],[true, true, false, false, true, false, true, true, true, false, true, false, false, true, true],[true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],[true, true, true, true, true, true, true, true, true, true, true, true, true, true, true],[true, true, true, true, true, false, false, false, false, false, true, true, true, true, true],[false, true, true, true, true, true, true, true, true, true, true, true, true, true, false],[false, false, true, true, true, true, true, true, true, true, true, true, true, false, false],[false, false, false, true, true, true, true, true, true, true, true, true, false, false, false],[false, false, false, false, true, true, true, true, true, true, true, false, false, false, false],[false, false, false, false, false, true, true, true, true, true, false, false, false, false, false]]),
        Nonogram(name: "Big Heart", solution: [[false, false, true, true, false, false, false, false, false, true, true, false, false, false, false],[false, true, true, true, true, false, false, false, true, true, true, true, false, false, false],[true, true, true, true, true, true, false, true, true, true, true, true, true, false, false],[true, true, true, true, true, true, true, true, true, true, true, true, true, false, false],[true, true, true, true, true, true, true, true, true, true, true, true, true, false, false],[false, true, true, true, true, true, true, true, true, true, true, true, false, false, false],[false, false, true, true, true, true, true, true, true, true, true, false, false, false, false],[false, false, false, true, true, true, true, true, true, true, false, false, false, false, false],[false, false, false, false, true, true, true, true, true, false, false, false, false, false, false],[false, false, false, false, false, true, true, true, false, false, false, false, false, false],[false, false, false, false, false, false, true, false, false, false, false, false, false, false, false],[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],[false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]]),
        Nonogram(name: "Checkboard", solution: [[true, false, true, false, true, false, true, false, true, false, true, false, true, false, true],[false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],[true, false, true, false, true, false, true, false, true, false, true, false, true, false, true],[false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],[true, false, true, false, true, false, true, false, true, false, true, false, true, false, true],[false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],[true, false, true, false, true, false, true, false, true, false, true, false, true, false, true],[false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],[true, false, true, false, true, false, true, false, true, false, true, false, true, false, true],[false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],[true, false, true, false, true, false, true, false, true, false, true, false, true, false, true],[false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],[true, false, true, false, true, false, true, false, true, false, true, false, true, false, true],[false, true, false, true, false, true, false, true, false, true, false, true, false, true, false],[true, false, true, false, true, false, true, false, true, false, true, false, true, false, true]])
    ]
}
