//
//  Day9.swift
//  AdventOfCode2015
//
//  Created by Dan VanWinkle on 12/7/20.
//

import Foundation

fileprivate class Queue<T> {
    class Node {
        let value: T
        var next: Node? = nil

        init(value: T) {
            self.value = value
        }
    }

    class QueueIterator: IteratorProtocol {
        var currentNode: Node?

        init(head: Node?) {
            currentNode = head
        }

        func next() -> Node? {
            guard let node = currentNode else {
                return nil
            }

            currentNode = node.next

            return node
        }
    }

    let maxSize: Int
    var head: Node? = nil
    var tail: Node? = nil
    var currentSize = 0

    init(maxSize: Int) {
        self.maxSize = maxSize
    }

    func insert(value: T) {
        let node = Node(value: value)

        currentSize += 1

        guard let tail = tail else {
            head = node
            self.tail = node
            return
        }

        tail.next = node
        self.tail = node

        if currentSize > maxSize {
            head = head!.next
        }
    }
}

extension Queue: Sequence {
    func makeIterator() -> QueueIterator {
        return QueueIterator(head: head)
    }
}

struct Day9: Day {
    let day = 9
    let preambleSize = 25
    let input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day9.txt").split(separator: "\n").compactMap { Int($0) }

    // Time:
    // Space:
    func part1() -> Int {
        let queue = Queue<Int>(maxSize: preambleSize)

        checkValue: for i in 0..<input.count {
            let currentValue = input[i]

            // load preamble
            if queue.currentSize < queue.maxSize {
                queue.insert(value: currentValue)
                continue
            }

            var possible = [Int: Bool]()

            for preambleValue in queue {
                if possible[currentValue - preambleValue.value] == true {
                    continue checkValue
                }

                possible[preambleValue.value] = true
            }

            return currentValue
        }

        return -1
    }

    // Time:
    // Space:
    func part2() -> Int {
        let part1Value = part1()

        for i in 0..<input.count - 1 {
            let startingValue = input[i]
            if startingValue > part1Value {
                continue
            }

            var currentMin = startingValue
            var currentMax = startingValue
            var runningSum = startingValue
            var currentPointer = i + 1
            while currentPointer >= 0 && runningSum < part1Value {
                let currentValue = input[currentPointer]
                runningSum += currentValue
                currentMin = min(currentMin, currentValue)
                currentMax = max(currentMax, currentValue)
                currentPointer += 1
            }

            if runningSum == part1Value {
                print(runningSum)
                return currentMax + currentMin
            }
        }

        return -1
    }
}
