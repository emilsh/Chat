//
//  SocketIOManager.swift
//  Chat
//
//  Created by Emil Shafigin on 3/11/17.
//  Copyright © 2017 emksh. All rights reserved.
//

import UIKit

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    //Change IP address to your server's IP
    var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: "http://192.168.0.102:3000")!)
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func connectToServerWithNickname(nickname: String, completionHandler: @escaping ([[String: Any]]!) -> Void) {
        socket.emit("connectUser", nickname)
        
        socket.on("userList") { (dataArray, ack) in
            completionHandler(dataArray[0] as! [[String:Any]])
        }
        
        listenForOtherMessages()
    }
    
    func exitChatWithNickname(nickname: String, completionHandler: () -> Void) {
        socket.emit("exitUser", nickname)
        completionHandler()
    }
    
    func sendMessage(message: String, nickname: String) {
        socket.emit("chatMessage", nickname, message)
    }
    
    func getChatMessage(completionHandler: @escaping ([String: Any]) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) in
            var messageDictionary = [String: Any]()
            messageDictionary["nickname"] = dataArray[0] as! String
            messageDictionary["message"] = dataArray[1] as! String
            messageDictionary["date"] = dataArray[2] as! String
            
            completionHandler(messageDictionary)
        }
    }
    
    private func listenForOtherMessages() {
        socket.on("userConnectUpdate") { (dataArray, socketAck) in
            NotificationCenter.default.post(name: Notification.Name("userWasConnectedNotification"), object: dataArray[0] as! [String:Any])
        }
        
        socket.on("userExitUpdate") { (dataArray, socketAck) in
            NotificationCenter.default.post(name: Notification.Name("userWasDisconnectedNotification"), object: dataArray[0] as! String)
        }
        
        socket.on("userTypingUpdate") { (dataArray, socketAck) in
            NotificationCenter.default.post(name: Notification.Name("userTypingNotification"), object: dataArray[0] as! [String:Any])
        }
    }
    
    func sendStartTypingMessage(nickname: String) {
        socket.emit("startType", nickname)
    }
    
    func sendStopTypingMessage(nickname: String) {
        socket.emit("stopType", nickname)
    }
}
