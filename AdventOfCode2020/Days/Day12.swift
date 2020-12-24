//
//  Day12.swift
//  AdventOfCode2020
//
//  Created by Dan VanWinkle on 12/8/20.
//

import Foundation

class Day12: Day {
    enum FacingDirection: Int {
        case north = 0
        case east = 90
        case south = 180
        case west = 270

        func toMovement(with value: Int) -> Movement {
            switch self {
            case .north: return .north(value)
            case .south: return .south(value)
            case .east: return .east(value)
            case .west: return .west(value)
            }
        }
    }

    enum Movement {
        case north(Int)
        case south(Int)
        case east(Int)
        case west(Int)
        case forward(Int)
    }

    enum Rotation {
        case left(Int)
        case right(Int)
    }

    enum NavigationInstruction {
        case movement(Movement)
        case rotation(Rotation)
    }

    class Ship {
        var location: (eastWest: Int, northSouth: Int) = (0, 0)
        var facing: FacingDirection = .east
        var manhattanDistanceFromOrigin: Int {
            return abs(location.eastWest) + abs(location.northSouth)
        }

        func move(_ direction: Movement) {
            switch direction {
            case .north(let value): location.northSouth += value
            case .south(let value): location.northSouth -= value
            case .east(let value): location.eastWest += value
            case .west(let value): location.eastWest -= value
            case .forward(let value): move(facing.toMovement(with: value))
            }
        }

        func rotate(_ rotation: Rotation) {
            switch rotation {
            case .left(let value):
                facing = FacingDirection(rawValue: (facing.rawValue - value + 360) % 360)!
            case .right(let value):
                facing = FacingDirection(rawValue: (facing.rawValue + value) % 360)!
            }
        }
    }

    let day = 12
    let input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day12.txt")
        .split(separator: "\n")

    lazy var navInstructions: [NavigationInstruction] = {
        return input
            .map { line -> NavigationInstruction in
                let firstCharacter = line[line.startIndex]
                let value = Int(line[line.index(after: line.startIndex)...])!
                switch line[line.startIndex] {
                case "N":
                    return .movement(.north(value))
                case "S":
                    return .movement(.south(value))
                case "E":
                    return .movement(.east(value))
                case "W":
                    return .movement(.west(value))
                case "L":
                    return .rotation(.left(value))
                case "R":
                    return .rotation(.right(value))
                case "F":
                    return .movement(.forward(value))
                default:
                    fatalError("Invalid input")
                }
            }
    }()

    // Time:
    // Space:
    func part1() -> Int {
        var (x, y) = (0, 0)
        let rotations = [
            "E": [
                "R": [
                    0: "E",
                    90: "S",
                    180: "W",
                    270: "N"
                ],
                "L": [
                    0: "E",
                    90: "N",
                    180: "W",
                    270: "S"
                ]
            ],
            "S": [
                "R": [
                    0: "S",
                    90: "W",
                    180: "N",
                    270: "E"
                ],
                "L": [
                    0: "S",
                    90: "E",
                    180: "N",
                    270: "W"
                ]
            ],
            "W": [
                "R": [
                    0: "W",
                    90: "N",
                    180: "E",
                    270: "S"
                ],
                "L": [
                    0: "W",
                    90: "S",
                    180: "E",
                    270: "N"
                ]
            ], "N": [
                "R": [
                    0: "N",
                    90: "E",
                    180: "S",
                    270: "W"
                ],
                "L": [
                    0: "N",
                    90: "W",
                    180: "S",
                    270: "E"
                ]
            ]
        ]
        var heading = "E"

        for (instruction, value) in input.map({ ($0[$0.startIndex], Int($0[$0.index(after: $0.startIndex)...])!) }) {
            switch instruction {
            case "N":
                y += value
            case "S":
                y -= value
            case "E":
                x += value
            case "W":
                x -= value
            case "F":
                switch heading {
                case "N":
                    y += value
                case "S":
                    y -= value
                case "E":
                    x += value
                case "W":
                    x -= value
                default: fatalError()
                }
            case "R":
                heading = rotations[heading]!["R"]![value]!
            case "L":
                heading = rotations[heading]!["L"]![value]!
            default: fatalError()
            }
        }

        return abs(x) + abs(y)
    }

    // Time:
    // Space:
    func part2() -> Int {
        var (x, y) = (0, 0)
        var (wx, wy) = (10, 1)

        for (instruction, value) in input.map({ ($0[$0.startIndex], Int($0[$0.index(after: $0.startIndex)...])!) }) {
            switch instruction {
            case "N":
                wy += value
            case "S":
                wy -= value
            case "E":
                wx += value
            case "W":
                wx -= value
            case "F":
                (x, y) = (x + (value * wx), y + (value * wy))
            case "R":
                for _ in 0..<(value % 360 / 90) {
                    (wx, wy) = (wy, -1 * wx)
                }
            case "L":
                for _ in 0..<(value % 360 / 90) {
                    (wx, wy) = (-1 * wy, wx)
                }
            default: fatalError()
            }
        }

        return abs(x) + abs(y)
    }
}
