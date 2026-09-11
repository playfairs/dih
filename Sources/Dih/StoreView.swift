import DihCore
import SwiftUI

struct StoreView: View {
    @EnvironmentObject private var game: DihGame

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DIH STORE").font(.caption.weight(.black)).foregroundStyle(.orange)
                        Text("Buy better problems").font(.title.bold())
                        Text("Every upgrade changes the actual game.").foregroundStyle(.secondary)
                    }
                    Spacer()
                    CurrencyView(points: game.points)
                }
                ForEach(DihUpgradeTier.allCases, id: \.self) { tier in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(tier.rawValue.uppercased())
                            .font(.caption.weight(.black))
                            .foregroundStyle(.orange)
                        LazyVStack(spacing: 10) {
                            ForEach(DihUpgradeDefinition.all.filter { $0.tier == tier }) { definition in
                                UpgradeCard(id: definition.id)
                            }
                        }
                    }
                }
            }
            .padding(28)
        }
    }
}