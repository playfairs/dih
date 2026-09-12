import SwiftUI

struct StatCard: View {
  let title: String
  let value: String
  let icon: String

  var body: some View {
    VStack(alignment: .leading, spacing: 7) {
      Image(systemName: icon).foregroundStyle(.orange)
      Text(title).font(.caption).foregroundStyle(.secondary)
      Text(value).font(.title3.bold().monospacedDigit())
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(13)
    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 9))
  }
}
