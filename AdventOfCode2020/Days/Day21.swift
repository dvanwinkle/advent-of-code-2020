//
//  Day21.swift
//  AdventOfCode2020
//
//  Created by Dan VanWinkle on 12/8/20.
//

import Foundation

struct Day21: Day {
    struct Food {
        let ingredients: [String]
        let alergens: [String]
    }

    let day = 21
    let input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day21.txt")
        .replacingOccurrences(of: "(contains ", with: "|")
        .replacingOccurrences(of: ")", with: "")
        .replacingOccurrences(of: ", ", with: ",")
        .split(separator: "\n")
        .map({ s -> Food in
            let s = s.split(separator: "|")
            return Food(
                ingredients: s[0].split(separator: " ").map({ String($0) }),
                alergens: s[1]
                    .split(separator: ",")
                    .map({ String($0) })
            )
        })

    // Time:
    // Space:
    func part1() -> Int {
        var foods = input
        let ingredients = foods.flatMap(\.ingredients).reduce(into: Set<String>()) { _ = $0.insert($1) }
        let alergens = foods.flatMap(\.alergens).reduce(into: Set<String>()) { _ = $0.insert($1) }

        for alergen in alergens {
            let possibleAllergens = foods
                .filter({ $0.alergens.contains(alergen) })
                .map({ Set($0.ingredients) })
                .reduce(ingredients) { $0.intersection($1) }

            foods = foods.map {
                Food(
                    ingredients: $0.ingredients.filter({ !possibleAllergens.contains($0) }),
                    alergens: $0.alergens
                )
            }
        }

        return foods.map(\.ingredients).reduce(0, { $0 + $1.count })
    }

    // Time:
    // Space:
    func part2() -> String {
        let foods = input
        let ingredients = foods.flatMap(\.ingredients).reduce(into: Set<String>()) { _ = $0.insert($1) }
        let alergens = foods.flatMap(\.alergens).reduce(into: Set<String>()) { _ = $0.insert($1) }

        var alergenMap = [String: Set<String>]()
        for alergen in alergens {
            let possibleAllergens = foods
                .filter({ $0.alergens.contains(alergen) })
                .map({ Set($0.ingredients) })
                .reduce(ingredients) { $0.intersection($1) }

            alergenMap[alergen] = possibleAllergens
        }

        var knownAlergens = [String: String]()
        while let knownAlergen = alergenMap.first(where: { $0.value.count == 1 }), let ingredient = knownAlergen.value.first {
            knownAlergens[ingredient] = knownAlergen.key
            alergenMap.removeValue(forKey: knownAlergen.key)
            alergenMap = alergenMap.mapValues { $0.subtracting(knownAlergens.keys) }
        }

        print(knownAlergens)
        print(alergenMap.count)

        return knownAlergens.sorted(by: { $0.value < $1.value }).map(\.key).joined(separator: ",")
    }
}
