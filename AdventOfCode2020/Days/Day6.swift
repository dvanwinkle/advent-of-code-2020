//
//  Day6.swift
//  AdventOfCode2015
//
//  Created by Dan VanWinkle on 12/7/20.
//

import Foundation

struct Day6: Day {
    let day = 6
    // O(n)
    let input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day6.txt")
        .split(separator: "\n", maxSplits: .max, omittingEmptySubsequences: false)
        .reduce(into: [[String]()]) {
            guard $1 != "" else { $0.append([]); return }

            $0[$0.count - 1].append(String($1))
        }

    // O(gp) where g = num of groups && p = num of people in groups
    func part1() -> Int {
        return input.reduce(0) {
            return $0 + $1.map { Set($0.utf8) }.reduce(into: Set<String.UTF8View.Element>()) { $0.formUnion($1) }.count
        }
    }

    func part2() -> Int {
        return input.reduce(0) {
            var group = $1
            var allYes = Set(group.popLast()!.utf8)
            while allYes.count > 0, let next = group.popLast() {
                allYes.formIntersection(Set(next.utf8))
            }

            return $0 + allYes.count
        }
    }
}
