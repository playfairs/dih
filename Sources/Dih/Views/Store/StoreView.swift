import DihCore
import SwiftUI

struct StoreView: View {
  @EnvironmentObject private var game: DihGame
  @State private var selectedBulkQuantity = 1

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
          VStack(alignment: .trailing, spacing: 8) {
            CurrencyView(points: game.points)
            HStack(spacing: 8) {
              bulkButton("1", quantity: 1)
              bulkButton("10", quantity: 10)
              bulkButton("100", quantity: 100)
              bulkButton("MAX", quantity: -1)
            }
          }
        }
        ForEach(DihUpgradeTier.allCases, id: \.self) { tier in
          VStack(alignment: .leading, spacing: 10) {
            Text(tier.rawValue.uppercased())
              .font(.caption.weight(.black))
              .foregroundStyle(.orange)
            LazyVStack(spacing: 10) {
              ForEach(DihUpgradeDefinition.all.filter { $0.tier == tier }) { definition in
                UpgradeCard(id: definition.id, selectedBulkQuantity: selectedBulkQuantity)
              }
            }
          }
        }
      }
      .padding(28)
    }
  }

  private func bulkButton(_ title: String, quantity: Int) -> some View {
    Button(title) {
      selectedBulkQuantity = quantity
    }
    .buttonStyle(.bordered)
    .controlSize(.mini)
    .tint(selectedBulkQuantity == quantity ? .orange : .secondary)
  }
}
