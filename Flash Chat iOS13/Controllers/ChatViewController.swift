//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase
class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    let db = Firestore.firestore()
    var messages : [Message] = [
        Message(sender: "1@2.com",body:"Hey!"),
        Message(sender: "a@b.com",body:"Hello!"),
        Message(sender: "1@2.com",body:"What's up?")
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        title = K.appName
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessages()
    }
    func loadMessages(){
        
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener{
            (querySnapshot,error) in
            if let e = error{
                print(e.localizedDescription)
            }
            else{
                self.messages = []
                if let snapshotdocuments = querySnapshot?.documents{
                    for doc in snapshotdocuments{
                        let data = doc.data()
                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String{
                            self.messages.append(Message(sender: messageSender, body: messageBody))
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
                }
            }
        }
    }
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text,let messageSender = Auth.auth().currentUser?.email{
            db.collection(K.FStore.collectionName).addDocument(data: [
                    K.FStore.senderField : messageSender,
                    K.FStore.bodyField : messageBody,
                   K.FStore.dateField: Date().timeIntervalSince1970]
            ){(error) in
                if let e = error{
                    print("There was an issue saving your data to firestore \(e.localizedDescription)")
                }
                else{
                    self.messageTextfield.text = ""
                    print("Successfully saved data")
                }
            }
        }
    }
    

    @IBAction func logOutPressed(_ sender: UIBarButtonItem){
       do {
         try Auth.auth().signOut()
       } catch let signOutError as NSError {
         print ("Error signing out: %@", signOutError)
       }
        navigationController?.popToRootViewController(animated: true)
    }
}

extension ChatViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for : indexPath) as! MessageCell
        cell.label.text = messages[indexPath.row].body
        
        if message.sender == Auth.auth().currentUser?.email{
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }
        else{
            cell.rightImageView.isHidden = true
            cell.leftImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
        return cell
    }
    
    
}
