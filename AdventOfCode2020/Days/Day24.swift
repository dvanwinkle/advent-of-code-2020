//
//  Day24.swift
//  AdventOfCode2020
//
//  Created by Dan VanWinkle on 12/8/20.
//

import Foundation

protocol BaseCoordinate: Comparable, Hashable {
}

protocol BaseTile: Hashable {
    associatedtype Coordinate: BaseCoordinate

    var coordinate: Coordinate { get }
}

protocol BaseTileFloor {
    associatedtype Tile: BaseTile
    associatedtype Coordinate = Tile.Coordinate

    var referenceTile: Tile { get }

    func getTile(at: Coordinate) -> Tile
}

struct Day24: Day {
    enum Direction: String {
        case northEast = "ne"
        case east = "e"
        case southEast = "se"
        case southWest = "sw"
        case west = "w"
        case northWest = "nw"
    }

    enum TileState {
        case white, black

        func flip() -> TileState {
            switch self {
            case .white:
                return .black
            case .black:
                return .white
            }
        }
    }

    struct AxialCoordinate: BaseCoordinate, CustomStringConvertible {
        let q: Int
        let r: Int

        var description: String { "(\(q), \(r))" }

        static func + (lhs: AxialCoordinate, rhs: AxialCoordinate) -> AxialCoordinate {
            AxialCoordinate(q: lhs.q + rhs.q, r: lhs.r + rhs.r)
        }

        static func < (lhs: AxialCoordinate, rhs: AxialCoordinate) -> Bool {
            (lhs.r != rhs.r && lhs.r < rhs.r) || lhs.q < rhs.q
        }
    }

    class AxialTile: BaseTile {
        let coordinate: AxialCoordinate
        var state: TileState = .white

        init(coordinate: AxialCoordinate) {
            self.coordinate = coordinate
        }

        static func == (lhs: AxialTile, rhs: AxialTile) -> Bool {
            lhs.coordinate == rhs.coordinate && lhs.state == rhs.state
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(coordinate)
            hasher.combine(state)
        }
    }

    class AxialTileFloor: BaseTileFloor {
        static let allDirections: [Direction] = [.northEast, .east, .southEast, .southWest, .west, .northWest]
        var tiles: [AxialCoordinate: AxialTile]

        let referenceTile: AxialTile

        init() {
            let reference = AxialTile(coordinate: .init(q: 0, r: 0))
            tiles = [reference.coordinate: reference]
            referenceTile = reference
        }

        func getTile(at coordinate: AxialCoordinate) -> AxialTile {
            getOrCreateTile(at: coordinate)
        }

        func countTiles(withState state: TileState) -> Int {
            tiles.values.filter({ $0.state == state }).count
        }

        func getTile(atEndOfPath path: [Direction]) -> AxialTile {
            getTile(at: getCoordinate(fromCoordinate: referenceTile.coordinate, withPath: path))
        }

        func flipTilesForDay() {
            var newState = [AxialCoordinate: AxialTile]()
            for blackTile in tiles.values.filter({ $0.state == .black }) {
                flipTileForDay(tile: blackTile, newState: &newState)
            }

            tiles = newState
        }

        private func flipTileForDay(tile: AxialTile, newState: inout [Coordinate: AxialTile]) {
            guard newState[tile.coordinate] == nil else {
                return
            }

            let surroundingTiles = AxialTileFloor.allDirections
                .map({ getCoordinate(fromCoordinate: tile.coordinate, inDirection: $0) })
                .map(getTile)
            let surroundingBlackCount = surroundingTiles.filter({ $0.state == .black }).count
            let newTile = AxialTile(coordinate: tile.coordinate)
            newState[tile.coordinate] = newTile

            if tile.state == .black {
                newTile.state = surroundingBlackCount == 0 || surroundingBlackCount > 2 ? .white : .black

                for surroundingTile in surroundingTiles {
                    flipTileForDay(tile: surroundingTile, newState: &newState)
                }
            } else if tile.state == .white {
                newTile.state = surroundingBlackCount == 2 ? .black : .white
            }
        }

        private func getCoordinate(fromCoordinate coordinate: AxialCoordinate, inDirection direction: Direction) -> AxialCoordinate {
            let directionOffset: Tile.Coordinate
            switch direction {
            case .northEast:
                directionOffset = .init(q: 1, r: 1)
            case .east:
                directionOffset = .init(q: 1, r: 0)
            case .southEast:
                directionOffset = .init(q: 0, r: -1)
            case .southWest:
                directionOffset = .init(q: -1, r: -1)
            case .west:
                directionOffset = .init(q: -1, r: 0)
            case .northWest:
                directionOffset = .init(q: 0, r: 1)
            }

            return coordinate + directionOffset
        }

        private func getCoordinate(fromCoordinate coordinate: AxialCoordinate, withPath path: [Direction]) -> AxialCoordinate {
            guard !path.isEmpty else {
                return coordinate
            }

            var mutablePath = path
            let nextDirection = mutablePath.removeLast()
            let newCoordinate = getCoordinate(fromCoordinate: coordinate, inDirection: nextDirection)

            return getCoordinate(fromCoordinate: newCoordinate, withPath: mutablePath)
        }

        private func getOrCreateTile(at coordinate: Coordinate) -> Tile {
            if let cached = tiles[coordinate] {
                return cached
            }

            let tile = Tile(coordinate: coordinate)
            tiles[coordinate] = tile

            return tile
        }
    }

    let day = 24
    let input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day24.txt")
        .components(separatedBy: .newlines)
    let floor = AxialTileFloor()

    // Time:
    // Space:
    func part1() -> Int {
        let tilePaths = input.map(getPaths)

        for path in tilePaths {
            let tile = floor.getTile(atEndOfPath: path)
            tile.state = tile.state.flip()
        }

        return floor.countTiles(withState: .black)
    }

    // Time:
    // Space:
    func part2() -> Int {
        for _ in 0 ..< 100 {
            floor.flipTilesForDay()
        }
        return floor.countTiles(withState: .black)
    }

    private func getPaths(line: String) -> [Direction] {
        var directions = [Direction]()

        var currentIndex = line.startIndex
        while currentIndex != line.endIndex {
            let character = line[currentIndex]
            let endIndex = character == "e" || character == "w" ? currentIndex : line.index(after: currentIndex)
            let directionString = String(line[currentIndex ... endIndex])
            directions.append(Direction(rawValue: directionString)!)

            currentIndex = line.index(after: endIndex)
        }

        return directions
    }
}
