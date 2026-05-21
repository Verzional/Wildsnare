import SwiftUI

struct RoundVictoryOverlayView: View {
    let level: Int
    let results: [RaceResult]
    let onNextLevel: () -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()

                RoundedRectangle(cornerRadius: 42)
                    .fill(Color(red: 0.33, green: 0.36, blue: 0.51))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()

                VStack(spacing: 5) {
                    VStack (spacing: 20){
                        Text("LEADERBOARD")
                            .font(.custom("UpheavalTT-BRK-", size: 45))
                            .foregroundColor(Color(red: 1.0, green: 0.80, blue: 0.06))
                            .shadow(color: Color(red: 0.0, green: 0.06, blue: 0.29), radius: 0, x: 2, y: 4)

                        Text("YOU ARE IN 2ND RANK!")
                            .font(.custom("UpheavalTT-BRK-", size: 25))
                            .foregroundColor(Color(red: 1.0, green: 0.80, blue: 0.06))
                            .shadow(color: Color(red: 0.0, green: 0.06, blue: 0.29), radius: 0, x: 2, y: 3)

                    }
//                    .padding(.top, 20)
                    
                    leaderboardBox

                    Spacer(minLength: 24)

                    Button(action: onNextLevel) {
                        ZStack {
                            Image("btn_Primary")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.80)

                            Text("NEXT LEVEL")
                                .font(.custom("UpheavalTT-BRK-", size: 37))
                                .foregroundColor(.black)
                                .padding(.bottom, 5)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 26)
                }
                .padding(.top, 68)
                .padding(.horizontal, 36)
                .frame(width: geo.size.width * 0.92, height: geo.size.height * 0.94)
            }
        }
    }

    private var leaderboardBox: some View {
        ZStack {
            Image("BoxModal")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 420)
                .clipped()

            VStack(spacing: 24) {
                ForEach(Array(results.prefix(4).enumerated()), id: \.offset) { index, result in
                    HStack {
                        Text("\(index + 1). \(truncatedLeaderboardName(for: result))")
                            .font(.custom("UpheavalTT-BRK-", size: 22))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)

                        Spacer(minLength: 10)

                        Text(String(format: "%.2f", result.finishTime))
                            .font(.custom("UpheavalTT-BRK-", size: 22))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 80)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 380)
    }

    private func truncatedLeaderboardName(for result: RaceResult) -> String {
        let rawName = (result.playerName.isEmpty ? result.senderID : result.playerName).uppercased()
        if rawName.count <= 10 {
            return rawName
        }

        let prefix = rawName.prefix(10)
        return "\(prefix)..."
    }
}

#Preview {
    RoundVictoryOverlayView(
        level: 1,
        results: [
            RaceResult(senderID: "1", playerName: "VERZIONAL", finishTime: 50.0),
            RaceResult(senderID: "2", playerName: "CAFFEINEJUNKIE", finishTime: 99.0),
            RaceResult(senderID: "3", playerName: "INDIGOGUIDEEE", finishTime: 90.0),
            RaceResult(senderID: "4", playerName: "ASDFGHJASDFGH", finishTime: 88.0)
        ],
        onNextLevel: {}
    )
}
