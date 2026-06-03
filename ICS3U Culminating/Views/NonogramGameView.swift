//
//  NonogramGameView.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

/**
 The main view for the Nonogram game.
 It displays the clues, the interactive grid, and game controls.
 */
struct NonogramGameView: View {
    
    // MARK: - Stored properties
    
    // The view model that manages the game state
    @State var viewModel = NonogramViewModel()
    
    // MARK: - Computed properties
    //1111
    var body: some View {
        VStack(spacing: 20) {
            
            // Header
            Text("Nonogram")
                .font(.largeTitle)
                .bold()
            
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
            VStack(spacing: 0) {
                // Column Clues
                HStack(spacing: 0) {
                    // Spacer for the top-left corner (above row clues)
                    Spacer()
                        .frame(width: 60) 
                    
                    // Column clues display
                    ForEach(0..<viewModel.puzzle.columnClues.count, id: \.self) { columnIndex in
                        VStack(spacing: 2) {
                            let clues: [Int] = viewModel.puzzle.columnClues[columnIndex]
                            ForEach(0..<clues.count, id: \.self) { clueIndex in
                                let clue: Int = clues[clueIndex]
                                Text("\(clue)")
                                    .font(.caption2)
                                    .frame(width: 30)
                            }
                        }
                    }
                }
                
                // Row Clues and Grid
                ForEach(0..<viewModel.puzzle.grid.count, id: \.self) { rowIndex in
                    HStack(spacing: 0) {
                        // Row clues display
                        HStack(spacing: 4) {
                            Spacer()
                            let clues: [Int] = viewModel.puzzle.rowClues[rowIndex]
                            ForEach(0..<clues.count, id: \.self) { clueIndex in
                                let clue: Int = clues[clueIndex]
                                Text("\(clue)")
                                    .font(.caption2)
                            }
                        }
                        .frame(width: 60)
                        .padding(.trailing, 5)
                        
                        // The interactive row of cells
                        ForEach(0..<viewModel.puzzle.grid[rowIndex].count, id: \.self) { columnIndex in
                            NonogramCellView(state: viewModel.puzzle.grid[rowIndex][columnIndex])
                                .onTapGesture {
                                    // Tell the view model to toggle this cell
                                    viewModel.toggleCell(atRow: rowIndex, atColumn: columnIndex)
                                }
                        }
                    }
                }
            }
            .padding()
            
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
