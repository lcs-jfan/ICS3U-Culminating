//
//  NonogramGameView.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

/**
 USER INTERFACE: NonogramGameView
 -------------------------------
 Demonstrates how arrays drive the visual menus.
 Now includes a working Best Time overlay.
 */
struct NonogramGameView: View {
    
    // The ViewModel acts as the "source of truth".
    @State private var viewModel = NonogramViewModel()
    
    var body: some View {
        // We use a ZStack so the popup window can sit ON TOP of the main game.
        ZStack {
            
            // --- LAYER 1: THE MAIN GAME UI ---
            VStack(spacing: 0) {
                
                // 1. Title
                Text("Nonogram")
                    .font(.system(size: 40, design: .rounded))
                    .padding(.top, 20)
                
                // 2. Selection Area
                VStack(spacing: 12) {
                    
                    // Difficulty Picker using 1D Array
                    Picker("Difficulty", selection: $viewModel.difficulty) {
                        ForEach(viewModel.difficultyLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.difficulty) {
                        viewModel.changeDifficulty(to: viewModel.difficulty)
                    }
                    
                    // Puzzle Selection Dropdown
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
                        
                        // Victory Label
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
                
                // 3. Centered Grid
                ZStack {
                    Color(uiColor: .systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    GeometryReader { geometry in
                        ScrollView([.horizontal, .vertical], showsIndicators: false) {
                            VStack(spacing: 0) {
                                Spacer(minLength: 0)
                                HStack(spacing: 0) {
                                    Spacer(minLength: 0)
                                    
                                    NonogramBoardView(puzzle: viewModel.puzzle, onToggle: { row, col in
                                        viewModel.toggleCell(atRow: row, atColumn: col)
                                    })
                                    .id(viewModel.puzzle.id)
                                    .offset(x: -30, y: -35) // Centering math
                                    
                                    Spacer(minLength: 0)
                                }
                                Spacer(minLength: 0)
                            }
                            .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                        }
                    }
                }
                
                Divider()
                
                // 4. Action Buttons
                HStack(spacing: 15) {
                    Button(role: .destructive, action: {
                        viewModel.resetPuzzle()
                    }) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    
                    Button(action: {
                        viewModel.revealSolution()
                    }) {
                        Label("Reveal", systemImage: "eye")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    
                    // BEST TIME BUTTON: Now toggles the overlay correctly
                    Button(action: {
                        withAnimation {
                            viewModel.showingBestTime = true
                        }
                    }) {
                        Label("Best", systemImage: "stopwatch")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                }
                .padding()
            }
            // Overlaying timer and move count on the main game view
            .overlay(alignment: .trailing) {
                VStack {
                    Text(viewModel.timeFormatted)
                        .font(.system(.title3, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.trailing, 20)
                    
                    Text("Moves: \(viewModel.moveHistory.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 20)
                    
                    Spacer()
                }
                .padding(.top, 30)
            }
            
            // --- LAYER 2: THE POPUP OVERLAY ---
            if viewModel.showingBestTime {
                ZStack {
                    // Dimmed background that closes the popup when tapped
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                viewModel.showingBestTime = false
                            }
                        }
                    
                    // The Actual Window
                    VStack(spacing: 20) {
                        Text("Personal Best")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            Text(viewModel.puzzle.name)
                                .font(.title2.bold())
                            
                            // Reads from the persisted data
                            Text(viewModel.getBestTime())
                                .font(.system(size: 40, weight: .bold, design: .monospaced))
                                .foregroundColor(.purple)
                        }
                        
                        Button("Close") {
                            withAnimation {
                                viewModel.showingBestTime = false
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                    }
                    .padding(30)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .systemBackground)))
                    .shadow(radius: 20)
                    // Makes the popup slide and fade in
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                }
            }
        }
    }
}

#Preview {
    NonogramGameView()
}
