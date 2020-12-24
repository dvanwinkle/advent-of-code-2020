//
//  Day1.swift
//  AdventOfCode2015
//
//  Created by Dan VanWinkle on 12/7/20.
//

import Foundation

struct Day1: Day {
    let day = 1
    let input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day1.txt").split(separator: "\n").compactMap { Int($0) }

    // O(N) time || O(N) space
    func part1() -> Int {
        var map = [Int: Bool]()

        for value in input {
            guard map[value] != true else {
                return value * (2020 - value)
            }

            map[2020 - value] = true
        }

        return -1
    }

    func part2() -> Int {
        let sortedInput = input.sorted()

        for i in stride(from: 0, to: sortedInput.count - 3, by: 1) {
            var left = i + 1
            var right = sortedInput.count - 1

            while left < right {
                let possible = sortedInput[i] + sortedInput[left] + sortedInput[right]

                if possible == 2020 {
                    return sortedInput[i] * sortedInput[left] * sortedInput[right]
                } else if possible < 2020 {
                    left += 1
                } else {
                    right -= 1
                }
            }
        }

        return -1
    }
}
