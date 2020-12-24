//
//  Day13.swift
//  AdventOfCode2020
//
//  Created by Dan VanWinkle on 12/8/20.
//

import Foundation

extension Int {
    func mod(_ other: Int) -> Int {
        guard other != 0 else { return 0 }
        let m = self % other
        return m < 0 ? m + other : m
    }
}

struct Day13: Day {
    let day = 13
    var input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day13.txt")
        .split(separator: "\n")

    // Time:
    // Space:
    func part1() -> Int {
        let currentTime = Int(input[0])!
        let buses = input[1].split(separator: ",").compactMap({ Int($0) })

        let nextArrivals = buses.map { busNumber -> (busNumber: Int, arrivesIn: Int) in
            let arrivesIn = busNumber - (currentTime % busNumber)

            return (busNumber, arrivesIn)
        }

        return nextArrivals.min { (first, second) -> Bool in
            return first.arrivesIn < second.arrivesIn
        }.map { $0.busNumber * $0.arrivesIn }!
    }

    // Time:
    // Space:
    func part2() -> Int {
        let buses = input[1].split(separator: ",").enumerated().filter({ $0.element != "x" })
            .compactMap({ (offset, element) -> (a: Int, mod: Int)? in
                guard let element = Int(String(element)) else { return nil }

                return ((-offset).mod(element), element)
            })

        let modProduct = buses.reduce(1) { $0 * $1.mod }

        return buses
            .compactMap { bus -> Int? in
                let (a, mod) = bus
                let n1 = modProduct / mod
                let g = gcd(n1, mod)

                guard let x = g.x else { return nil }

                let y = x >= 0 ? x : x + mod

                return a * n1 * y
            }
            .reduce(0, +) % modProduct
    }

    func gcd(_ a: Int, _ b: Int) -> (gcd: Int, x: Int?, y: Int?) {
        if a == 0 {
            return b == 1 ? (b, 0, 1) : (b, nil, nil)
        }

        let (q, r) = b.quotientAndRemainder(dividingBy: a)
        let g = gcd(r, a)
        guard let x1 = g.x, let y1 = g.y else {
            return g
        }

        let x = y1 - (q * x1)
        let y = x1

        return (g.gcd, x, y)
    }
}
