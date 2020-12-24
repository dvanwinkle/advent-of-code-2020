//
//  Day4.swift
//  AdventOfCode2015
//
//  Created by Dan VanWinkle on 12/7/20.
//

import Foundation

struct Day4: Day {
    let day = 4
    let input: [[String: String]] = {
        let lines = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day4.txt")
            .split(separator: "\n", maxSplits: .max, omittingEmptySubsequences: false)
        var passports = [[String: String]]()

        var currentPassport: [String: String]? = nil

        for line in lines {
            if currentPassport == nil {
                currentPassport = [:]
            } else if line == "" {
                passports.append(currentPassport!)
                currentPassport = nil
                continue
            }


            for pair in line.split(separator: " ") {
                var splitPair = pair.split(separator: ":")
                currentPassport![String(splitPair[0])] = String(splitPair[1])
            }
        }

        if let passport = currentPassport {
            passports.append(passport)
        }

        return passports
    }()

    func part1() -> Int {
        let requiredFields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]

        let validPassports = input.filter { passport in requiredFields.allSatisfy { passport.keys.contains($0) }}

        return validPassports.count
    }

    func part2() -> Int {
        let validPassports = input.filter { passport in
            return validateBirthYear(birthYear: passport["byr"]) &&
                validateIssueYear(issueYear: passport["iyr"]) &&
                validateExpirationYear(expirationYear: passport["eyr"]) &&
                validateHeight(height: passport["hgt"]) &&
                validateHairColor(hairColor: passport["hcl"]) &&
                validateEyeColor(eyeColor: passport["ecl"]) &&
                validatePid(pid: passport["pid"])
        }

        return validPassports.count
    }

    private func extractFirstMatch(from string: String?, using pattern: String) -> [String] {
        guard let string = string,
              let expression = try? NSRegularExpression(pattern: pattern, options: []),
              let firstMatch = expression.firstMatch(in: string, options: [], range: NSMakeRange(0, string.utf16.count))
        else {
            return []
        }

        return (0..<firstMatch.numberOfRanges).compactMap { Range(firstMatch.range(at: $0), in: string) }.map { String(string[$0]) }
    }

    private func validateBirthYear(birthYear: String?) -> Bool {
        let match = extractFirstMatch(from: birthYear, using: #"^\d{4}$"#)
        guard match.count == 1, let birthYear = Int(match[0]) else { return false }

        return birthYear >= 1920 && birthYear <= 2002
    }

    private func validateIssueYear(issueYear: String?) -> Bool {
        let match = extractFirstMatch(from: issueYear, using: #"^\d{4}$"#)
        guard match.count == 1, let issueYear = Int(match[0]) else { return false }

        return issueYear >= 2010 && issueYear <= 2020
    }

    private func validateExpirationYear(expirationYear: String?) -> Bool {
        let match = extractFirstMatch(from: expirationYear, using: #"^\d{4}$"#)
        guard match.count == 1, let expirationYear = Int(match[0]) else { return false }

        return expirationYear >= 2020 && expirationYear <= 2030
    }

    private func validateHeight(height: String?) -> Bool {
        let match = extractFirstMatch(from: height, using: #"^(\d{2,3})(cm|in)$"#)
        guard match.count == 3, let heightNumeral = Int(match[1]) else { return false }

        switch match[2] {
        case "cm":
            return heightNumeral >= 150 && heightNumeral <= 193
        case "in":
            return heightNumeral >= 59 && heightNumeral <= 76
        default:
            return false // not possible
        }
    }

    private func validateHairColor(hairColor: String?) -> Bool {
        let match = extractFirstMatch(from: hairColor, using: ##"^#[0-9a-f]{6}$"##)

        return match.count == 1
    }

    private func validateEyeColor(eyeColor: String?) -> Bool {
        let match = extractFirstMatch(from: eyeColor, using: #"^(amb|blu|brn|gry|grn|hzl|oth)$"#)

        return match.count == 2
    }

    private func validatePid(pid: String?) -> Bool {
        let match = extractFirstMatch(from: pid, using: #"^\d{9}$"#)

        return match.count == 1
    }
}
