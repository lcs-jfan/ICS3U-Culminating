//
//  NonogramGameView.swift
//  ICS3U Culminating
//
//  Created by Gemini CLI on 2026-06-01.
//

import SwiftUI

/**
 The main view for the Nonogram game.
 Perfectly centered, polished, with high scores and a timer.
 */
struct NonogramGameView: View {
    
    // MARK: - Stored properties
    
    // The view model that manages the game state
    @State private var viewModel = NonogramViewModel()
    
    // MARK: - Computed properties
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // 1. Title and Timer
                HStack {
                    Spacer()
                    Text("Nonogram")
                        .font(.system(size: 40, design: .rounded))
                    Spacer()
                }
                .overlay(alignment: .trailing) {
                    // Live Timer Display
                    Text(viewModel.timeFormatted)
                        .font(.system(.title3, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.trailing, 20)
                }
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
                
                // 3. Perfectly Centered Grid Area
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
                                    .offset(x: -30)
                                    
                                    Spacer(minLength: 0)
                                }
                                .offset(y: -35)
                                Spacer(minLength: 0)
                            }
                            .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                        }
                    }
                }
                
                Divider()
                
                // 4. Bottom Controls
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
            
            // 5. Best Time Overlay
            if viewModel.showingBestTime {
                ZStack {
                    // Dim background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.showingBestTime = false
                        }
                    
                    // Overlay Window
                    VStack(spacing: 20) {
                        Text("Personal Best")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            Text(viewModel.puzzle.name)
                                .font(.title2.bold())
                            
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
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .animation(.spring(), value: viewModel.showingBestTime)
    }
}

#Preview {
    NonogramGameView()
}
