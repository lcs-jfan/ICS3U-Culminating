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
 This class acts as the "Middle Man" between the data and the user interface.
 It is marked with '@Observable' so that any SwiftUI view using it will
 automatically update when these properties change.
 */
@Observable
class NonogramViewModel {
    
    // MARK: - Stored properties
    
    /**
     puzzle: The currently active Nonogram puzzle object.
     Changing this property triggers a complete UI refresh of the grid.
     */
    var puzzle: Nonogram
    
    /**
     difficulty: Stores the user's selection from the top bar (Easy, Medium, Hard).
     */
    var difficulty: String = "Easy"
    
    /**
     selectedPuzzleName: Stores the name of the puzzle chosen from the dropdown menu.
     */
    var selectedPuzzleName: String = "Heart"
    
    /**
     secondsElapsed: An integer counting how many seconds the player has been solving.
     */
    var secondsElapsed: Int = 0
    
    /**
     timer: A reference to the background system timer. 
     We store it here so we can stop it (invalidate it) when needed.
     */
    private var timer: Timer?
    
    /**
     timerHasStarted: A Boolean flag to ensure the clock only starts on the FIRST tap.
     */
    var timerHasStarted: Bool = false
    
    /**
     wasRevealed: Tracks if the user clicked the "Reveal" button.
     If true, the game will block them from saving a high score for this session.
     */
    var wasRevealed: Bool = false
    
    /**
     showingBestTime: A toggle for the SwiftUI overlay window.
     */
    var showingBestTime: Bool = false
    
    // MARK: - Computed properties
    
    /**
     currentPuzzleList:
     A helper property that returns only the puzzles matching the current difficulty.
     It uses an if-else block to pick from the PuzzleLibrary.
     */
    var currentPuzzleList: [Nonogram] {
        if difficulty == "Easy" {
            return PuzzleLibrary.easyPuzzles
        } else if difficulty == "Medium" {
            return PuzzleLibrary.mediumPuzzles
        } else {
            return PuzzleLibrary.hardPuzzles
        }
    }
    
    /**
     timeFormatted:
     Converts the raw 'secondsElapsed' (e.g., 90) into a nice string (e.g., "01:30").
     Uses the modulo operator (%) to find remaining seconds.
     */
    var timeFormatted: String {
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Initializer
    
    /**
     init(): The constructor for the ViewModel.
     Starts the app with the very first puzzle in the Easy category.
     */
    init() {
        self.puzzle = PuzzleLibrary.easyPuzzles[0]
        self.selectedPuzzleName = self.puzzle.name
    }
    
    // MARK: - Core Gameplay Logic
    
    /**
     toggleCell(atRow:atColumn:): Handles the user clicking on a square.
     - Parameters:
        - row: The vertical index (0 to grid height - 1)
        - column: The horizontal index (0 to grid width - 1)
     
     The logic follows this cycle: Empty -> Filled -> Marked (X) -> Empty.
     */
    func toggleCell(atRow row: Int, atColumn column: Int) {
        // PRE-CHECK 1: Don't allow clicking if the puzzle is already solved.
        if puzzle.isSolved { return }
        
        // PRE-CHECK 2: Start the clock on the very first interaction.
        startTimerIfNeeded()
        
        // STEP 1: Verify the coordinates are safe (inside the array boundaries).
        if row >= 0 && row < puzzle.grid.count {
            if column >= 0 && column < puzzle.grid[row].count {
                
                // STEP 2: Determine the next state based on the current state.
                let currentState: CellState = puzzle.grid[row][column]
                var nextState: CellState = .empty
                
                if currentState == .empty {
                    nextState = .filled
                } else if currentState == .filled {
                    nextState = .marked
                } else if currentState == .marked {
                    nextState = .empty
                }
                
                // STEP 3: Apply the new state to the grid.
                puzzle.grid[row][column] = nextState
                
                // STEP 4: Check if this click finished the puzzle!
                if puzzle.isSolved {
                    stopTimer() // Stop the clock immediately.
                    
                    // Integrity check: Did the user "cheat" with the Reveal button?
                    if !wasRevealed {
                        saveBestTime() // If not, record their achievement!
                    }
                }
            }
        }
    }
    
    /**
     startTimerIfNeeded(): Creates a background task that ticks every second.
     Uses Timer.scheduledTimer to run a closure (block of code) repeatedly.
     */
    func startTimerIfNeeded() {
        if !timerHasStarted {
            timerHasStarted = true
            secondsElapsed = 0
            timer?.invalidate() // Stop any old timer just in case.
            
            // Create a new timer that repeats every 1.0 seconds.
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                // This code runs every second.
                // 'self' refers to this ViewModel instance.
                self?.secondsElapsed += 1
            }
        }
    }
    
    /**
     stopTimer(): Disconnects the timer from the system so it stops ticking.
     */
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Level Management
    
    /**
     changeDifficulty(to:): Triggered by the segmented picker.
     Switches the list of available puzzles and loads the first one.
     */
    func changeDifficulty(to newDifficulty: String) {
        self.difficulty = newDifficulty
        
        // Auto-load the first puzzle of the new category.
        let firstPuzzle = currentPuzzleList[0]
        loadPuzzle(firstPuzzle)
    }
    
    /**
     changePuzzle(to:): Triggered by the dropdown menu.
     Loads a specific puzzle by searching the current list for the name.
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
     loadPuzzle(_:): The shared logic for loading any new puzzle.
     Resets all the "Session" flags so the user starts with a clean slate.
     */
    func loadPuzzle(_ newPuzzle: Nonogram) {
        stopTimer() // Stop any running clock.
        self.puzzle = newPuzzle
        self.selectedPuzzleName = newPuzzle.name
        self.timerHasStarted = false
        self.secondsElapsed = 0
        self.wasRevealed = false
    }
    
    /**
     resetPuzzle(): Clears the grid but keeps the current puzzle active.
     Uses nested loops to set every cell back to '.empty'.
     */
    func resetPuzzle() {
        stopTimer()
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
        self.puzzle.grid = newGrid
        
        // Reset timing flags.
        self.timerHasStarted = false
        self.secondsElapsed = 0
        self.wasRevealed = false
    }
    
    /**
     revealSolution(): Fills the grid with the solution.
     Disables high scores by setting 'wasRevealed' to true.
     */
    func revealSolution() {
        stopTimer()
        wasRevealed = true // Mark as revealed so high score isn't saved.
        
        let rowCount = puzzle.grid.count
        let colCount = puzzle.grid.isEmpty ? 0 : puzzle.grid[0].count
        
        var solvedGrid: [[CellState]] = []
        //create a new "solution grid"
        for rowIndex in 0..<rowCount {
            //loop through every row
            var newRow: [CellState] = []

            for colIndex in 0..<colCount {
                // If the solution is true, fill the cell. Otherwise, leave it empty.
                if puzzle.solution[rowIndex][colIndex] {
                    //if the cell's condition of corresponding row and column number is filled in the solution
                    newRow.append(.filled)
                    //fill the solved grid array with a "filled"
                } else {
                    newRow.append(.empty)
                    //fill the solved grid array with nothing
                }
            }
            solvedGrid.append(newRow)
        }
        self.puzzle.grid = solvedGrid
    }
    
    // MARK: - DATA PERSISTENCE (High Scores)
    
    /**
     PERSISTENCE KEY:
     The base string used to identify our data in the device's storage.
     */
    private let bestTimesKey = "nonogram_best_times"
    
    /**
     saveBestTime(): Writes the current record to the iPhone's storage.
     
     Steps:
     1. Create a unique key for THIS puzzle (e.g., "best_times_Heart").
     2. Check the existing record in UserDefaults.
     3. If no record exists (0) or the new time is better (lower), SAVE IT.
     */
    func saveBestTime() {
        let key = "\(bestTimesKey)_\(puzzle.name)"
        let currentBest = UserDefaults.standard.integer(forKey: key)
        
        if currentBest == 0 || secondsElapsed < currentBest {
            // Write the value to the device's disk.
            UserDefaults.standard.set(secondsElapsed, forKey: key)
        }
    }
    
    /**
     getBestTime(): Reads the saved record from the device's storage.
     
     Steps:
     1. Retrieve the integer from UserDefaults.
     2. If it's 0, return "N/A".
     3. Otherwise, format the seconds back into "MM:SS".
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
