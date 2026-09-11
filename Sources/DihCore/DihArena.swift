import CoreGraphics

public enum DihArena {
    public static let minimumSize = CGSize(width: 120, height: 100)

    public static func clampedCenter(in arena: CGRect, buttonSize: CGSize, desired: CGPoint) -> CGPoint {
        let halfWidth = min(buttonSize.width / 2, arena.width / 2)
        let halfHeight = min(buttonSize.height / 2, arena.height / 2)
        let minX = arena.minX + halfWidth
        let maxX = arena.maxX - halfWidth
        let minY = arena.minY + halfHeight
        let maxY = arena.maxY - halfHeight
        return CGPoint(x: min(max(desired.x, minX), maxX), y: min(max(desired.y, minY), maxY))
    }

    public static func randomCenter(in arena: CGRect, buttonSize: CGSize, generator: inout some RandomNumberGenerator) -> CGPoint {
        let halfWidth = min(buttonSize.width / 2, arena.width / 2)
        let halfHeight = min(buttonSize.height / 2, arena.height / 2)
        let x = CGFloat.random(in: (arena.minX + halfWidth)...(arena.maxX - halfWidth), using: &generator)
        let y = CGFloat.random(in: (arena.minY + halfHeight)...(arena.maxY - halfHeight), using: &generator)
        return CGPoint(x: x, y: y)
    }
}