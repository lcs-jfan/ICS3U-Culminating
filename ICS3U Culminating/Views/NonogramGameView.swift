//
//  NonogramGameView.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

/**
 The main view for the Nonogram game.
 Automatically centers and scales the grid to fit the screen.
 */
struct NonogramGameView: View {
    
    // MARK: - Stored properties
    
    // The view model that manages the game state
    @State private var viewModel = NonogramViewModel()
    
    // MARK: - Computed properties
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // 1. Top Controls Area
                VStack(spacing: 12) {
                    Picker("Difficulty", selection: $viewModel.difficulty) {
                        Text("Easy").tag("Easy")
                        Text("Medium").tag("Medium")
                        Text("Hard").tag("Hard")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.difficulty) {
                        viewModel.changeDifficulty(to: viewModel.difficulty)
                    }
                    
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
                
                // 2. Centered Grid Area
                // GeometryReader helps us calculate the available screen space
                GeometryReader { geometry in
                    ScrollView([.horizontal, .vertical]) {
                        VStack {
                            Spacer(minLength: 0)
                            
                            HStack {
                                Spacer(minLength: 0)
                                
                                NonogramBoardView(puzzle: viewModel.puzzle, onToggle: { row, col in
                                    viewModel.toggleCell(atRow: row, atColumn: col)
                                })
                                .id(viewModel.puzzle.id)
                                
                                Spacer(minLength: 0)
                            }
                            
                            Spacer(minLength: 0)
                        }
                        // This frame ensures the content is at least as wide/tall as the screen
                        // which allows the Spacers to push the board into the center.
                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                    }
                }
                .background(Color(uiColor: .systemGroupedBackground))
                
                Divider()
                
                // 3. Bottom Controls
                HStack {
                    Button(role: .destructive, action: {
                        viewModel.resetPuzzle()
                    }) {
                        Label("Reset Board", systemImage: "arrow.counterclockwise")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding()
                }
            }
            .navigationTitle("Nonogram")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NonogramGameView()
}
