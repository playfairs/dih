import DihCore
import SwiftUI

struct UpgradeCard: View {
  @EnvironmentObject private var game: DihGame
  let id: DihUpgradeID
  let selectedBulkQuantity: Int

  private var definition: DihUpgradeDefinition { game.definition(for: id) }
  private var level: Int { game.level(for: id) }
  private var isMaxed: Bool { level >= definition.maximumLevel }
  private var locked: Bool { !game.isUnlocked(id) }

  private var selectedPurchaseQuantity: Int {
    if selectedBulkQuantity < 0 {
      return DihEconomy.maxAffordable(for: id, in: game.save)
    }
    return min(selectedBulkQuantity, max(0, definition.maximumLevel - level))
  }

  private var selectedCost: Int {
    guard selectedPurchaseQuantity > 0 else { return 0 }
    return DihEconomy.cost(for: id, fromLevel: level, quantity: selectedPurchaseQuantity)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .top, spacing: 10) {
        Image(systemName: definition.icon)
          .font(.title3)
          .foregroundStyle(.orange)
          .frame(width: 34, height: 34)
          .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

        VStack(alignment: .leading, spacing: 4) {
          Text(definition.name)
            .font(.headline)
            .foregroundStyle(.primary)
          Text(definition.description)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(2)
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 3) {
          Text("LEVEL")
            .font(.caption2.weight(.black))
            .foregroundStyle(.secondary)
          Text("\(level)")
            .font(.caption.weight(.black))
            .foregroundStyle(.orange)
        }
      }

      if locked {
        Label(definition.unlockText, systemImage: "lock.fill")
          .font(.caption).foregroundStyle(.secondary)
      } else {
        HStack(alignment: .top, spacing: 10) {
          VStack(alignment: .leading, spacing: 7) {
            Divider().background(.quaternary)
            detailRow(label: "CURRENT", value: effectText)
            detailRow(label: "NEXT", value: nextEffectText)
            detailRow(label: "COST", value: "\(selectedCost) pts")
          }
          .frame(maxWidth: .infinity, alignment: .leading)

          if !isMaxed {
            Button("Buy \((selectedBulkQuantity < 0) ? "MAX" : "\(selectedPurchaseQuantity)")") {
              DihSoundEffects.play(.upgrade, settings: game.settings)
              _ = game.purchase(id, quantity: selectedPurchaseQuantity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .disabled(!canAfford(selectedPurchaseQuantity))
            .frame(alignment: .topTrailing)
          } else {
            Label("MAX", systemImage: "checkmark.seal.fill")
              .font(.caption.weight(.bold))
              .foregroundStyle(.green)
              .frame(alignment: .topTrailing)
          }
        }
      }
    }
    .padding(14)
    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.quaternary, lineWidth: 1))
    .opacity(game.isUnlocked(id) || level > 0 ? 1 : 0.72)
  }

  private func detailRow(label: String, value: String) -> some View {
    HStack(alignment: .top, spacing: 10) {
      Text(label)
        .font(.caption2.weight(.black))
        .foregroundStyle(.secondary)
        .frame(width: 56, alignment: .leading)
      Text(value)
        .font(.caption)
        .foregroundStyle(.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private var effectText: String {
    definition.effectDescription(game.save, level)
  }

  private var nextEffectText: String {
    let nextLevel = min(level + 1, definition.maximumLevel)
    return definition.effectDescription(game.save, nextLevel)
  }

  private func canAfford(_ quantity: Int) -> Bool {
    if level >= definition.maximumLevel { return false }
    guard quantity > 0 else { return false }
    let buyable = min(quantity, definition.maximumLevel - level)
    guard buyable > 0 else { return false }
    let cost = DihEconomy.cost(for: id, fromLevel: level, quantity: buyable)
    return game.points >= cost
  }
}
