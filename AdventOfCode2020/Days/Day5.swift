//
//  Day5.swift
//  AdventOfCode2015
//
//  Created by Dan VanWinkle on 12/7/20.
//

import Foundation

struct Day5: Day {
    let day = 5
    let input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day5.txt")
        .split(separator: "\n")
        .map { String($0) }

    func part1() -> Int {
        return input.map { getSeatId(for: $0) }.max()!
    }

    func part2() -> Int {
        let sortedSeats = input.map { getSeatId(for: $0) }.sorted()
        var mySeatId = -1
        var lastSeat = sortedSeats.first!

        for seat in sortedSeats.dropFirst() {
            if lastSeat + 1 != seat {
                mySeatId = lastSeat + 1
                break
            }

            lastSeat = seat
        }

        return mySeatId
    }

    private func getSeatId(for seat: String) -> Int {
        let row = getRowNumber(for: seat)
        let col = getColNumber(for: seat)

        return row * 8 + col
    }

    private func getRowNumber(for seat: String) -> Int {
        let end = seat.index(seat.startIndex, offsetBy: 7)
        let binary = String(seat[..<end].map {
            switch $0 {
            case "B":
                return "1"
            default:
                return "0"
            }
        })

        return Int(strtoul(binary, nil, 2))
    }

    private func getColNumber(for seat: String) -> Int {
        let start = seat.index(seat.startIndex, offsetBy: 7)
        let binary = String(seat[start...].map {
            switch $0 {
            case "R":
                return "1"
            default:
                return "0"
            }
        })

        return Int(strtoul(binary, nil, 2))
    }
}
