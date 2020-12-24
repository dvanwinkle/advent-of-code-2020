//
//  Day10.swift
//  AdventOfCode2015
//
//  Created by Dan VanWinkle on 12/7/20.
//

import Foundation

class AdapterNode: Hashable {
    let value: Int
    var possibleAdapters = [AdapterNode]()

    init(_ value: Int) {
        self.value = value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }

    static func ==(lhs: AdapterNode, rhs: AdapterNode) -> Bool {
        return lhs.value == rhs.value
    }
}

struct Day10: Day {
    let day = 10
    var input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day10.txt")
        .split(separator: "\n")
        .compactMap { Int($0) }

    // Time: O(n log(n) + n) -> O(n log(n))
    // Space: O(n)
    func part1() -> Int {
        let sorted = input.sorted()

        var diffs: (ones: Int, threes: Int) = (1, 1)
        for i in 1..<sorted.count {
            let diff = sorted[i] - sorted[i - 1]
            if diff == 1 {
                diffs.ones += 1
            }

            if diff == 3 {
                diffs.threes += 1
            }
        }

        return diffs.ones * diffs.threes
    }

    // Time: O(n)
    // Space: O(n)
    func part2() -> Int {
        var graph = input.reduce(into: [0: AdapterNode(0)]) { $0[$1] = AdapterNode($1) }
        let maxValue = (input.max() ?? 0) + 3
        graph[maxValue] = AdapterNode(maxValue)

        for item in graph {
            item.value.possibleAdapters = ((item.key + 1)...(item.key + 3)).compactMap { graph[$0] }
        }

        var cache = [AdapterNode: Int]()

        return getPossiblePaths(from: graph[0]!, using: &cache)
    }

    // Time: O(n)
    // Space: O(n)
    private func getPossiblePaths(from node: AdapterNode, using cache: inout [AdapterNode: Int]) -> Int {
        if let cacheHit = cache[node] {
            return cacheHit
        }

        if node.possibleAdapters.count == 0 {
            return 1
        }

        let paths = node.possibleAdapters.map { getPossiblePaths(from: $0, using: &cache) }.reduce(0, +)
        cache[node] = paths

        return paths
    }
}
