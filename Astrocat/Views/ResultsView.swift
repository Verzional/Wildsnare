//
//  ResultsView.swift
//  Astrocat
//
//  Created by Arya on 18/05/26.
//

import SwiftUI

struct ResultsView: View {
    let results: [RaceResult]
    var onDismiss: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 32) {
            Text("🏁 Race Results")
                .font(.largeTitle)
                .bold()
            
            VStack(spacing: 16) {
                ForEach(Array(results.enumerated()), id: \.offset) { index, result in
                    HStack {
                        Text(medal(for: index))
                            .font(.title2)
                        Text(result.playerName.isEmpty ? result.senderID : result.playerName)
                            .fontWeight(index == 0 ? .bold : .regular)
                        Spacer()
                        Text(String(format: "%.2fs", result.finishTime))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 32)
                }
            }
            
            Button("Back to Lobby") {
                onDismiss?()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private func medal(for index: Int) -> String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return "\(index + 1)."
        }
    }
}
