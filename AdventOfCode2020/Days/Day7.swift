//
//  Day7.swift
//  AdventOfCode2015
//
//  Created by Dan VanWinkle on 12/7/20.
//

import Foundation

struct Day7: Day {
    typealias Graph = [String: [String: Int]]

    let day = 7
    let graph = buildGraph(input: getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day7.txt").split(separator: "\n").map(String.init))

    func part1() -> Int {
        var visited = Set<String>()
        let targetNode = "shiny gold"

        part1Traverse(graph: graph, targetNode: targetNode, visited: &visited)

        return visited.count - 1
    }

    func part1Traverse(graph: Graph, targetNode: String, visited: inout Set<String>) {
        guard !visited.contains(targetNode) else {
            return
        }

        visited.insert(targetNode)

        for node in graph.keys where graph[node]!.count > 0 {
            if let requirements = graph[node], let _ = requirements[targetNode] {
                part1Traverse(graph: graph, targetNode: node, visited: &visited)
            }
        }
    }

    func part2() -> Int {
        return getBagsNeeded(in: "shiny gold", using: graph)
    }

    private func getBagsNeeded(in node: String, using graph: Graph) -> Int {
        let value = graph[node]!.reduce(0) { (acc, requirement) in
            let (node, count) = requirement
            return acc + count + (count * getBagsNeeded(in: node, using: graph))
        }

        return value
    }

    private static func buildGraph(input: [String]) -> Graph {
        return input.reduce(into: Graph()) { (graph, line) in
            // Simplifies:
            //   posh coral bags contain 1 light silver bag, 2 dull blue bags, 3 dim fuchsia bags, 2 dotted magenta bags.
            //   drab silver bags contain no other bags.
            // To:
            //   posh coral-1 light silver,2 dull blue,3 dim fushsia,2 dotted magenta
            //   drab silver-
            let simpleLine = [(" bags contain ", "-"), (".", ""), ("no other bags", ""), (" bags", ""), (" bag", ""), (", ", ",")]
                .reduce(line) { $0.replacingOccurrences(of: $1.0, with: $1.1) }

            let containsSplit = simpleLine.split(separator: "-")
            let node = String(containsSplit[0])

            guard containsSplit.count == 2 else {
                graph[node] = [:]
                return
            }

            graph[node] = containsSplit[1].split(separator: ",").reduce(into: [String: Int]()) { (acc, current) in
                let split = current.split(separator: " ", maxSplits: 1)
                let targetNode = String(split[1])
                let count = Int(String(split[0]))!

                acc[targetNode] = count
            }
        }
    }
}
