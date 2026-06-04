//
//  NonogramBoardView.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

/**
 A view that renders the puzzle grid and clues.
 Automatically calculates cell size to ensure the entire grid is visible.
 */
struct NonogramBoardView: View {
    
    // MARK: - Stored properties
    
    // The specific puzzle data to display
    let puzzle: Nonogram
    
    // Action to perform when a cell is tapped
    let onToggle: (Int, Int) -> Void
    
    // MARK: - Computed properties
    
    // Dynamic cell size based on grid complexity
    private var cellSize: CGFloat {
        let gridWidth = CGFloat(puzzle.grid.isEmpty ? 1 : puzzle.grid[0].count)
        if gridWidth <= 5 {
            return 45 // Larger for Easy
        } else if gridWidth <= 10 {
            return 30 // Standard for Medium
        } else {
            return 22 // Smaller for Hard (15x15) to fit on screen
        }
    }
    
    // Fixed width for the row clues area
    private let rowClueWidth: CGFloat = 60
    
    // Fixed height for the column clues area
    private let colClueHeight: CGFloat = 70
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. Column Clues
            HStack(spacing: 0) {
                // Spacer matches the row clues area
                Spacer()
                    .frame(width: rowClueWidth) 
                
                ForEach(puzzle.columnClues.indices, id: \.self) { columnIndex in
                    VStack(spacing: 1) {
                        Spacer(minLength: 0)
                        let clues: [Int] = puzzle.columnClues[columnIndex]
                        ForEach(clues.indices, id: \.self) { clueIndex in
                            Text("\(clues[clueIndex])")
                                .font(.system(size: cellSize * 0.45, weight: .medium, design: .monospaced))
                                .frame(width: cellSize)
                        }
                    }
                    .frame(width: cellSize, height: colClueHeight)
                }
            }
            
            // 2. Row Clues and Grid
            ForEach(puzzle.grid.indices, id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    
                    // Row clues display
                    HStack(spacing: 4) {
                        Spacer()
                        let clues: [Int] = puzzle.rowClues[rowIndex]
                        ForEach(clues.indices, id: \.self) { clueIndex in
                            Text("\(clues[clueIndex])")
                                .font(.system(size: cellSize * 0.45, weight: .medium, design: .monospaced))
                        }
                    }
                    .frame(width: rowClueWidth, height: cellSize)
                    .padding(.trailing, 4)
                    
                    // Interactive Row
                    let row: [CellState] = puzzle.grid[rowIndex]
                    ForEach(row.indices, id: \.self) { columnIndex in
                        NonogramCellView(state: row[columnIndex], size: cellSize)
                            .onTapGesture {
                                onToggle(rowIndex, columnIndex)
                            }
                    }
                }
            }
        }
        // Ensure the entire construction is centered
        .padding()
    }
}

#Preview {
    VStack {
        NonogramBoardView(puzzle: PuzzleLibrary.easyPuzzles[0], onToggle: { _, _ in })
        NonogramBoardView(puzzle: PuzzleLibrary.hardPuzzles[0], onToggle: { _, _ in })
    }
}
