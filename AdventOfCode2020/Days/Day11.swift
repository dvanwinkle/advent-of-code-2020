//
//  Day11.swift
//  AdventOfCode2020
//
//  Created by Dan VanWinkle on 12/8/20.
//

import Foundation

struct Day11: Day {
    enum Direction {
        case north, south, east, west, northeast, southeast, southwest, northwest

        var movement: (Int, Int) {
            return Direction.movements[self]!
        }

        var opposite: Direction {
            return Direction.opposites[self]!
        }

        static let movements: [Direction: (Int, Int)] = [
            .north: (0, -1),
            .south: (0, 1),
            .east: (1, 0),
            .west: (-1, 0),
            .northeast: (1, -1),
            .northwest: (-1, -1),
            .southeast: (1, 1),
            .southwest: (-1, 1)
        ]

        static let opposites: [Direction: Direction] = [
            .north: .south,
            .south: .north,
            .east: .west,
            .west: .east,
            .northwest: .southeast,
            .northeast: .southwest,
            .southeast: .northwest,
            .southwest: .northeast
        ]
    }

    class SeatNode {
        let value: Character
        var adjacentOccupied = [Direction: Bool]()

        var adjacentOccupideCount: Int {
            adjacentOccupied.values.filter({ $0 }).count
        }

        init(_ value: Character) {
            self.value = value
        }
    }

    let day = 11
    let seatingMap = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day11.txt")
        .split(separator: "\n")
        .map({ Array($0) })

    // Time:
    // Space:
    func part1() -> Int {
        var updated = seatingMap

        repeat {
            let current = updated
            updated = updateSeatingChartPart1(on: current)
            if current == updated {
                break
            }
        } while true

        return updated.map({ $0.filter({$0 == "#"}).count }).reduce(0, +)
    }

    // Time:
    // Space:
    func part2() -> Int {
        var infiniteLoop: [Int: Bool] = [:]
        var updated = seatingMap

        repeat {
            let current = updated
            infiniteLoop[current.hashValue] = true
            updated = updateSeatingChartPart2(on: current)
            if infiniteLoop[updated.hashValue] != nil {
                break
            }
        } while true

        return updated.map({ $0.filter({$0 == "#"}).count }).reduce(0, +)
    }

    private func updateSeatingChartPart1(on seatingMap: [[Character]]) -> [[Character]] {
        var updatedSeatingChart = seatingMap

        for i in 0..<seatingMap.count {
            for j in 0..<seatingMap[i].count {
                let currentSeat = seatingMap[i][j]
                switch currentSeat {
                case "L", "#":
                    var countOccupied = 0
                    for si in max(0, i - 1)..<min(seatingMap.count, i + 2) {
                        for sj in max(0, j - 1)..<min(seatingMap[si].count, j + 2) {
                            if (si, sj) != (i, j) && seatingMap[si][sj] == "#" {
                                countOccupied += 1
                            }
                        }
                    }
                    if countOccupied == 0 && currentSeat != "#" {
                        updatedSeatingChart[i][j] = "#"
                    } else if countOccupied >= 4 && currentSeat != "L" {
                        updatedSeatingChart[i][j] = "L"
                    }
                default:
                    break
                }
            }
        }

        return updatedSeatingChart
    }

    private func updateSeatingChartPart2(on seatingMap: [[Character]]) -> [[Character]] {
        var updatedSeatingChart = seatingMap

        for i in 0..<seatingMap.count {
            for j in 0..<seatingMap[i].count {
                let currentSeat = seatingMap[i][j]
                switch currentSeat {
                case "L", "#":
                    let allDirections: [Direction] = [.north, .south, .east, .west, .northwest, .northeast, .southwest, .southeast]
                    let countOccupied = allDirections
                        .filter { return isSeatOccupied(toThe: $0, ofSeatAt: (i, j), in: seatingMap) }
                        .count

                    if countOccupied == 0 && currentSeat != "#" {
                        updatedSeatingChart[i][j] = "#"
                    } else if countOccupied >= 5 && currentSeat != "L" {
                        updatedSeatingChart[i][j] = "L"
                    }
                default:
                    break
                }
            }
        }

        return updatedSeatingChart
    }

    private func isSeatOccupied(toThe direction: Direction, ofSeatAt location: (Int, Int), in seatingChart: [[Character]]) -> Bool {
        var newLocation = getNewLocation(from: location, in: direction)

        while locationIsValid(newLocation, in: seatingChart) {
            let (x, y) = newLocation
            switch seatingChart[x][y] {
            case ".":
                newLocation = getNewLocation(from: newLocation, in: direction)
            case let seat:
                return seat == "#"
            }
        }

        return false
    }

    private func locationIsValid(_ location: (Int, Int), in seatingChart: [[Character]]) -> Bool {
        let (x, y) = location
        return x >= 0 && y >= 0 && x < seatingChart.count && y < seatingChart[x].count
    }

    private func getNewLocation(from location: (Int, Int), in direction: Direction) -> (Int, Int) {
        let (x, y) = location
        let (dx, dy) = Direction.movements[direction]!

        return (x + dx, y + dy)
    }
}
