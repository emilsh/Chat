//
//  ChatViewController.swift
//  Chat
//
//  Created by Emil Shafigin on 3/11/17.
//  Copyright © 2017 emksh. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var nickname: String!
    var chatMessages = [[String: Any]]()
    var users = [[String:Any]]()

    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var tvMsg: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if nickname == nil {
            askForNickname()
        }
        
        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) in
            DispatchQueue.main.async {
                self.chatMessages.append(messageInfo)
                self.tblChat.reloadData()
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func askForNickname() {
        let alertController = UIAlertController(title: "Chat", message: "Введите Ваше имя:", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField(configurationHandler: nil)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) in
            
            let textField = alertController.textFields![0]
            
            if textField.text?.characters.count == 0 {
                self.askForNickname()
            } else {
                self.nickname = textField.text
                
                SocketIOManager.sharedInstance.connectToServerWithNickname(nickname: self.nickname, completionHandler: { (userList) in
                    DispatchQueue.main.async { () -> Void in
                        if userList != nil {
                            self.users = userList
                            
                        }
                    }
                })
            }
            
        }
        
        alertController.addAction(OKAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func sendMsg(_ sender: Any) {
        
        if tvMsg.text.characters.count > 0 {
            SocketIOManager.sharedInstance.sendMessage(message: tvMsg.text, nickname: nickname)
            tvMsg.text = ""
            tvMsg.becomeFirstResponder()
        }
    }
    
    //TableViewDatasource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath) as! ChatCell
        
        let currentChatMessage = chatMessages[indexPath.row]
        let senderNickname = currentChatMessage["nickname"] as! String
        let message = currentChatMessage["message"] as! String
        let messageDate = currentChatMessage["date"] as! String
        
        if senderNickname == nickname {
            cell.msgLabel.textAlignment = NSTextAlignment.right
            cell.msgDetailsLabel.textAlignment = NSTextAlignment.right
            cell.msgLabel.textColor = UIColor.green
        }
        
        cell.msgLabel.text = message
        cell.msgDetailsLabel.text = "\(senderNickname) @ \(messageDate)"
        
        return cell
    }
    
    //TableViewDelegate methods
    
    
    
    
}
