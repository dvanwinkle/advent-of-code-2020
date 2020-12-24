//
//  Day2.swift
//  AdventOfCode2015
//
//  Created by Dan VanWinkle on 12/7/20.
//

import Foundation

struct Day2: Day {
    struct Password {
        let policy: (Int, Int, Character)
        let value: String

        init(_ policyAndPassword: String) {
            let charactersToSplit: [Character] = ["-", " ", ":"]
            let splits = policyAndPassword.split { charactersToSplit.contains($0) }

            policy = (Int(splits[0])!, Int(splits[1])!, splits[2].last!)
            value = String(splits.last!)
        }
    }

    let day = 2
    let input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day2.txt")
        .split(separator: "\n")
        .map { Password(String($0)) }

    // Time: O(nc) where n is number of inputs and c is number of characters in each input
    // Space: O(1)
    func part1() -> Int {
        return input.filter { password in
            let count = password.value.filter { $0 == password.policy.2 }.count

            return count >= password.policy.0 && count <= password.policy.1
        }.count
    }

    // Time: O(n)
    // Space: O(1)
    func part2() -> Int {
        return input.filter { password in
            let pass = password.value
            let first = String.Index(utf16Offset: password.policy.0 - 1, in: pass)
            let second = String.Index(utf16Offset: password.policy.1 - 1, in: pass)
            let firstFound = pass[first] == password.policy.2
            let secondFound = pass[second] == password.policy.2

            return firstFound != secondFound
        }.count
    }
}
