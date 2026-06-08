//
//  NonogramViewModel.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation
import SwiftUI

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
    
    // Timer properties
    var secondsElapsed: Int = 0
    private var timer: Timer?
    
    // Controls the visibility of the Best Time overlay
    var showingBestTime: Bool = false
    
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
    
    // Formatted time string (e.g., "01:23")
    var timeFormatted: String {
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Initializer
    
    /**
     Creates a new view model and starts with the first Easy puzzle.
     */
    init() {
        self.puzzle = PuzzleLibrary.easyPuzzles[0]
        self.selectedPuzzleName = self.puzzle.name
        startTimer()
    }
    
    // MARK: - Functions
    
    /**
     Starts or restarts the game timer.
     */
    func startTimer() {
        timer?.invalidate()
        secondsElapsed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.secondsElapsed += 1
        }
    }
    
    /**
     Stops the game timer.
     */
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /**
     Updates the difficulty and loads the first puzzle of that difficulty.
     */
    func changeDifficulty(to newDifficulty: String) {
        self.difficulty = newDifficulty
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
     Loads a new puzzle instance and restarts the timer.
     */
    func loadPuzzle(_ newPuzzle: Nonogram) {
        self.puzzle = newPuzzle
        self.selectedPuzzleName = newPuzzle.name
        startTimer()
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
                
                // Check if solved
                if puzzle.isSolved {
                    stopTimer()
                    saveBestTime()
                }
            }
        }
    }
    
    /**
     Resets the entire grid and restarts the timer.
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
        startTimer()
    }
    
    /**
     Reveals the solution (timer stops).
     */
    func revealSolution() {
        stopTimer()
        let rowCount = puzzle.grid.count
        let colCount = puzzle.grid.isEmpty ? 0 : puzzle.grid[0].count
        
        var solvedGrid: [[CellState]] = []
        for rowIndex in 0..<rowCount {
            var newRow: [CellState] = []
            for colIndex in 0..<colCount {
                if puzzle.solution[rowIndex][colIndex] {
                    newRow.append(.filled)
                } else {
                    newRow.append(.empty)
                }
            }
            solvedGrid.append(newRow)
        }
        puzzle.grid = solvedGrid
    }
    
    // MARK: - Persistence (High Scores)
    
    private let bestTimesKey = "nonogram_best_times"
    
    /**
     Saves the current time if it's the fastest for this puzzle name.
     */
    func saveBestTime() {
        let key = "\(bestTimesKey)_\(puzzle.name)"
        let currentBest = UserDefaults.standard.integer(forKey: key)
        
        if currentBest == 0 || secondsElapsed < currentBest {
            UserDefaults.standard.set(secondsElapsed, forKey: key)
        }
    }
    
    /**
     Retrieves the best time for the current puzzle.
     Returns a formatted string or "N/A".
     */
    func getBestTime() -> String {
        let key = "\(bestTimesKey)_\(puzzle.name)"
        let best = UserDefaults.standard.integer(forKey: key)
        
        if best == 0 {
            return "N/A"
        } else {
            let minutes = best / 60
            let seconds = best % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
