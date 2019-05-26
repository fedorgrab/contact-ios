//
//  Layout.swift
//  Contact-2.0
//
//  Created by Fedor on 13/04/2019.
//  Copyright © 2019 Fedor. All rights reserved.
//

import Foundation
import UIKit

extension GameViewController {
    
    func setUpGameMakerView() {
        setUpTableView()
        setUpWordLabel()
        buttonAlert(title: "Think of a word!", placeholder: "type a word here") { word in
            Server.thinkOfAWord(word: word)
        }
    }
    
    func setUpPlayerView() {
        setUpTableView()
        setUpDefinitionTextField()
        setUpWordTextField()
        setUpButton()
        setUpWordLabel()
    }
    
    func setUpButton() {
        sendButton = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
        sendButton.backgroundColor = UIColor.green
        sendButton.setTitle("Click Me", for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
        sendButton.tag = 1
        self.view.addSubview(sendButton)
        //Cornstarits
//        sendButton.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 10.0).isActive = true
//        sendButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10.0).isActive = true
//        sendButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10.0).isActive = true
//        sendButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        
    }
    
    func setUpDefinitionTextField() {
        definitionTextField = UITextField()
        definitionTextField.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(definitionTextField)
        definitionTextField.backgroundColor = UIColor.lightGray
        definitionTextField.placeholder = "Type a definition here"
        
        //Cornstarits
        definitionTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10.0).isActive = true
        definitionTextField.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10.0).isActive = true
        definitionTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10.0).isActive = true
        definitionTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    func setUpWordTextField() {
        wordTextField = UITextField()
        wordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(wordTextField)
        wordTextField.backgroundColor = UIColor.lightGray
        wordTextField.placeholder = "type a word here"
        
        //Cornstraits
        wordTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10.0).isActive = true
        wordTextField.topAnchor.constraint(equalTo: definitionTextField.bottomAnchor, constant: 10.0).isActive = true
        wordTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10.0).isActive = true
        definitionTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    func setUpTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        
        // constrain the table view
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32.0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -230.0).isActive = true
        
        // set delegate and datasource
        tableView.delegate = self
        tableView.dataSource = self
        
        // register a defalut cell
        tableView.register(ContactCell.self, forCellReuseIdentifier: "cell")
    }
    
    func setUpWordLabel() {
        wordLabel = UILabel()
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wordLabel)
        wordLabel.textAlignment = .center
        wordLabel.backgroundColor = UIColor.lightGray
        
        //Cornstraits
        wordLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        wordLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        wordLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        wordLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
}


extension ContactCell {
    
    func setUpButton() {
        if contactCellButton == nil {
            contactCellButton = UIButton()
            contactCellButton.tag = 111;
            contentView.addSubview(contactCellButton)
            contactCellButton.translatesAutoresizingMaskIntoConstraints = false
            contactCellButton.titleLabel?.numberOfLines = 0
            contactCellButton.titleLabel?.adjustsFontSizeToFitWidth = true
            contactCellButton.titleLabel?.minimumScaleFactor = 0.5
            contactCellButton.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
            switch playerType {
            case .none:
                print("player type in contact cell is not defined")
            case .some(.player):
                contactCellButton.backgroundColor = UIColor.blue
                contactCellButton.setTitle("Contact", for: .normal)
            case .some(.gameMaker):
                contactCellButton.backgroundColor = UIColor.red
                contactCellButton.setTitle("Cancel", for: .normal)
            }
        }
        //    //Cornstraints
        contactCellButton.rightAnchor.constraint(equalTo: rightAnchor, constant: 5).isActive = true
        contactCellButton.leftAnchor.constraint(equalTo: definitionLabel.rightAnchor, constant: 5).isActive = true
        contactCellButton.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        contactCellButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
    }
    
    func unSetUpButton() {
        print("Contact cell button is nil")
        contactCellButton.isHidden = true
        contactCellButton.removeFromSuperview()
    }
    
    func setUpDefinitionLabel() {
        definitionLabel = UILabel()
        definitionLabel.translatesAutoresizingMaskIntoConstraints = false
        definitionLabel.numberOfLines = 0
        addSubview(definitionLabel)
        definitionLabel.backgroundColor = UIColor.gray
        
        //Cornstraints
        definitionLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        definitionLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -45).isActive = true
        definitionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        definitionLabel.bottomAnchor.constraint(equalTo: topAnchor, constant: 25).isActive = true
    }
}

