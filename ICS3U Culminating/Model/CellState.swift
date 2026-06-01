//
//  CellState.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import Foundation

/**
 Represents the possible states of a single cell in the Nonogram grid.
 In a Nonogram, cells aren't just filled or empty; players also need a way
 to mark cells they are certain should remain empty.
 */
enum CellState {
    // The cell has not been interacted with yet.
    case empty
    
    // The player has decided this cell is part of the hidden image.
    case filled
    
    // The player has marked this cell with an "X" to indicate they know it is empty.
    case marked
}
