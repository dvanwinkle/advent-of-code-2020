//
//  Day19.swift
//  AdventOfCode2020
//
//  Created by Dan VanWinkle on 12/8/20.
//

import Foundation

fileprivate protocol Node {
    var regExPattern: String { get set }

    func isStringValid(_ string: String) throws -> Bool
}

struct Day19: Day {
    fileprivate typealias Graph = [Int: Node]

    fileprivate class ValueNode: Node {
        let value: String
        var regExPattern: String

        init(value: String) {
            self.value = value
            regExPattern = value
        }

        func isStringValid(_ string: String) throws -> Bool {
            return string == value
        }
    }

    fileprivate class CombinationNode: Node {
        var validCombinations = [[Node]]()
        lazy var regExPattern: String = {
            "(\(validCombinations.map { "\($0.map { $0.regExPattern }.joined())" }.joined(separator: "|")))"
        }()

        func isStringValid(_ string: String) throws -> Bool {
            let regEx = try NSRegularExpression(pattern: "^\(regExPattern)$", options: [])
            return regEx.numberOfMatches(in: string, options: [], range: NSMakeRange(0, string.utf16.count)) == 1
        }
    }

    let day = 19
    let input = getInputString(
        atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day19.txt"
    )

    // Time:
    // Space:
    func part1() -> Int {
        var unparsedRules = [Int: String]()
        var graph = Graph()
        var possibleStrings = [String]()
        var parsingRules = true

        for line in input.split(separator: "\n", maxSplits: .max, omittingEmptySubsequences: false) {
            guard !line.isEmpty else {
                parsingRules = false
                continue
            }

            if parsingRules {
                let rule = line.split(separator: ":")
                unparsedRules[Int(rule[0])!] = String(rule[1])
            } else {
                possibleStrings.append(String(line))
            }
        }

        for rule in unparsedRules {
            buildGraph(rule.key, &graph, &unparsedRules)
        }

        let rule0 = graph[0]! as! CombinationNode

        let regex = try! NSRegularExpression(pattern: "^\(rule0.regExPattern)$", options: [])

        return possibleStrings.filter({regex.numberOfMatches(in: $0, options: [], range: NSMakeRange(0, $0.utf16.count)) == 1}).count
    }

    // Time:
    // Space:
    func part2() -> Int {
        var unparsedRules = [Int: String]()
        var graph = Graph()
        var possibleStrings = [String]()
        var parsingRules = true

        for line in input.split(separator: "\n", maxSplits: .max, omittingEmptySubsequences: false) {
            guard !line.isEmpty else {
                parsingRules = false
                continue
            }

            if parsingRules {
                let rule = line.split(separator: ":")
                unparsedRules[Int(rule[0])!] = String(rule[1])
            } else {
                possibleStrings.append(String(line))
            }
        }

        for rule in unparsedRules {
            buildGraph(rule.key, &graph, &unparsedRules)
        }

        if let rule42 = graph[42]?.regExPattern, let rule31 = graph[31]?.regExPattern {
            graph[8]?.regExPattern = "(\(rule42)+)"
            graph[11]?.regExPattern = "((\(rule42)\(rule31))|(\(rule42){2}\(rule31){2})|(\(rule42){3}\(rule31){3})|(\(rule42){4}\(rule31){4}))"
        }

        let rule0 = graph[0]!

        let regex = try! NSRegularExpression(pattern: "^\(rule0.regExPattern)$", options: [])

        return possibleStrings
            .filter({ regex.numberOfMatches(in: $0, options: [], range: NSMakeRange(0, $0.utf16.count)) == 1 })
            .count
    }

    private func buildGraph(_ key: Int, _ graph: inout Graph, _ unparsedRules: inout [Int: String]) {
        guard graph[key] == nil, let unparsedValue = unparsedRules[key] else {
            return
        }

        if unparsedValue.contains("\"") {
            let valueNode = ValueNode(value: unparsedValue.trimmingCharacters(in: CharacterSet(charactersIn: "\" ")))
            graph[key] = valueNode
            return
        }

        let node = CombinationNode()
        unparsedValue.split(separator: "|").forEach{ possibleRule in
            let ruleParts = possibleRule.split(separator: " ").compactMap { Int($0) }
            ruleParts.forEach {
                buildGraph($0, &graph, &unparsedRules)
            }

            node.validCombinations.append(ruleParts.compactMap({ graph[$0] }))
        }

        graph[key] = node
    }
}
