//
//  GameLogic.swift
//  ARRPC
//
//  Created by Lakshay Gupta on 14/01/25.
//
import SwiftUI

enum GameState {
    case waiting
    case countdown
    case playing
    case result
}

class GameLogic: ObservableObject {
    @Published var userGesture: String = ""
    @Published var computerGesture: String = ""
    @Published var result: String = ""
    @Published var gameState: GameState = .waiting
    @Published var countdown: Int = 3
    
    func startNewGame() {
        gameState = .countdown
        countdown = 3
        userGesture = ""
        computerGesture = ""
        result = ""
    }
    
    func updateUserGesture(_ gesture: String) {
        if gameState == .playing {
            userGesture = gesture
        }
    }
    
    func playGame() {
        let gestures = ["Rock", "Paper", "Scissors"]
        computerGesture = gestures.randomElement() ?? "Rock"
        
        // Determine winner
        if userGesture == computerGesture {
            result = "It's a Draw!"
        } else if (userGesture == "Rock" && computerGesture == "Scissors") ||
                  (userGesture == "Paper" && computerGesture == "Rock") ||
                  (userGesture == "Scissors" && computerGesture == "Paper") {
            result = "You Win! 🎉"
        } else {
            result = "Computer Wins! 😅"
        }
        
        gameState = .result
    }
}
