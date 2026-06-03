//
//  NonogramGameView.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

/**
 The main view for the Nonogram game.
 It displays the difficulty selection, the win status, and the game board.
 */
struct NonogramGameView: View {
    
    // MARK: - Stored properties
    
    // The view model that manages the game state
    @State var viewModel = NonogramViewModel()
    
    // Tracks the current difficulty selection
    @State private var selectedDifficulty: String = "Easy"
    
    // MARK: - Computed properties
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Header
            Text("Nonogram")
                .font(.largeTitle)
                .bold()
            
            // Difficulty Picker
            Picker("Difficulty", selection: $selectedDifficulty) {
                Text("Easy (5x5)").tag("Easy")
                Text("Medium (10x10)").tag("Medium")
                Text("Hard (15x15)").tag("Hard")
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedDifficulty) { 
                // When the difficulty changes, load the corresponding puzzle
                if selectedDifficulty == "Easy" {
                    viewModel.loadPuzzle(Nonogram.example5x5)
                } else if selectedDifficulty == "Medium" {
                    viewModel.loadPuzzle(Nonogram.example10x10)
                } else if selectedDifficulty == "Hard" {
                    viewModel.loadPuzzle(Nonogram.house15x15)
                }
            }
            
            // Win message
            if viewModel.puzzle.isSolved {
                Text("You Solved It! 🎉")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(.green.opacity(0.1)))
            } else {
                Text("Complete the image!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // The Game Board
            ScrollView([.horizontal, .vertical]) {
                // By passing the puzzle as an input to a separate View struct (NonogramBoardView),
                // we isolate the grid logic. 
                // Using .id(viewModel.puzzle.id) forces SwiftUI to recreate the board 
                // whenever the puzzle changes, preventing index-out-of-range crashes.
                NonogramBoardView(puzzle: viewModel.puzzle, onToggle: { row, col in
                    viewModel.toggleCell(atRow: row, atColumn: col)
                })
                .id(viewModel.puzzle.id)
            }
            
            // Controls
            HStack(spacing: 30) {
                Button(action: {
                    viewModel.resetPuzzle()
                }) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    NonogramGameView()
}
