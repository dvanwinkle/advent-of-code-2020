//
//  Day18.swift
//  AdventOfCode2020
//
//  Created by Dan VanWinkle on 12/8/20.
//

import Foundation

struct Day18: Day {
    struct Operation: CustomStringConvertible, CustomDebugStringConvertible, Comparable {
        let symbol: Character
        let precedence: Int

        var description: String {
            return String(symbol)
        }

        var debugDescription: String { description }

        func performOperation(on number1: Int, and number2: Int) throws -> Int {
            switch symbol {
            case "+":
                return number1 + number2
            case "*":
                return number1 * number2
            default:
                throw Errors.badOperation
            }
        }

        static func < (lhs: Operation, rhs: Operation) -> Bool {
            lhs.precedence < rhs.precedence
        }

        static func == (lhs: Operation, rhs: Operation) -> Bool {
            lhs.precedence == rhs.precedence
        }
    }

    enum Errors: Error {
        case badOperation
        case invalidInput
    }

    let day = 18
    var input = getInputString(
        atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day18.txt"
    )
    .split(separator: "\n")
//    let input = ["1 + 2 * 3 + 4 * 5 + 6"]
//    let input = ["1 + (2 * 3) + (4 * (5 + 6))"]
//    let input = ["2 * 3 + (4 * 5)"]
//    let input = ["5 + (8 * 3 + 9 + 3 * 4 * 3)"]
//    let input = ["5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"]
//    let input = ["((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"]

    // Time:
    // Space:
    func part1() throws -> Int {
        let operationMap: [Character: Operation] = [
            "+": Operation(symbol: "+", precedence: 1),
            "*": Operation(symbol: "*", precedence: 1)
        ]
        return try input.map({ try calculate($0, precedence: operationMap) }).reduce(0, +)
    }

    // Time:
    // Space:
    func part2() throws -> Int {
        let operationMap: [Character: Operation] = [
            "+": Operation(symbol: "+", precedence: 1),
            "*": Operation(symbol: "*", precedence: 2)
        ]

        return try input.map({ try calculate($0, precedence: operationMap) }).reduce(0, +)
    }

    private func calculate<T: StringProtocol>(_ string: T, precedence: [Character: Operation]) throws -> Int {
        var numberStacks = [[Int]()]
        var operationStacks = [[Operation]()]
        var currentNumber: [Character]? = nil

        for character in string {
            if let current = currentNumber, !("0"..."9").contains(character) {
                numberStacks[numberStacks.count - 1] += [Int(String(current))!]
                currentNumber = nil
            }

            switch character {
            case "0"..."9":
                var current = currentNumber ?? []
                current.append(character)
                currentNumber = current
            case "(":
                numberStacks.append([])
                operationStacks.append([])
            case ")":
                var numberStack = numberStacks.popLast()
                var operationStack = operationStacks.popLast()
                var currentValue = 0
                while let operation = operationStack?.popLast() {
                    guard let n1 = numberStack?.popLast(), let n2 = numberStack?.popLast() else {
                        throw Errors.invalidInput
                    }

                    currentValue = try! operation.performOperation(on: n1, and: n2)
                    numberStack?.append(currentValue)
                }

                numberStacks[numberStacks.count - 1] += [currentValue]
            case "+", "*":
                var numberStack = numberStacks.last!
                var operationStack = operationStacks.last!
                while let currentOperation = precedence[character], let topOperation = operationStack.last, currentOperation.precedence >= topOperation.precedence {
                    let operation = operationStack.popLast()!
                    guard let n1 = numberStack.popLast(), let n2 = numberStack.popLast() else {
                        throw Errors.invalidInput
                    }

                    try! numberStack.append(operation.performOperation(on: n1, and: n2))
                }
                numberStacks[numberStacks.count - 1] = numberStack
                operationStacks[operationStacks.count - 1] = operationStack + [precedence[character]!]
            default:
                continue
            }
        }

        if let current = currentNumber {
            numberStacks[numberStacks.count - 1] += [Int(String(current))!]
            currentNumber = nil
        }

        var operationStack = operationStacks.last!
        var numberStack = numberStacks.last!

        while let operation = operationStack.popLast() {
            guard let n1 = numberStack.popLast(), let n2 = numberStack.popLast() else {
                throw Errors.invalidInput
            }

            try! numberStack.append(operation.performOperation(on: n1, and: n2))
        }

        guard numberStack.count == 1 else {
            throw Errors.invalidInput
        }

        return numberStack.popLast()!
    }
}
