//
//  Day23.swift
//  AdventOfCode2020
//
//  Created by Dan VanWinkle on 12/8/20.
//

import Foundation

struct Day23: Day {
    class CupNode: Sequence, Equatable {
        typealias Iterator = CupNodeIterator

        func makeIterator() -> CupNodeIterator {
            return CupNodeIterator(node: self)
        }

        let value: Int
        var next: CupNode!

        init(value: Int) {
            self.value = value
        }

        static func == (lhs: CupNode, rhs: CupNode) -> Bool {
            return lhs.value == rhs.value
        }
    }

    class CupNodeIterator: IteratorProtocol {
        typealias Element = CupNode

        let firstNode: CupNode
        var currentNode: CupNode?
        var hasShownFirst = false

        init(node: CupNode) {
            firstNode = node
            currentNode = node
        }

        func next() -> CupNode? {
            guard !hasShownFirst || currentNode != firstNode else { return nil }

            hasShownFirst = true

            let current = currentNode

            currentNode = current?.next

            return current
        }
    }

    class CupGame: Sequence {
        __consuming func makeIterator() -> Day23.CupGameIterator {
            return Iterator(endingNode: cupMap[1]!, excludeLastElement: true)
        }

        typealias Iterator = CupGameIterator

        var cupMap: [Int: CupNode]
        var currentNode: CupNode
        let minValue: Int
        let maxValue: Int
        var movesPlayed = 0

        var cupsDescription: String {
            var counter = 0
            return currentNode
                .filter({ _ in
                    counter += 1
                    return counter <= 10
                })
                .map({ $0 == currentNode ? "(\($0.value))" : "\($0.value)" })
                .joined(separator: " ")
        }

        init(cupLabeling: String, extendToOneMillion: Bool = false) {
            let labels = cupLabeling
                .map(String.init)
                .compactMap(Int.init)

            var cups = [CupNode]()
            var minValue: Int = .max
            var maxValue: Int = .min
            for label in labels {
                minValue = Swift.min(minValue, label)
                maxValue = Swift.max(maxValue, label)

                let node = CupNode(value: label)

                if let last = cups.last {
                    last.next = node
                }

                cups.append(node)
            }
            if extendToOneMillion, let max = labels.max() {
                maxValue = 1_000_000
                for i in max + 1 ... 1_000_000 {
                    let node = CupNode(value: i)

                    if let last = cups.last {
                        last.next = node
                    }

                    cups.append(node)
                }
            }

            if let first = cups.first, let last = cups.last {
                last.next = first
            }

            cupMap = Dictionary(
                uniqueKeysWithValues: cups.map({ (key: $0.value, value: $0) })
            )
            currentNode = cupMap[labels[0]]!
            self.minValue = minValue
            self.maxValue = maxValue
        }

        func play(numberOfRounds: Int, verbose: Bool = false) {
            while movesPlayed < numberOfRounds {
                move(verbose: verbose)
            }

            if verbose { print("-- final --") }
            if verbose { print("cups:  \(cupsDescription)") }
            if verbose { print() }
        }

        func move(verbose: Bool = false) {
            movesPlayed += 1

            if verbose { print("-- move \(movesPlayed) --") }
            if verbose { print("cups:  \(cupsDescription)") }

            let pickup = currentNode.next!
            currentNode.next = pickup.next!.next!.next
            pickup.next.next.next = pickup

            if verbose { print("pick up: \(pickup.map({ String($0.value) }).joined(separator: ", "))") }

            var destination = currentNode.value
            destination = (destination - 1) < minValue ? maxValue : destination - 1
            let pickupValues = pickup.map(\.value)
            while pickupValues.contains(destination) {
                destination = (destination - 1) < minValue ? maxValue : destination - 1
            }

            if verbose { print("destination: \(destination)") }

            let destinationNode = cupMap[destination]

            let tempNext = destinationNode?.next
            destinationNode?.next = pickup

            pickup.next?.next?.next = tempNext

            if verbose { print() }

            currentNode = currentNode.next!
        }
    }

    struct CupGameIterator: IteratorProtocol {
        let endingNode: CupNode
        var nextNode: CupNode?
        let excludeLastElement: Bool

        init(endingNode: CupNode, excludeLastElement: Bool) {
            self.endingNode = endingNode
            self.nextNode = endingNode.next!
            self.excludeLastElement = excludeLastElement
        }

        typealias Element = Int

        mutating func next() -> Int? {
            guard let node = nextNode, !excludeLastElement || node != endingNode else { return nil }

            nextNode = node == endingNode ? nil : node.next

            return node.value
        }
    }

    let day = 23
    let input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day23.txt")

    // Time:
    // Space:
    func part1() -> Int {
        let game = CupGame(cupLabeling: input)
        game.play(numberOfRounds: 100)

        var currentValue = 0
        for value in game {
            currentValue *= 10
            currentValue += value
        }

        return currentValue
    }

    // Time:
    // Space:
    func part2() -> Int {
        let game = CupGame(cupLabeling: input, extendToOneMillion: true)
        game.play(numberOfRounds: 10_000_000)

        var counter = 0
        var currentValue = 1
        for node in game.cupMap[1]!.next! {
            guard counter < 2 else { break }

            print(node.value)

            currentValue *= node.value

            counter += 1
        }

        return currentValue
    }
}
