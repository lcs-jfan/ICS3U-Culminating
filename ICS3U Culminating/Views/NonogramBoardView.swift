//
//  NonogramBoardView.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

/**
 VIEW: NonogramBoardView
 -----------------------
 This view is the "Heart" of the visual game. 
 It renders the grid of squares and the numerical clues.
 
 Logic Isolation:
 By making this a separate struct, we ensure that SwiftUI doesn't mix up 
 row and column indices when the user switches between puzzle sizes (like 5x5 and 15x15).
 */
struct NonogramBoardView: View {
    
    // MARK: - Stored properties
    
    /**
     puzzle: The current Nonogram data being displayed.
     Passed in from the parent NonogramGameView.
     */
    let puzzle: Nonogram
    
    /**
     onToggle: A "Closure" or "Callback" function.
     When a cell is tapped, this view doesn't change data itself; 
     it tells the ViewModel which (row, column) was clicked.
     */
    let onToggle: (Int, Int) -> Void
    
    // MARK: - Layout Constants
    
    /**
     cellSize: A dynamic calculation of how big each square should be.
     - 5x5 grid -> 45px (Big)
     - 10x10 grid -> 30px (Medium)
     - 15x15 grid -> 22px (Small)
     This ensures the massive 15x15 grid still fits on the iPhone screen.
     */
    private var cellSize: CGFloat {
        let gridWidth = CGFloat(puzzle.grid.isEmpty ? 1 : puzzle.grid[0].count)
        if gridWidth <= 5 {
            return 45
        } else if gridWidth <= 10 {
            return 30
        } else {
            return 22
        }
    }
    
    /**
     rowClueWidth: The fixed width for the numbers on the left.
     Used for alignment and centering math.
     */
    private let rowClueWidth: CGFloat = 60
    
    /**
     colClueHeight: The fixed height for the numbers on top.
     */
    private let colClueHeight: CGFloat = 70
    
    // MARK: - Body (User Interface)
    
    var body: some View {
        VStack(spacing: 0) {
            
            // --- ROW 1: COLUMN CLUES ---
            HStack(spacing: 0) {
                // Top-Left corner spacer (to leave room for row clues).
                Spacer()
                    .frame(width: rowClueWidth) 
                
                // Draw each column's clue block.
                ForEach(puzzle.columnClues.indices, id: \.self) { columnIndex in
                    VStack(spacing: 1) {
                        Spacer(minLength: 0) // Pushes clues to the bottom of the block
                        let clues: [Int] = puzzle.columnClues[columnIndex]
                        
                        // Draw the individual numbers inside the block.
                        ForEach(clues.indices, id: \.self) { clueIndex in
                            Text("\(clues[clueIndex])")
                                .font(.system(size: cellSize * 0.45, weight: .medium, design: .monospaced))
                                .frame(width: cellSize)
                        }
                    }
                    .frame(width: cellSize, height: colClueHeight)
                }
            }
            
            // --- ROWS 2+: ROW CLUES AND INTERACTIVE CELLS ---
            ForEach(puzzle.grid.indices, id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    
                    // LEFT: Row Clue Block.
                    HStack(spacing: 4) {
                        Spacer() // Pushes numbers to the right (close to the grid)
                        let clues: [Int] = puzzle.rowClues[rowIndex]
                        
                        ForEach(clues.indices, id: \.self) { clueIndex in
                            Text("\(clues[clueIndex])")
                                .font(.system(size: cellSize * 0.45, weight: .medium, design: .monospaced))
                        }
                    }
                    .frame(width: rowClueWidth, height: cellSize)
                    .padding(.trailing, 4)
                    
                    // RIGHT: The interactive cells for this row.
                    let row: [CellState] = puzzle.grid[rowIndex]
                    ForEach(row.indices, id: \.self) { columnIndex in
                        // Reusable Cell Component.
                        NonogramCellView(state: row[columnIndex], size: cellSize)
                            .onTapGesture {
                                // Execute the callback to the ViewModel.
                                onToggle(rowIndex, columnIndex)
                            }
                    }
                }
            }
        }
        .padding() // Exterior padding around the whole board
    }
}

#Preview {
    NonogramBoardView(puzzle: PuzzleLibrary.easyPuzzles[0], onToggle: { _, _ in })
}
