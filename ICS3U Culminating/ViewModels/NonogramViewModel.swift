//
//  NonogramViewModel.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation
import SwiftUI

/**
 VIEW MODEL: NonogramViewModel
 ----------------------------
 Demonstrates 1D array state management.
 */
@Observable
class NonogramViewModel {
    
    // MARK: - Stored properties
    
    var puzzle: Nonogram
    
    /**
     [1D ARRAY EXAMPLE]
     'difficultyLevels' is a simple 1D array of Strings.
     This is used to populate the UI menu at the top.
     */
    let difficultyLevels: [String] = ["Easy", "Medium", "Hard"]
    
    /**
     [DYNAMIC 1D ARRAY EXAMPLE]
     'moveHistory' is a list that grows as the user plays.
     It stores a text record of every click the user makes.
     */
    var moveHistory: [String] = []
    
    var difficulty: String = "Easy"
    var selectedPuzzleName: String = "Heart"
    var secondsElapsed: Int = 0
    private var timer: Timer?
    var timerHasStarted: Bool = false
    var wasRevealed: Bool = false
    var showingBestTime: Bool = false
    
    // MARK: - Computed properties
    
    var currentPuzzleList: [Nonogram] {
        if difficulty == "Easy" {
            return PuzzleLibrary.easyPuzzles
        } else if difficulty == "Medium" {
            return PuzzleLibrary.mediumPuzzles
        } else {
            return PuzzleLibrary.hardPuzzles
        }
    }
    
    var timeFormatted: String {
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Initializer
    
    init() {
        self.puzzle = PuzzleLibrary.easyPuzzles[0]
        self.selectedPuzzleName = self.puzzle.name
    }
    
    // MARK: - Functions
    
    func toggleCell(atRow row: Int, atColumn column: Int) {
        if puzzle.isSolved { return }
        
        startTimerIfNeeded()
        
        if row >= 0 && row < puzzle.grid.count {
            if column >= 0 && column < puzzle.grid[row].count {
                let currentState: CellState = puzzle.grid[row][column]
                var nextState: CellState = .empty
                
                if currentState == .empty { nextState = .filled }
                else if currentState == .filled { nextState = .marked }
                else if currentState == .marked { nextState = .empty }
                
                puzzle.grid[row][column] = nextState
                
                /**
                 UPDATING A 1D ARRAY
                 -------------------
                 We 'append' a new String to our history list every time the user clicks.
                 */
                let record = "Tapped (\(row),\(column)) to \(nextState)"
                moveHistory.append(record)
                
                if puzzle.isSolved {
                    stopTimer()
                    if !wasRevealed { saveBestTime() }
                }
            }
        }
    }
    
    func startTimerIfNeeded() {
        if !timerHasStarted {
            timerHasStarted = true
            secondsElapsed = 0
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.secondsElapsed += 1
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func changeDifficulty(to newDifficulty: String) {
        self.difficulty = newDifficulty
        let firstPuzzle = currentPuzzleList[0]
        loadPuzzle(firstPuzzle)
    }
    
    func changePuzzle(to puzzleName: String) {
        for puzzle in currentPuzzleList {
            if puzzle.name == puzzleName {
                loadPuzzle(puzzle)
                return
            }
        }
    }
    
    func loadPuzzle(_ newPuzzle: Nonogram) {
        stopTimer()
        self.puzzle = newPuzzle
        self.selectedPuzzleName = newPuzzle.name
        self.timerHasStarted = false
        self.secondsElapsed = 0
        self.wasRevealed = false
        // Clear move history for the new puzzle
        self.moveHistory = []
    }
    
    func resetPuzzle() {
        stopTimer()
        let rowCount = puzzle.grid.count
        let colCount = puzzle.grid.isEmpty ? 0 : puzzle.grid[0].count
        var newGrid: [[CellState]] = []
        for _ in 0..<rowCount {
            var newRow: [CellState] = []
            for _ in 0..<colCount { newRow.append(.empty) }
            newGrid.append(newRow)
        }
        self.puzzle.grid = newGrid
        self.timerHasStarted = false
        self.secondsElapsed = 0
        self.wasRevealed = false
        // Clear move history on reset
        self.moveHistory = []
    }
    
    func revealSolution() {
        stopTimer()
        wasRevealed = true
        let rowCount = puzzle.grid.count
        let colCount = puzzle.grid.isEmpty ? 0 : puzzle.grid[0].count
        var solvedGrid: [[CellState]] = []
        for rowIndex in 0..<rowCount {
            var newRow: [CellState] = []
            for colIndex in 0..<colCount {
                if puzzle.solution[rowIndex][colIndex] { newRow.append(.filled) }
                else { newRow.append(.empty) }
            }
            solvedGrid.append(newRow)
        }
        self.puzzle.grid = solvedGrid
    }
    
    // MARK: - Data Persistence
    
    private let bestTimesKey = "nonogram_best_times"
    
    func saveBestTime() {
        let key = "\(bestTimesKey)_\(puzzle.name)"
        let currentBest = UserDefaults.standard.integer(forKey: key)
        if currentBest == 0 || secondsElapsed < currentBest {
            UserDefaults.standard.set(secondsElapsed, forKey: key)
        }
    }
    
    func getBestTime() -> String {
        let key = "\(bestTimesKey)_\(puzzle.name)"
        let best = UserDefaults.standard.integer(forKey: key)
        if best == 0 { return "N/A" }
        let minutes = best / 60
        let seconds = best % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
