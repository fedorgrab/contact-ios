//
//  Server.swift
//  Contact-2.0
//
//  Created by Fedor on 13/04/2019.
//  Copyright © 2019 Fedor. All rights reserved.
//


import Foundation
import SwiftWebSocket
import SwiftyJSON

//MARK:- Server Delegate protocol
protocol ServerDelegate: NSObjectProtocol {
    
    /// Propertie showing which type of a player is a current player
    var playerType: PlayerType { get set }
    
    /// Is called when message has just been sent from a server
    /// - parameters:
    ///   - message: A Codable based Message serializible model
    func messageWasReceived(_ message: Message)
    
    /// Is called when word is sent from a server
    /// - parameters:
    ///   - word: A Codable based Word serializible model
    func wordWasSet(_ word:Word)
    
    /// Is called after all the players connected to the server and game maker is set
    func gameMakerWasSet()
    
    /// Is called when contact already finished with a contact result
    /// - parameters:
    ///  - contact: a model of contact received from a server
    func contactDidFinished(_ contact: Contact)
    
    /// Is called when someone has just canceled contact
    /// - parameters:
    ///   - indexOfCanceledMessage: index of a message which
    func contactHasHadCanceled(indexOfCanceledMessage: Int)
    
    /// Is called when player has to be refreshed
    func refresh()
    
}

enum ServerActionCode:String {
    case sendMessage = "100"
    case setWord = "200"
    case contact = "300"
    case checkContact = "301"
}

typealias DecodedData = [String: Any]
//MARK:- Server Class
class Server {
    
    static private let ws = WebSocket(LOCAL_WEBSOCKET_URL)
    static weak var delegate: ServerDelegate?
    static private var connectionIsOpened = false
    static private var session: Session?
    
    //MARK:- Sending data to a server
    
    public class func sendMessage(definition: String, word:String) {
        let message = Message(definition: definition, word: word)
        let messageResponse = serializeResponse(action: .sendMessage, session: session!, data: message)
        ws.send(messageResponse)
    }
    
    public class func thinkOfAWord(word: String) {
        let word = Word(text: word)
        let wordResponse = serializeResponse(action: .setWord, session: session!, data: word)
        ws.send(wordResponse)
    }
    
    public class func tryToContact(estimatedWord: String, indexOfMessage: Int) {
        print("word is trying to be contacted is \(estimatedWord) and index is \(indexOfMessage)")
        let contact = Contact(indexOfMessage: indexOfMessage, estimatedWord: estimatedWord)
        let contactReponse = serializeResponse(action: .contact, session: session!, data: contact)
        ws.send(contactReponse)
//        delay(withTime: 5.0, callback: checkWetherThereWasAContact)
    }
    
    public class func cancelContact(estimatedWord: String, index: Int) {
        ws.send("302\(estimatedWord)/\(index)")
    }
    
    public class func checkWetherThereWasAContact() {
        self.ws.send(serializeResponse(action: .checkContact, session: session!, data: nil))
    }
    
    //    MARK:- Delegation
    private class func handleStartGame(data:DecodedData){
        let isGameMaker = data[Server.session!.playerId] as! Bool
        delegate?.playerType = isGameMaker ? .gameMaker : .player
        delegate?.gameMakerWasSet()
    }
    private class func handleSettingSessionKey(_ dict: DecodedData){
        do {
            session = try Session(from: dict)
        } catch {
            print(error.localizedDescription)
        }
    }
    private class func handleWordSetting(data: DecodedData){
        do {
            let word = try Word(from: data)
            delegate?.wordWasSet(word)
        } catch {
            print(error.localizedDescription)
        }
    }
    private class func handleMessageReceiving(_ data: DecodedData){
        do {
            let message = try Message(from: data)
            delegate?.messageWasReceived(message)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    private class func handleContactNotification(_ data: DecodedData){
        do {
            let contact = try Contact(from: data)
            // delegate.handleContactNotification
            delay(withTime: 5.0, callback: checkWetherThereWasAContact)
            print(contact.dictionary!)
        } catch {
            print(error.localizedDescription)
        }
    }
    private class func handleContactAction(_ data: DecodedData){
        do {
            let contact = try Contact(from: data)
            delegate?.contactDidFinished(contact)
        } catch {
            print(error.localizedDescription)
        }
    }
    //MARK:- Recieving data from a server
    class func openConnection(firstMsg message: String) {
        ws.event.open = {
            
            //                        TODO: implement reconnection logic
            let connectJSON = JSON(["code":"000"])
            self.ws.send(connectJSON)
            connectionIsOpened = true
            print("opened")
        }
        ws.event.close = { code, reason, clean in
            print(reason)
            self.ws.open()
        }
        ws.event.error = { error in
            print("error \(error)")
        }
        
        ws.event.message = { frame in
            print("decoded frame: ")
            print(frame)
            let decodedFrame = JSON(parseJSON: frame as! String)
            let code = decodedFrame["code"].string!
            let dictData: [String: Any] = decodedFrame["data"].dictionaryObject!
            
            switch code {
            case "0009":
                handleSettingSessionKey(dictData)
            case "9009":
                handleStartGame(data: dictData)
            case "1009":
                handleMessageReceiving(dictData)
            case "2009":
                handleWordSetting(data: dictData)
            case "3009":
                handleContactNotification(dictData)
            case "3019":
                handleContactAction(dictData)
                
                
                //
                
                //
                //            case "3029":
                //                var arr = decodedFrame.components(separatedBy: "/")
                //                let isCanceled = arr[0] == "1" ? true : false
                //                if isCanceled {
                //                    delegate?.contactHasHadCanceled(indexOfCanceledMessage: Int(arr[1])!)
                //                }
                //
                //            case "3019":
                //                if decodedFrame == "0" {
                //                    Server.delegate?.contactJustNotHappened()
                //                    print("Contact wasn't correct")
                //                } else {
                //                    var arr = decodedFrame.components(separatedBy: "/")
                //                    let indexOfMessageIsTryingToBeContacted = Int(arr[1])
                //                    Server.delegate?.contactJustHappened(indexOfMessage: indexOfMessageIsTryingToBeContacted!)
                //                    print("Contact just happened")
                //                }
                //
                //            case "9999":
                //                Server.delegate?.refresh()
                
            default:
                print("Unpredictable message code")
            }
        }
    }
}
