//
//  Day14.swift
//  AdventOfCode2020
//
//  Created by Dan VanWinkle on 12/8/20.
//

import Foundation

struct Day14: Day {
    let day = 14
    let input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day14.txt")
        .split(separator: "\n")

    // Time:
    // Space:
    func part1() -> UInt {
        var mask: (and: UInt, or: UInt) = (.min, .min)
        var register = [Int: UInt]()

        for line in input {
            if line.starts(with: "mask") {
                let trimmedLine = line.replacingOccurrences(of: "mask = ", with: "")
                if let andUInt = UInt(trimmedLine.replacingOccurrences(of: "X", with: "1"), radix: 2) {
                    mask.and = andUInt
                }
                if let orUInt = UInt(trimmedLine.replacingOccurrences(of: "X", with: "0"), radix: 2) {
                    mask.or = orUInt
                }
            } else {
                let trimmedAndSplitLine = line.replacingOccurrences(of: "mem[", with: "")
                    .replacingOccurrences(of: "]", with: "")
                    .replacingOccurrences(of: " ", with: "")
                    .split(separator: "=")

                if let key = Int(trimmedAndSplitLine[0]), let value = UInt(trimmedAndSplitLine[1]) {
                    register[key] = value & mask.and | mask.or
                }
            }
        }

        return register.values.reduce(0, +)
    }

    // Time:
    // Space:
    func part2() -> UInt {
        var mask = input[0].replacingOccurrences(of: "mask = ", with: "")
        var register = [UInt: UInt]()

        for line in input {
            if line.starts(with: "mask") {
                mask = line.replacingOccurrences(of: "mask = ", with: "")
            } else {
                let trimmedAndSplitLine = line.replacingOccurrences(of: "mem[", with: "")
                    .replacingOccurrences(of: "]", with: "")
                    .replacingOccurrences(of: " ", with: "")
                    .split(separator: "=")

                guard let address = UInt(trimmedAndSplitLine[0]), let value = UInt(trimmedAndSplitLine[1]) else {
                    return .min
                }

                var keys: [[Character]] = [[]]
                let addressAsReversedBinaryString = String(address, radix: 2, uppercase: false).reversed()
                for (index, character) in mask.reversed().enumerated() {
                    var currentValue: Character = "0"
                    if index < addressAsReversedBinaryString.count {
                        let currentValueIndex = addressAsReversedBinaryString.index(addressAsReversedBinaryString.startIndex, offsetBy: index)
                        currentValue = addressAsReversedBinaryString[currentValueIndex]
                    }

                    switch character {
                    case "X":
                        let copyOfkeys = keys.map { ["0"] + $0 }
                        keys = keys.map { ["1"] + $0 } + copyOfkeys
                    case "1":
                        keys = keys.map { ["1"] + $0 }
                    case "0":
                        keys = keys.map { [currentValue] + $0 }
                    default:
                        break
                    }
                }

                for key in keys.compactMap({ UInt(String($0), radix: 2) }) {
                    register[key] = value
                }
            }
        }

        return register.values.reduce(0, +)
    }
}
