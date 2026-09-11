import DihCore
import SwiftUI

struct HotlineView: View {
    @EnvironmentObject private var game: DihGame
    @State private var answer = "Press the button for advice you absolutely did not request."

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DIH HOTLINE").font(.caption.weight(.black)).foregroundStyle(.orange)
                    Text("A helper with a telephone problem.").font(.title.bold())
                }
                Spacer()
                CurrencyView(points: game.points)
            }

            HStack(spacing: 16) {
                Image(systemName: "phone.down.fill")
                    .font(.system(size: 34)).foregroundStyle(.orange)
                    .frame(width: 60, height: 60)
                    .background(.orange.opacity(0.12), in: Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(game.helperActive ? "Helper online" : "No one is answering").font(.headline)
                    Text(game.helperActive ? "Your hotline is generating points while you play." : "Call once to hire the hotline helper.")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(game.helperActive ? "Call again" : "Call hotline", systemImage: "phone.fill") {
                    answer = game.callHotline()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

            HStack(spacing: 20) {
                InfoTile(title: "LEVEL", value: "\(game.helperLevel)", icon: "person.fill")
                InfoTile(title: "PAYOUT", value: "+\(game.payoutAmount)", icon: "circle.fill")
                InfoTile(title: "EVERY", value: "\(Int(game.payoutInterval))s", icon: "timer")
                InfoTile(title: "RATE", value: "\(Int(Double(game.payoutAmount) * 60 / game.payoutInterval))/m", icon: "chart.line.uptrend.xyaxis")
                InfoTile(title: "LIFETIME", value: "\(game.save.passivePointsGenerated)", icon: "chart.line.uptrend.xyaxis")
            }

            if game.helperActive {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Next payout")
                        Spacer()
                        Text("\(Int(game.secondsUntilPayout))s")
                            .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                    }
                    ProgressView(value: game.passiveProgress).tint(.orange)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Label("Hotline advice", systemImage: "quote.bubble.fill").font(.headline)
                Text(answer)
                    .font(.title3).foregroundStyle(.secondary)
                    .frame(maxWidth: 500, alignment: .leading)
            }
            Spacer()
        }
        .padding(28)
    }
}

private struct InfoTile: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Image(systemName: icon).foregroundStyle(.orange)
            Text(title).font(.caption2.weight(.bold)).foregroundStyle(.secondary)
            Text(value).font(.title3.bold().monospacedDigit())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}