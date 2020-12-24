//
//  Day3.swift
//  AdventOfCode2015
//
//  Created by Dan VanWinkle on 12/7/20.
//

import Foundation

struct Day3: Day {
    let day = 3
    let input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day3.txt")
        .split(separator: "\n")
        .map { Array($0) }

    // Time: O(n)
    // Space: O(1)
    func part1() -> Int {
        return checkSlope(3, 1)
    }

    // Time: O(ns) where n == number of rows & s == number of slopes to check
    // Space: O(s)
    func part2() -> Int {
        let slopesToCheck = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]
        return slopesToCheck.reduce(1) { $0 * checkSlope($1.0, $1.1) }
    }

    // Time: O(n) where n == number of rows
    // Space: O(1)
    private func checkSlope(_ x: Int, _ y: Int) -> Int {
        var currentX = x
        var treeCount = 0

        for y in stride(from: y, to: input.count, by: y) {
            let row = input[y]
            let current = row[currentX % row.count]
            treeCount += current == "#" ? 1 : 0
            currentX += x
        }

        return treeCount
    }
}
