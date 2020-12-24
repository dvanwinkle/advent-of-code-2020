//
//  Day17.swift
//  AdventOfCode2020
//
//  Created by Dan VanWinkle on 12/8/20.
//

import Foundation
import Algorithms

struct Day17: Day {
    typealias Graph = [Coordinate: Node]
    typealias HyperGraph = [HyperCoordinate: HyperNode]

    struct Coordinate: Hashable, CustomStringConvertible {
        let x: Int
        let y: Int
        let z: Int

        var description: String {
            return "(\(x), \(y), \(z))"
        }
    }

    struct HyperCoordinate: Hashable, CustomStringConvertible {
        let x: Int
        let y: Int
        let z: Int
        let w: Int

        var description: String {
            return "(\(x), \(y), \(z), \(w)"
        }
    }

    enum State: String {
        case active = "#"
        case inactive = "."
    }

    class Node: CustomStringConvertible {
        let location: Coordinate
        var state: State
        var neighbors: [Coordinate: State]

        var description: String {
            return "{\n\tlocation: \(location),\n\tstate: \(state)\n}"
        }

        init(location: Coordinate, state: State, currentGraph graph: Graph) {
            self.location = location
            self.state = state
            var neighbors = [Coordinate: State]()

            for x in location.x - 1 ... location.x + 1 {
                for y in location.y - 1 ... location.y + 1 {
                    for z in location.z - 1 ... location.z + 1 {
                        let coordinate = Coordinate(x: x, y: y, z: z)
                        if location != coordinate {
                            neighbors[coordinate] = graph[coordinate]?.state ?? .inactive
                        }
                    }
                }
            }

            self.neighbors = neighbors
        }
    }

    class HyperNode: CustomStringConvertible {
        let location: HyperCoordinate
        var state: State
        var neighbors: [HyperCoordinate: State]

        var description: String {
            return "{\n\tlocation: \(location),\n\tstate: \(state)\n}"
        }

        init(location: HyperCoordinate, state: State, currentGraph graph: HyperGraph) {
            self.location = location
            self.state = state
            var neighbors = [HyperCoordinate: State]()

            for x in location.x - 1 ... location.x + 1 {
                for y in location.y - 1 ... location.y + 1 {
                    for z in location.z - 1 ... location.z + 1 {
                        for w in location.w - 1 ... location.w + 1 {
                            let coordinate = HyperCoordinate(x: x, y: y, z: z, w: w)
                            if location != coordinate {
                                neighbors[coordinate] = graph[coordinate]?.state ?? .inactive
                            }
                        }
                    }
                }
            }

            self.neighbors = neighbors
        }
    }

    let day = 17
    let input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day17.txt")
        .split(separator: "\n")

    // Time:
    // Space:
    func part1() -> Int {
        var graph = Graph()
        for (y, line) in input.indexed() {
            for (x, state) in line.indexed() {
                let coordinate = Coordinate(x: x.utf16Offset(in: line), y: y, z: 0)
                graph[coordinate] = Node(location: coordinate, state: State(rawValue: String(state))!, currentGraph: graph)
            }
        }

        for (_, node) in graph {
            for (neighbor, _) in node.neighbors {
                node.neighbors[neighbor] = graph[neighbor]?.state ?? .inactive
            }
        }

        var newGraph = graph
        for _ in 0..<6 {
            newGraph = cycleGraph(newGraph)
        }

        return newGraph.filter({ $0.value.state == .active }).count
    }

    private func cycleGraph(_ graph: Graph) -> Graph {
        var newGraph = graph
        for (_, node) in graph {
            for (neighbor, _) in node.neighbors {
                if newGraph[neighbor] == nil {
                    newGraph[neighbor] = Node(location: neighbor, state: .inactive, currentGraph: graph)
                }
            }
        }

        for (_, node) in newGraph {
            let activeNeighborCount = node.neighbors.filter({ $0.value == .active }).count
            if node.state == .active && (activeNeighborCount < 2 || activeNeighborCount > 3) {
                node.state = .inactive
            } else if node.state == .inactive && activeNeighborCount == 3 {
                node.state = .active
            }
        }

        for (_, node) in newGraph {
            for (neighbor, _) in node.neighbors {
                node.neighbors[neighbor] = newGraph[neighbor]?.state ?? .inactive
            }
        }

        return newGraph
    }

    // Time:
    // Space:
    func part2() -> Int {
        var graph = HyperGraph()
        for (y, line) in input.indexed() {
            for (x, state) in line.indexed() {
                let coordinate = HyperCoordinate(x: x.utf16Offset(in: line), y: y, z: 0, w: 0)
                graph[coordinate] = HyperNode(location: coordinate, state: State(rawValue: String(state))!, currentGraph: graph)
            }
        }

        for (_, node) in graph {
            for (neighbor, _) in node.neighbors {
                node.neighbors[neighbor] = graph[neighbor]?.state ?? .inactive
            }
        }

        var newGraph = graph
        for _ in 0..<6 {
            newGraph = cycleHyperGraph(newGraph)
        }

        return newGraph.filter({ $0.value.state == .active }).count
    }

    private func cycleHyperGraph(_ graph: HyperGraph) -> HyperGraph {
        var newGraph = graph
        for (_, node) in graph {
            for (neighbor, _) in node.neighbors {
                if newGraph[neighbor] == nil {
                    newGraph[neighbor] = HyperNode(location: neighbor, state: .inactive, currentGraph: graph)
                }
            }
        }

        for (_, node) in newGraph {
            let activeNeighborCount = node.neighbors.filter({ $0.value == .active }).count
            if node.state == .active && (activeNeighborCount < 2 || activeNeighborCount > 3) {
                node.state = .inactive
            } else if node.state == .inactive && activeNeighborCount == 3 {
                node.state = .active
            }
        }

        for (_, node) in newGraph {
            for (neighbor, _) in node.neighbors {
                node.neighbors[neighbor] = newGraph[neighbor]?.state ?? .inactive
            }
        }

        return newGraph
    }
}
