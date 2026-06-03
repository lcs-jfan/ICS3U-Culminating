//
//  NonogramBoardView.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

/**
 A view that renders the puzzle grid and clues.
 By isolating this in its own struct, we ensure that SwiftUI doesn't
 mix up indices when the puzzle size changes.
 */
struct NonogramBoardView: View {
    
    // MARK: - Stored properties
    
    // The specific puzzle data to display
    let puzzle: Nonogram
    
    // Action to perform when a cell is tapped
    let onToggle: (Int, Int) -> Void
    
    // MARK: - Computed properties
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. Column Clues
            HStack(spacing: 0) {
                // Spacer for the top-left corner (above row clues)
                // Width matches the row clues frame below
                Spacer()
                    .frame(width: 60) 
                
                // Column clues display
                // Using .indices is safer than 0..<count for dynamic arrays
                ForEach(puzzle.columnClues.indices, id: \.self) { columnIndex in
                    VStack(spacing: 2) {
                        let clues: [Int] = puzzle.columnClues[columnIndex]
                        ForEach(clues.indices, id: \.self) { clueIndex in
                            let clue: Int = clues[clueIndex]
                            Text("\(clue)")
                                .font(.caption2)
                                .frame(width: 30)
                        }
                    }
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
                            let clue: Int = clues[clueIndex]
                            Text("\(clue)")
                                .font(.caption2)
                        }
                    }
                    .frame(width: 60)
                    .padding(.trailing, 5)
                    
                    // The interactive row of cells
                    let row: [CellState] = puzzle.grid[rowIndex]
                    ForEach(row.indices, id: \.self) { columnIndex in
                        NonogramCellView(state: row[columnIndex])
                            .onTapGesture {
                                onToggle(rowIndex, columnIndex)
                            }
                    }
                }
            }
        }
        .padding()
    }
}
