//
//  ViewController.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 24.01.2026.
//

import UIKit

final class ViewController: UIViewController {

    override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = UIColor(red: 18/255, green: 20/255, blue: 24/255, alpha: 1)
            
            
            let imageView = UIImageView(image: UIImage(named: "Photo"))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 35
            imageView.clipsToBounds = true
            imageView.backgroundColor = .systemGray
            view.addSubview(imageView)
            
  
            let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Exit"), for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

            
            button.tintColor = .systemRed
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
         
            let nameLabel = UILabel()
            nameLabel.text = "Екатерина Новикова"
            nameLabel.textColor = .white
            nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            
           
            let usernameLabel = UILabel()
            usernameLabel.text = "@ekaterina_nov"
            usernameLabel.textColor = .systemGray
            usernameLabel.font = .systemFont(ofSize: 13)
            usernameLabel.translatesAutoresizingMaskIntoConstraints = false
            
            
            let bioLabel = UILabel()
            bioLabel.text = "Hello, world!"
            bioLabel.textColor = .white
            bioLabel.font = .systemFont(ofSize: 13)
            bioLabel.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(nameLabel)
            view.addSubview(usernameLabel)
            view.addSubview(bioLabel)
            
            
            NSLayoutConstraint.activate([
                
                imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                imageView.widthAnchor.constraint(equalToConstant: 70),
                imageView.heightAnchor.constraint(equalToConstant: 70),
                
                // Button
                button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
                
                // Name
                nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
                
                // Username
                usernameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
                
                // Bio
                bioLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8)
            ])
        }
    }
