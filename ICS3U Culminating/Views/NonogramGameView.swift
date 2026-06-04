//
//  NonogramGameView.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

/**
 The main view for the Nonogram game.
 It displays the difficulty selection, puzzle selection, and the game board.
 */
struct NonogramGameView: View {
    
    // MARK: - Stored properties
    
    // The view model that manages the game state
    @State private var viewModel = NonogramViewModel()
    
    // MARK: - Computed properties
    
    var body: some View {
        VStack(spacing: 15) {
            
            // Header
            Text("Nonogram")
                .font(.largeTitle)
                .bold()
            
            // 1. Difficulty Picker (Top Bar)
            Picker("Difficulty", selection: $viewModel.difficulty) {
                Text("Easy").tag("Easy")
                Text("Medium").tag("Medium")
                Text("Hard").tag("Hard")
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.difficulty) {
                // Tell the view model to handle the difficulty change logic
                viewModel.changeDifficulty(to: viewModel.difficulty)
            }
            
            // 2. Puzzle Selection Menu (Dropdown)
            HStack {
                Text("Select Puzzle:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Puzzle", selection: $viewModel.selectedPuzzleName) {
                    ForEach(viewModel.currentPuzzleList) { puzzle in
                        Text(puzzle.name).tag(puzzle.name)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: viewModel.selectedPuzzleName) {
                    // Tell the view model to load the specific puzzle by name
                    viewModel.changePuzzle(to: viewModel.selectedPuzzleName)
                }
            }
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.1)))
            
            // Win message or Status
            Group {
                if viewModel.puzzle.isSolved {
                    Text("Solved: \(viewModel.puzzle.name)! 🎉")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(.green.opacity(0.1)))
                } else {
                    Text("Drawing: \(viewModel.puzzle.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // The Game Board
            ScrollView([.horizontal, .vertical]) {
                // By passing the puzzle as an input to a separate View struct, we isolate the grid logic.
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
