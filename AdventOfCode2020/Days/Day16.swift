//
//  Day16.swift
//  AdventOfCode2020
//
//  Created by Dan VanWinkle on 12/8/20.
//

import Foundation

struct Day16: Day {
    let day = 16
    let rules: [String: [(lower: Int, upper: Int)]]
    let myTicket: [Int]
    let nearbyTickets: [[Int]]

    init() {
        (rules, myTicket, nearbyTickets) = Day16.parseInput(
            getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day16.txt")
                .split(separator: "\n", maxSplits: .max, omittingEmptySubsequences: false)
                .map({ String($0) })
        )
    }

    // Time:
    // Space:
    func part1() -> Int {
        var errorRate = 0

        for nearbyTicket in nearbyTickets {
            var invalidValues = nearbyTicket
            valueLoop: for value in nearbyTicket {
                for ranges in rules.values {
                    for range in ranges {
                        if value >= range.lower && value <= range.upper {
                            invalidValues.removeAll { $0 == value }
                            continue valueLoop
                        }
                    }
                }
            }

            errorRate += invalidValues.reduce(0, +)
        }

        return errorRate
    }

    // Time:
    // Space:
    func part2() -> Int {
        var possibleMap = [String: [Bool]]()
        var finalMap = [String: Int]()
        let possibleIndexes = [Bool](repeating: true, count: myTicket.count)
        for (key, _) in rules {
            possibleMap[key] = possibleIndexes
            finalMap[key] = -1
        }

        for nearbyTicket in nearbyTickets {
            var invalidValues = nearbyTicket
            valueLoop: for value in nearbyTicket {
                for ranges in rules.values {
                    for range in ranges {
                        if value >= range.lower && value <= range.upper {
                            invalidValues.removeAll { $0 == value }
                            continue valueLoop
                        }
                    }
                }
            }

            if invalidValues.count > 0 { continue }

            for (index, value) in nearbyTicket.enumerated() {
                ruleLoop: for (ruleName, ranges) in rules {
                    if possibleMap[ruleName]?[index] == false { continue }

                    for range in ranges {
                        if value >= range.lower && value <= range.upper {
                            continue ruleLoop
                        }
                    }
                    possibleMap[ruleName]?[index] = false
                }
            }
        }

        var needsIndexed = finalMap.filter { $0.value == -1 }
        while needsIndexed.count != 0 {
            for (key, _) in needsIndexed {
                if possibleMap[key]!.filter({ $0 }).count != 1 {
                    continue
                }

                let index = possibleMap[key]!.firstIndex(of: true)!
                finalMap[key] = index
                for (key, _) in possibleMap.filter({ $0.key != key && $0.value[index] == true }) {
                    possibleMap[key]![index] = false
                }
            }

            needsIndexed = finalMap.filter { $0.value == -1 }
        }

        return finalMap.filter { $0.key.starts(with: "departure") }.map { myTicket[$0.value] }.reduce(1, *)
    }

    private static func parseInput(_ input: [String]) -> (rules: [String: [(lower: Int, upper: Int)]], myTicket: [Int], nearbyTickets: [[Int]]) {
        var rules: [String: [(Int, Int)]] = [:]
        var currentLineIndex = 0
        while input[currentLineIndex] != "" {
            var splits = input[currentLineIndex].replacingOccurrences(of: ": ", with: ":").split(separator: ":")
            let rule = String(splits[0])
            splits = splits[1].replacingOccurrences(of: " or ", with: ":").split(separator: ":")
            let bounds: [(Int, Int)] = splits.map {
                let boundSplit = $0.split(separator: "-")
                return (Int(boundSplit[0])!, Int(boundSplit[1])!)
            }

            rules[rule] = bounds
            currentLineIndex += 1
        }

        currentLineIndex += 2

        let myTicket = input[currentLineIndex].split(separator: ",").map { Int($0)! }

        currentLineIndex += 3

        var nearbyTickets = [[Int]]()

        while currentLineIndex < input.count && input[currentLineIndex] != "" {
            nearbyTickets.append(input[currentLineIndex].split(separator: ",").map({ Int($0)! }))
            currentLineIndex += 1
        }

        return (rules, myTicket, nearbyTickets)
    }
}
