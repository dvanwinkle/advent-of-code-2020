//
//  Day22.swift
//  AdventOfCode2020
//
//  Created by Dan VanWinkle on 12/8/20.
//

import Foundation

struct Day22: Day {
    struct Combat {
        enum Errors: Error {
            case gameEnded
        }

        var player1: Player
        var player2: Player
        var roundsPlayed = 0
        var ended = false

        var winner: Player? {
            guard ended else { return nil }

            return player1.canPlay ? player1 : player2
        }

        static func setupGame(dealtCards: [String]) -> Combat {
            let players = dealtCards.split(separator: "").map({ hand -> Player in
                var hand = hand
                let playerName = hand.removeFirst().replacingOccurrences(of: ":", with: "")

                return Player(name: playerName, deck: hand.compactMap({ Int($0) }))
            })

            return Combat(player1: players[0], player2: players[1])
        }

        mutating func play(verbose: Bool = false) -> Player {
            while !ended {
                do {
                    try playRound(verbose: verbose)
                    if verbose { print() }
                } catch {
                    print(error)
                }
            }

            if verbose {
                print()
                print("== Post-game results ==")
                print("\(player1.name)'s deck: \(player1.deckDescription)")
                print("\(player2.name)'s deck: \(player2.deckDescription)")
            }

            return winner!
        }

        mutating func playRound(verbose: Bool) throws {
            guard !ended else { throw Errors.gameEnded }

            roundsPlayed += 1
            if verbose {
                print("-- Round \(roundsPlayed) --")
                print("\(player1.name)'s deck: \(player1.deckDescription)")
                print("\(player2.name)'s deck: \(player2.deckDescription)")
            }

            let player1Card = try player1.playCard()
            let player2Card = try player2.playCard()

            if verbose {
                print("\(player1.name) plays: \(player1Card)")
                print("\(player2.name) plays: \(player2Card)")
            }

            if player1Card > player2Card {
                if verbose { print("\(player1.name) wins the round!") }
                player1.addCardsToDeck(cards: player1Card, player2Card)
            } else {
                if verbose { print("\(player2.name) wins the round!") }
                player2.addCardsToDeck(cards: player2Card, player1Card)
            }

            ended = !(player1.canPlay && player2.canPlay)
        }
    }

    class RecursiveCombat {
        private static let gamesCreatedQueue = DispatchQueue(label: "com.danvw.AdventOfCode2020.Day22.gamesCreatedQueue")
        private static var gamesCreated = 0

        static func generateGameNumber() -> Int {
            var gameNumber = -1

            gamesCreatedQueue.sync {
                gamesCreated += 1
                gameNumber = gamesCreated
            }

            return gameNumber
        }

        static func setupGame(dealtCards: [String]) -> RecursiveCombat {
            let players = dealtCards.split(separator: "").map({ hand -> Player in
                var hand = hand
                let playerName = hand.removeFirst().replacingOccurrences(of: ":", with: "")

                return Player(name: playerName, deck: hand.compactMap({ Int($0) }))
            })

            return RecursiveCombat(player1: players[0], player2: players[1])
        }

        enum Errors: Error {
            case gameEnded
        }

        var player1: Player
        var player2: Player
        let gameNumber = generateGameNumber()
        var roundsPlayed = 0
        var ended = false

        var player1Cache = Set<[Int]>()
        var player2Cache = Set<[Int]>()

        init(player1: Player, player2: Player) {
            self.player1 = player1
            self.player2 = player2
        }

        func play(verbose: Bool = false) -> Player {
            if verbose { print("=== Game \(gameNumber) ===\n") }
            var winner = player1

            while !ended {
                do {
                    winner = try playRound(verbose: verbose)
                } catch {
                    print(error)
                }
            }

            if verbose && gameNumber == 1 {
                print("\n== Post-game results ==")
                print("\(player1.name)'s deck: \(player1.deckDescription)")
                print("\(player2.name)'s deck: \(player2.deckDescription)")
            }

            return winner
        }

        func playRound(verbose: Bool) throws -> Player {
            guard !ended else { throw Errors.gameEnded }

            guard !player1Cache.contains(player1.deck) else {
                if verbose {
                    print("\(player1.name) has seen this hand before. \(player1.name) wins game \(gameNumber)!")
                }
                ended = true
                return player1
            }

            guard !player2Cache.contains(player2.deck) else {
                if verbose {
                    print("\(player2.name) has seen this hand before. \(player1.name) wins game \(gameNumber)!")
                }
                ended = true
                return player1
            }

            roundsPlayed += 1
            if verbose {
                print("-- Round \(roundsPlayed) (Game \(gameNumber)) --")
                print("\(player1.name)'s deck: \(player1.deckDescription)")
                print("\(player2.name)'s deck: \(player2.deckDescription)")
            }

            player1Cache.insert(player1.deck)
            player2Cache.insert(player2.deck)

            let (player1Card, player2Card) = (try player1.playCard(), try player2.playCard())
            if verbose {
                print("\(player1.name) plays: \(player1Card)")
                print("\(player2.name) plays: \(player2Card)")
            }

            let winner: Player
            if player1Card <= player1.deck.count && player2Card <= player2.deck.count {
                if verbose { print("Playing a sub-game to determine the winner...\n") }

                let subGame = RecursiveCombat(
                    player1: Player(name: player1.name, id: player1.id, deck: Array(player1.deck[0..<player1Card])),
                    player2: Player(name: player2.name, id: player2.id, deck: Array(player2.deck[0..<player2Card]))
                )
                winner = subGame.play(verbose: verbose)

                if verbose { print("...anyway, back to game \(gameNumber)") }
            } else {
                winner = player1Card > player2Card ? player1 : player2
            }

            if verbose { print("\(winner.name) wins round \(roundsPlayed) of game \(gameNumber)!") }

            if winner == player1 {
                player1.addCardsToDeck(cards: player1Card, player2Card)
            } else {
                player2.addCardsToDeck(cards: player2Card, player1Card)
            }

            ended = !(player1.canPlay && player2.canPlay)
            if verbose {
                if ended {
                    print("The winner of game \(gameNumber) is \(winner.name.lowercased())!")
                }
                print()
            }

            return winner
        }
    }

    class Player: Equatable {
        private static let playersCreatedQueue = DispatchQueue(label: "com.danvw.AdventOfCode2020.Day22.playersCreatedQueue")
        private static var playersCreated = 0

        static func generatePlayerId() -> Int {
            var playerId = -1

            playersCreatedQueue.sync {
                playersCreated += 1
                playerId = playersCreated
            }

            return playerId
        }

        static func == (lhs: Player, rhs: Player) -> Bool {
            return lhs.id == rhs.id
        }

        enum Errors: Error {
            case noCardsLeft
        }

        let id: Int
        let name: String
        var deck: [Int]

        var canPlay: Bool {
            return deck.count > 0
        }

        var deckDescription: String {
            return deck.map(String.init).joined(separator: ", ")
        }

        init(name: String, id: Int = generatePlayerId(), deck: [Int] = []) {
            self.id = id
            self.name = name
            self.deck = deck
        }

        func playCard() throws -> Int {
            guard canPlay else { throw Errors.noCardsLeft }

            return deck.removeFirst()
        }

        func addCardsToDeck(cards: Int...) {
            deck += cards
        }
    }

    let day = 22
    let input = getInputString(atPath: "/Users/dvanwinkle/Developer/AdventOfCode2020/AdventOfCode2020/Resources/Day22.txt")
        .split(separator: "\n", maxSplits: .max, omittingEmptySubsequences: false)
        .map(String.init)

    // Time:
    // Space:
    func part1() -> Int {
        var combat = Combat.setupGame(dealtCards: input)
        let winner = combat.play()

        return winner.deck.enumerated().reduce(0) {
            $0 + $1.element * (winner.deck.count - $1.offset)
        }
    }

    // Time:
    // Space:
    func part2() -> Int {
        let combat = RecursiveCombat.setupGame(dealtCards: input)
        let winner = combat.play()

        return winner.deck.enumerated().reduce(0) {
            $0 + $1.element * (winner.deck.count - $1.offset)
        }
    }
}
