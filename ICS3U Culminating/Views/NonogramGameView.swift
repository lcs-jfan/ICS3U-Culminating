//
//  NonogramGameView.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

/**
 USER INTERFACE: NonogramGameView
 The main screen of the application.
 
 It uses a "VStack" to organize the layout into 4 main sections:
 1. Header (Title and Timer)
 2. Level Selection (Difficulty and Puzzle Menu)
 3. Centered Game Board (The Grid)
 4. Bottom Controls (Reset, Reveal, and Best Time)
 */
struct NonogramGameView: View {
    
    // MARK: - Stored properties
    
    // The ViewModel acts as the "source of truth".
    // Using @State ensures the UI refreshes when the ViewModel changes.
    @State private var viewModel = NonogramViewModel()
    
    // MARK: - Computed properties
    
    var body: some View {
        ZStack {
            // MAIN LAYOUT
            VStack(spacing: 0) {
                
                // --- SECTION 1: HEADER ---
                HStack {
                    Spacer()
                    // Large, clean title with a rounded design
                    Text("Nonogram")
                        .font(.system(size: 40, design: .rounded))
                    Spacer()
                }
                .overlay(alignment: .trailing) {
                    // LIVE TIMER: Displays the secondsElapsed from the ViewModel
                    Text(viewModel.timeFormatted)
                        .font(.system(.title3, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.trailing, 20)
                }
                .padding(.top, 20)
                
                // --- SECTION 2: SELECTION PANEL ---
                VStack(spacing: 12) {
                    // Difficulty segmented control (Easy, Medium, Hard)
                    Picker("Difficulty", selection: $viewModel.difficulty) {
                        Text("Easy").tag("Easy")
                        Text("Medium").tag("Medium")
                        Text("Hard").tag("Hard")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.difficulty) {
                        viewModel.changeDifficulty(to: viewModel.difficulty)
                    }
                    
                    // Specific Puzzle Dropdown Menu
                    HStack {
                        Image(systemName: "list.bullet.indent")
                            .foregroundColor(.secondary)
                        
                        Picker("Puzzle", selection: $viewModel.selectedPuzzleName) {
                            ForEach(viewModel.currentPuzzleList) { puzzle in
                                Text(puzzle.name).tag(puzzle.name)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: viewModel.selectedPuzzleName) {
                            viewModel.changePuzzle(to: viewModel.selectedPuzzleName)
                        }
                        
                        Spacer()
                        
                        // WIN INDICATOR: Only shows if isSolved is true
                        if viewModel.puzzle.isSolved {
                            Text("Solved! 🎉")
                                .font(.subheadline.bold())
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                }
                .padding()
                
                Divider()
                
                // --- SECTION 3: CENTERED GAME BOARD ---
                ZStack {
                    // Light gray background to define the "game area"
                    Color(uiColor: .systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    GeometryReader { geometry in
                        // ScrollView allows the user to pan around larger grids (15x15)
                        ScrollView([.horizontal, .vertical], showsIndicators: false) {
                            VStack(spacing: 0) {
                                Spacer(minLength: 0)
                                HStack(spacing: 0) {
                                    Spacer(minLength: 0)
                                    
                                    // THE BOARD: The grid and clues unit
                                    NonogramBoardView(puzzle: viewModel.puzzle, onToggle: { row, col in
                                        viewModel.toggleCell(atRow: row, atColumn: col)
                                    })
                                    .id(viewModel.puzzle.id) // Forces a fresh build on puzzle change
                                    
                                    /* 
                                     PERFECT CENTERING:
                                     Since row clues (60px) are only on the left and column clues (70px)
                                     are only at the top, we offset the board by half those widths.
                                     This puts the CENTER OF THE GRID squares exactly in the center of the view.
                                     */
                                    .offset(x: -25, y: -35)
                                    
                                    Spacer(minLength: 0)
                                }
                                Spacer(minLength: 0)
                            }
                            // This ensures the container is at least as large as the screen
                            // so the Spacers can push the content into the middle.
                            .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                        }
                    }
                }
                
                Divider()
                
                // --- SECTION 4: ACTION BUTTONS ---
                HStack(spacing: 15) {
                    // Reset: Clears the grid and timer
                    Button(role: .destructive, action: {
                        viewModel.resetPuzzle()
                    }) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    
                    // Reveal: Shows the answer (Disables high scores)
                    Button(action: {
                        viewModel.revealSolution()
                    }) {
                        Label("Reveal", systemImage: "eye")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    
                    // Best Time: Shows the "Personal Best" overlay
                    Button(action: {
                        viewModel.showingBestTime = true
                    }) {
                        Label("Best", systemImage: "stopwatch")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                }
                .padding()
            }
            
            // --- POPUP OVERLAY: PERSONAL BEST ---
            if viewModel.showingBestTime {
                ZStack {
                    // Dimmed background that closes the popup when tapped
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.showingBestTime = false
                        }
                    
                    // The Overlay Window
                    VStack(spacing: 20) {
                        Text("Personal Best")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            Text(viewModel.puzzle.name)
                                .font(.title2.bold())
                            
                            // Displays persisted data from UserDefaults
                            Text(viewModel.getBestTime())
                                .font(.system(size: 40, weight: .bold, design: .monospaced))
                                .foregroundColor(.purple)
                        }
                        
                        Button("Close") {
                            viewModel.showingBestTime = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(30)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground)))
                    .shadow(radius: 10)
                    .transition(.scale.combined(with: .opacity)) // Animated entrance
                }
            }
        }
        // Smoothly animate the appearance of the "Best Time" window
        .animation(.spring(), value: viewModel.showingBestTime)
    }
}

#Preview {
    NonogramGameView()
}
