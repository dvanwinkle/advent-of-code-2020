//
//  Day20.swift
//  AdventOfCode2020
//
//  Created by Dan VanWinkle on 12/8/20.
//

import Foundation

struct Day20: Day {
    typealias EdgeMap = (edge: Edge, characters: [Character])
    enum Edge {
        case top, right, bottom, left
    }

    enum ImageTileEdgeState {
        case empty
        case locked(ImageTile)
        case unknown
    }

    class ImageTileNode {
        let imageTile: ImageTile
        var imagePixels: [[Character]]
        var topTile = ImageTileEdgeState.unknown
        var rightTile = ImageTileEdgeState.unknown
        var bottomTile = ImageTileEdgeState.unknown
        var leftTile = ImageTileEdgeState.unknown

        init(tile: ImageTile) {
            imageTile = tile
            imagePixels = []
        }
    }

    class ImageTile: CustomStringConvertible, CustomDebugStringConvertible {
        let id: Int
        private(set) var pixels: [[Character]]

        /// Top row pixel representation (left to right)
        var top: [Character] {
            pixels[0]
        }

        /// Right column pixel representation (top to bottom)
        var right: [Character] {
            pixels.compactMap({ $0.last })
        }

        /// Bottom row pixel representation (left to right)
        var bottom: [Character] {
            pixels.last!
        }

        /// Left row pixel representation (top to bottom)
        var left: [Character] {
            pixels.map({ $0[0] })
        }

        var topMatch: Int? = nil
        var rightMatch: Int? = nil
        var bottomMatch: Int? = nil
        var leftMatch: Int? = nil

        var totalSidesMatched: Int {
            return [topMatch, rightMatch, bottomMatch, leftMatch].compactMap({ $0 }).count
        }

        var description: String {
            return pixels.map({ String($0) }).joined(separator: "\n")
        }

        var debugDescription: String {
            var debugLines = [String]()
            debugLines.append("\(id)\(rightMatch != nil ? " - " : "   ")")
            if bottomMatch != nil {
                debugLines.append("  |    ")
            }

            return debugLines.joined(separator: "\n")
        }

        init(id: Int, pixels: [[Character]]) {
            self.id = id
            self.pixels = pixels
        }

        // Rotates image to right
        func rotateRight() {
            let height = pixels.count
            let width = pixels[0].count

            var rotatedPixels = [[Character]]()
            for i in 0 ..< width {
                var currentRow = [Character]()
                for j in 0 ..< height {
                    currentRow.append(pixels[height - 1 - j][i])
                }
                rotatedPixels.append(currentRow)
            }
            pixels = rotatedPixels

            (topMatch, rightMatch, bottomMatch, leftMatch) = (leftMatch, topMatch, rightMatch, bottomMatch)
        }

        // Rotates image to left
        func rotateLeft() {
            let height = pixels.count
            let width = pixels[0].count

            var rotatedPixels = [[Character]]()
            for i in 0 ..< width {
                var currentRow = [Character]()
                for j in 0 ..< height {
                    currentRow.append(pixels[j][width - 1 - i])
                }
                rotatedPixels.append(currentRow)
            }
            pixels = rotatedPixels

            (topMatch, rightMatch, bottomMatch, leftMatch) = (rightMatch, bottomMatch, leftMatch, topMatch)
        }

        func flipHorizontally() {
            pixels = pixels.map({ $0.reversed() })

            (leftMatch, rightMatch) = (rightMatch, leftMatch)
        }

        func flipVertically() {
            pixels.reverse()
            (topMatch, bottomMatch) = (bottomMatch, topMatch)
        }
    }

    let day = 20
    let tileGraph: [Int: ImageTile] = {
        let input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day20.txt")
            .split(separator: "\n", maxSplits: .max, omittingEmptySubsequences: false)
            .split(separator: "")
            .map({ Array($0) })

        let imageTiles = input.map(processTile)

        for (i, image) in imageTiles.enumerated() {
            imageCheck: for j in (i + 1)..<imageTiles.count {
                let jImage = imageTiles[j]

                func checkForMatch(_ image: ImageTile, other: ImageTile, sideToCheck: Edge, edge: EdgeMap) -> Bool {
                    switch sideToCheck {
                    case .top:
                        if image.top != edge.characters { return false }
                        image.topMatch = other.id
                    case .right:
                        if image.right != edge.characters { return false }
                        image.rightMatch = other.id
                    case .bottom:
                        if image.bottom != edge.characters { return false }
                        image.bottomMatch = other.id
                    case .left:
                        if image.left != edge.characters { return false }
                        image.leftMatch = other.id
                    }

                    switch edge.edge {
                    case .top:
                        other.topMatch = image.id
                    case .right:
                        other.rightMatch = image.id
                    case .bottom:
                        other.bottomMatch = image.id
                    case .left:
                        other.leftMatch = image.id
                    }

                    return true
                }

                func rotateEdges(top: inout EdgeMap, right: inout EdgeMap, bottom: inout EdgeMap, left: inout EdgeMap) {
                    (top, right, bottom, left) = (
                        (left.edge, left.characters.reversed()),
                        top,
                        (right.edge, right.characters.reversed()),
                        bottom
                    )
                }

                func flipHorizontally(top: inout EdgeMap, right: inout EdgeMap, bottom: inout EdgeMap, left: inout EdgeMap) {
                    (top, right, bottom, left) = (
                        (top.edge, top.characters.reversed()),
                        left,
                        (bottom.edge, bottom.characters.reversed()),
                        right
                    )
                }

                var top: EdgeMap = (.top, jImage.top)
                var right: EdgeMap = (.right, jImage.right)
                var bottom: EdgeMap = (.bottom, jImage.bottom)
                var left: EdgeMap = (.left, jImage.left)
                for _ in 0..<4 {
                    if checkForMatch(image, other: jImage, sideToCheck: .top, edge: bottom) { continue imageCheck }
                    if checkForMatch(image, other: jImage, sideToCheck: .right, edge: left) { continue imageCheck }
                    if checkForMatch(image, other: jImage, sideToCheck: .bottom, edge: top) { continue imageCheck }
                    if checkForMatch(image, other: jImage, sideToCheck: .left, edge: right) { continue imageCheck }
                    rotateEdges(top: &top, right: &right, bottom: &bottom, left: &left)
                }

                flipHorizontally(top: &top, right: &right, bottom: &bottom, left: &left)

                for _ in 0..<4 {
                    if checkForMatch(image, other: jImage, sideToCheck: .top, edge: bottom) { continue imageCheck }
                    if checkForMatch(image, other: jImage, sideToCheck: .right, edge: left) { continue imageCheck }
                    if checkForMatch(image, other: jImage, sideToCheck: .bottom, edge: top) { continue imageCheck }
                    if checkForMatch(image, other: jImage, sideToCheck: .left, edge: right) { continue imageCheck }
                    rotateEdges(top: &top, right: &right, bottom: &bottom, left: &left)
                }
            }
        }

        return [Int: ImageTile](uniqueKeysWithValues: imageTiles.map({ ($0.id, $0) }))
    }()

    // Time:
    // Space:
    func part1() -> Int {
        return tileGraph.values
            .filter { $0.totalSidesMatched == 2 }
            .reduce(1) { $0 * $1.id }
    }

    private func alignTile(_ tile: inout ImageTile, toLeft left: ImageTile?, andTop top: ImageTile?) {
        guard tile.leftMatch != left?.id || tile.topMatch != top?.id else {
            return
        }

        if tile.leftMatch != left?.id {
            if tile.topMatch == left?.id {
                tile.rotateLeft()
            } else if tile.rightMatch == left?.id {
                tile.flipHorizontally()
            } else if tile.bottomMatch == left?.id {
                tile.rotateRight()
            }
        }

        if tile.bottomMatch == top?.id {
            tile.flipVertically()
        } else if tile.topMatch != top?.id {
            fatalError()
        }
    }

    // Time:
    // Space:
    func part2() -> Int {
        var leftTile: ImageTile? = nil
        var topTile: ImageTile? = nil
        var startTile = tileGraph[1289]

        var arrangedTiles = [[ImageTile]]()

        while var currentTile = startTile {
            alignTile(&currentTile, toLeft: leftTile, andTop: topTile)
            var currentRow = [currentTile]

            while let rightMatch = currentTile.rightMatch, let nextTile = tileGraph[rightMatch] {
                leftTile = currentTile
                topTile = topTile?.rightMatch != nil ? tileGraph[topTile!.rightMatch!] : nil
                currentTile = nextTile

                alignTile(&currentTile, toLeft: leftTile, andTop: topTile)

                currentRow.append(currentTile)
            }

            arrangedTiles.append(currentRow)
            topTile = currentRow.first
            leftTile = nil

            if let bottomMatch = topTile?.bottomMatch {
                startTile = tileGraph[bottomMatch]
            } else {
                startTile = nil
            }
        }

        return -1
    }

    static private func processTile<T: StringProtocol>(_ tile: [T]) -> ImageTile {
        var id = 0
        var pixels = [[Character]]()

        for line in tile {
            if line.starts(with: "Tile") {
                id = Int(line.split(separator: " ")[1].dropLast())!
                continue
            }

            pixels.append([Character](line))
        }

        return ImageTile(id: id, pixels: pixels)
    }
}
