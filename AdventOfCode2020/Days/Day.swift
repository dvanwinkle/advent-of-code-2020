import Foundation

public protocol Day {
    associatedtype P1: CustomStringConvertible
    associatedtype P2: CustomStringConvertible

    var day: Int { get }

    func part1() throws -> P1
    func part2() throws -> P2
}

extension Day {
    public func main() {
        let part1Start = Date()
        let part1Value = try! part1()
        let part1Time = part1Start.distance(to: Date())

        let part2Start = Date()
        let part2Value = try! part2()
        let part2Time = part2Start.distance(to: Date())

        print("Day \(day):\n\tPart 1: \(part1Value) (\(part1Time)\n\tPart 2: \(part2Value) (\(part2Time))")
    }
}
