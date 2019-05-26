//
//  Serializer.swift
//  Contact-2.0
//
//  Created by Fedor on 13/04/2019.
//  Copyright © 2019 Fedor. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

extension Decodable {
    init?(from json: String) throws {
        guard let jsonData = json.data(using: .utf8) else { return nil }
        self = try JSONDecoder().decode(Self.self, from: jsonData)
    }
    init(from dict: Any) throws {
        let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}

class Word: Codable {
    public var text: String
    
    enum CodingKeys: String, CodingKey {
        case text = "word"
    }
    
    init(text:String) {
        self.text = text
    }
}

class Message: Codable {
    var definition: String
    var word: String
    var sender: String?
    var isAbleToBeInteracted: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case word
        case definition
        case sender
    }
    init(definition: String, word: String, sender: String) {
        self.definition = definition
        self.word = word
        self.sender = sender
    }
    
    init(definition: String, word: String) {
        self.definition = definition
        self.word = word
    }
}

class Contact: Codable {
    public var indexOfMessage: Int
    public var estimatedWord: String?
    public var initiator: String?
    public var participants: [String]?
    public var isSuccessful: Bool?
    
    enum CodingKeys: String, CodingKey {
        case indexOfMessage = "index_of_message"
        case estimatedWord = "estimated_word"
        case isSuccessful = "is_successful"
        case initiator
        case participants
    }
    
    init(indexOfMessage: Int, estimatedWord: String) {
        self.indexOfMessage = indexOfMessage
        self.estimatedWord = estimatedWord
    }
    
//    required public init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        estimatedWord = try values.decodeIfPresent(String.self, forKey: .estimatedWord)
//        initiator = try values.decodeIfPresent(String.self, forKey: .initiator)
//        participants = try values.decodeIfPresent([String].self, forKey: .participants)
//        indexOfMessage = try values.decodeIfPresent(Int.self, forKey: .indexOfMessage)!
//    }
}

struct Participant: Codable {
    let playerId: String
}

class Session: Codable {
    public var key: String
    
    enum CodingKeys: String, CodingKey {
        case key = "session"
    }
    
    public var playerId: String {
        get {
            let playerIdStartIndex = self.key.index(
                self.key.startIndex, offsetBy: SESSION_PLAYER_ID_START_INDEX)
            
            return String(self.key.suffix(from: playerIdStartIndex))
        }
    }
    
    public var roomId: String {
        get {
            let roomIdEndIndex = self.key.index(
                self.key.startIndex, offsetBy: SESSION_PLAYER_ID_START_INDEX)
            
            return String(self.key.prefix(upTo: roomIdEndIndex))
        }
    }
    init(session: String) {
        self.key = session
    }
}

func serializeResponse(action:ServerActionCode, session:Session, data:Codable?) -> JSON {
    guard let data = data else {
        return JSON(["code":action.rawValue, "session_key":session.key, "data": "empty"]) }
    
    return JSON(["code": action.rawValue, "session_key":session.key, "data": data.dictionary!])
}
