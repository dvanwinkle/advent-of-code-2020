//
//  Day8.swift
//  AdventOfCode2015
//
//  Created by Dan VanWinkle on 12/7/20.
//

import Foundation

struct Day8: Day {
    enum Day8Error: Error {
        case foundLoop
    }

    enum Operation: String {
        case acc, jmp, nop
    }

    class InstructionNode {
        let index: Int
        let operation: Operation
        let value: Int
        let nextNodeIndex: Int
        var preRunAccumulation = -1
        var deepestReachableIndex = -1

        var alternateNode: InstructionNode? {
            switch operation {
            case .jmp:
                return InstructionNode(index: index, operation: .nop, value: value)
            case .nop:
                return InstructionNode(index: index, operation: .jmp, value: value)
            case .acc:
                return nil
            }
        }

        convenience init<T: StringProtocol>(index: Int, instructionText: T) {
            let instructionSplit = instructionText.split(separator: " ")
            let operation = Operation.init(rawValue: String(instructionSplit[0]))!
            let value = Int(instructionSplit[1])!

            self.init(index: index, operation: operation, value: value)
        }

        init(index: Int, operation: Operation, value: Int) {
            self.index = index
            self.operation = operation
            self.value = value

            switch operation {
            case .acc, .nop:
                nextNodeIndex = index + 1
            case .jmp:
                nextNodeIndex = index + value
            }
        }
    }

    let day = 8
    var graph = buildInstructionGraph(
        getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day8.txt")
            .split(separator: "\n")
    )

    // Time: O(1)
    // Space: O(1)
    func part1() -> Int {
        let startNode = graph[0]
        let deepestNode = graph[startNode.deepestReachableIndex]

        return deepestNode.preRunAccumulation + (deepestNode.operation == .acc ? deepestNode.value : 0)
    }

    // Time: O(n)
    // Space: O(1)
    func part2() -> Int {
        var visitedNodes = [Int: Bool]()
        var accumulator = 0

        let targetNodeIndex = graph.count - 1
        var currentNodeIndex = 0
        while visitedNodes[currentNodeIndex] == nil && currentNodeIndex < graph.count {
            let currentNode = graph[currentNodeIndex]
            visitedNodes[currentNodeIndex] = true

            // Let's see if we can flip it and reach the end if needed
            if currentNode.operation != .acc {
                if currentNode.deepestReachableIndex != targetNodeIndex, let alternateNode = currentNode.alternateNode, alternateNode.nextNodeIndex < graph.count {
                    let nextNode = graph[alternateNode.nextNodeIndex]

                    if nextNode.deepestReachableIndex == targetNodeIndex {
                        currentNodeIndex = alternateNode.nextNodeIndex
                        continue
                    }
                }
            } else {
                accumulator += currentNode.value
            }

            currentNodeIndex = currentNode.nextNodeIndex
        }

        return accumulator
    }

    // Time: O(n)
    // Space: O(n)
    private static func buildInstructionGraph<T: StringProtocol>(_ instructions: [T]) -> [InstructionNode] {
        let graph = instructions.enumerated().map { InstructionNode(index: $0.offset, instructionText: $0.element) }

        let startNode = graph[0]
        startNode.preRunAccumulation = 0

        // Traverse to target
        let targetNode = graph[instructions.count - 1]
        var checkedNodes = [Int: Bool]()
        for node in graph where node.deepestReachableIndex == -1 {
            node.deepestReachableIndex = (try? deepestReachableIndex(to: targetNode, from: node, graph: graph, checkedNodes: &checkedNodes)) ?? node.index
        }

        return graph
    }

    // Time: O(n), O(1) cached
    // Space: O(n) on stack, O(1) cached
    private static func deepestReachableIndex(to target: InstructionNode, from start: InstructionNode, graph: [InstructionNode], checkedNodes: inout [Int: Bool]) throws -> Int {
        guard checkedNodes[start.index] != true else {
            throw Day8Error.foundLoop
        }

        checkedNodes[start.index] = true

        if start.deepestReachableIndex != -1 {
            return start.deepestReachableIndex
        }

        if start.index == target.index {
            return target.index
        }

        if start.nextNodeIndex < graph.count {
            let nextNode = graph[start.nextNodeIndex]
            if start.preRunAccumulation != -1 {
                nextNode.preRunAccumulation = start.preRunAccumulation + (start.operation == .acc ? start.value : 0)
            }

            if nextNode.deepestReachableIndex == -1 {
                do {
                    nextNode.deepestReachableIndex = try deepestReachableIndex(to: target, from: nextNode, graph: graph, checkedNodes: &checkedNodes)
                } catch {
                    return start.index
                }
            }

            return nextNode.deepestReachableIndex
        } else {
            return start.index
        }
    }
}
