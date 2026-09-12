import SwiftUI

struct MiniStat: View {
  let title: String
  let value: String
  let icon: String

  var body: some View {
    Label {
      VStack(alignment: .leading, spacing: 1) {
        Text(title).font(.caption2.weight(.bold)).foregroundStyle(.secondary)
        Text(value).font(.headline.monospacedDigit())
      }
    } icon: {
      Image(systemName: icon).foregroundStyle(.orange)
    }
  }
}
