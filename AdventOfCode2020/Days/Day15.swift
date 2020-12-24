//
//  Day15.swift
//  AdventOfCode2020
//
//  Created by Dan VanWinkle on 12/8/20.
//

import Foundation

struct Day15: Day {
    let day = 15
    let input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day15.txt")
        .split(separator: ",")
        .map({ Int($0)! })

    // Time:
    // Space:
    func part1() -> Int {
        return speakNumbers(through: 2020)
    }

    // Time:
    // Space:
    func part2() -> Int {
        return speakNumbers(through: 30_000_000)
    }

    private func speakNumbers(through: Int) -> Int {
        var cache = [Int: Int]()

        for turn in 1..<input.count {
            let number = input[turn - 1]
            cache[number] = turn
        }

        var nextNumber = input[input.count - 1]
        for turn in input.count..<through {
            let numberLastSpokenTurn = cache[nextNumber]

            cache[nextNumber] = turn

            // load next number
            switch numberLastSpokenTurn {
            case .none:
                nextNumber = 0
            case .some(let lastSpokenTurn):
                nextNumber = turn - lastSpokenTurn
            }
        }

        return nextNumber
    }
}
