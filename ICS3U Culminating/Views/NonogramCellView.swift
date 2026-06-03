//
//  NonogramCellView.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

/**
 A view that represents a single cell in the Nonogram grid.
 It changes its appearance based on the 'state' provided.
 */
struct NonogramCellView: View {
    
    // MARK: - Stored properties
    
    // The current state of this specific cell
    let state: CellState
    
    // The size of the square cell
    let size: CGFloat = 30
    
    // MARK: - Computed properties
    
    var body: some View {
        ZStack {
            // Base square for the cell
            Rectangle()
                .fill(.white)
                .frame(width: size, height: size)
                // Border to define the grid lines
                .border(.gray, width: 0.5)
            
            // Overlay based on the state
            if state == .filled {
                // A filled cell (black)
                Rectangle()
                    .fill(.primary)
                    .padding(2) // Small gap to keep the grid lines visible
            } else if state == .marked {
                // A marked cell (X)
                Image(systemName: "xmark")
                    .foregroundColor(.red)
                    .font(.system(size: size * 0.6, weight: .bold))
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack {
        NonogramCellView(state: .empty)
        NonogramCellView(state: .filled)
        NonogramCellView(state: .marked)
    }
    .padding()
}
