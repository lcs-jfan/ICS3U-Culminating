//
//  NonogramGameView.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

/**
 The main view for the Nonogram game.
 The grid is precisely centered by offsetting the clue area.
 */
struct NonogramGameView: View {
    
    // MARK: - Stored properties
    
    // The view model that manages the game state
    @State private var viewModel = NonogramViewModel()
    
    // MARK: - Computed properties
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. Title
            Text("Nonogram")
                .font(.system(size: 40, design: .rounded))
                .padding(.top, 20)
            
            // 2. Selection Area
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
            
            // 3. Grid Area with Precise Offset Centering
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    ScrollView([.horizontal, .vertical], showsIndicators: false) {
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)
                            
                            HStack(spacing: 0) {
                                Spacer(minLength: 0)
                                
                                // The NonogramBoardView has a 60px wide clue area on the left.
                                // To make the GRID itself (the squares) perfectly centered,
                                // we shift the entire board to the left by exactly half that width (30px).
                                NonogramBoardView(puzzle: viewModel.puzzle, onToggle: { row, col in
                                    viewModel.toggleCell(atRow: row, atColumn: col)
                                })
                                .id(viewModel.puzzle.id)
                                .offset(x: -30) // Offset by half of rowClueWidth (60 / 2)
                                
                                Spacer(minLength: 0)
                            }
                            
                            // We also shift the whole board UP by half the clue height (70 / 2)
                            // so the grid's center matches the screen's center vertically too.
                            .offset(y: -35) 
                            
                            Spacer(minLength: 0)
                        }
                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                    }
                }
            }
            
            Divider()
            
            // 4. Bottom Controls
            HStack(spacing: 20) {
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
                    Label("Show Solution", systemImage: "eye")
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .padding()
        }
    }
}

#Preview {
    NonogramGameView()
}
