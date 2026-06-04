//
//  NonogramCellView.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

/**
 A view that represents a single cell in the Nonogram grid.
 Now supports a dynamic size to fit different grid dimensions.
 */
struct NonogramCellView: View {
    
    // MARK: - Stored properties
    
    // The current state of this specific cell
    let state: CellState
    
    // The size of the square cell (passed in by the board view)
    let size: CGFloat
    
    // MARK: - Computed properties
    
    var body: some View {
        ZStack {
            // Base square for the cell
            Rectangle()
                .fill(.white)
                .frame(width: size, height: size)
                .border(.gray.opacity(0.3), width: 0.5)
            
            // Overlay based on the state
            if state == .filled {
                Rectangle()
                    .fill(.primary)
                    .padding(size * 0.05) // Proportional padding
            } else if state == .marked {
                Image(systemName: "xmark")
                    .foregroundColor(.red)
                    // Scale font based on cell size
                    .font(.system(size: size * 0.6, weight: .bold))
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack {
        NonogramCellView(state: .empty, size: 35)
        NonogramCellView(state: .filled, size: 35)
        NonogramCellView(state: .marked, size: 35)
    }
    .padding()
}
