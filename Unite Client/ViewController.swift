//
//  ViewController.swift
//  Unite Client
//
//  Created by Daniel Royer on 8/10/18.
//  Copyright © 2018 Union Interpretation Team (UnITe). All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //References to items in the storyboard
    @IBOutlet weak var scrollContainer: UIScrollView!
    @IBOutlet weak var buttonCollector: UIStackView!
    @IBOutlet weak var refreshButton: UIButton!
    
    //Arrays that together make up an ordered pseudo-dictionary
    var toDos: [String] = []
    var states: [Bool] = []
    
    override func viewDidLoad() {
        refreshButton.addTarget(self, action: #selector(updateButtonSet), for: .touchUpInside)
        updateButtonSet()
    }
    
    @objc func updateButtonSet()
    {
        //Builds a GET request to a server with the To-Dos and states
        let url = URL(string: "https://uniteserver.herokuapp.com")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //Constructs the task from the request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //Parses data into the toDos and states fields
            guard data != nil else {return}
            let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
            self.toDos = jsonObj?.allKeys as! [String]
            self.toDos.sort()
            self.states = [Bool](repeating: true, count: self.toDos.endIndex)
            for x in self.toDos.startIndex..<self.toDos.endIndex
            {
                self.states[x] = jsonObj?.value(forKey: self.toDos[x]) as! Bool
            }
            //DispatchQueue.main.async {
            
                //Refreshes the views
                self.redrawAllButtons()
                print("Updated")
            //}
        }
        //Starts the task
        task.resume()
    }
    
    func redrawAllButtons()
    {
        print(self.toDos)
        print(self.states)
        DispatchQueue.main.async {
        let buttons = self.buttonCollector.arrangedSubviews as! [UIButton]
            //Loop through the data keys array, to show the data on screen
        for x in self.toDos.startIndex..<self.toDos.endIndex
        {
            //If there is no next button, make one with the needed values
            if (x >= buttons.endIndex)
            {
                self.buildToDo(toDoSet: self.toDos[x], isDoneSet: self.states[x])
            }
                //If there is a next button, make it match the keys and value
            else
            {
                print("Editing current button")
                let button = buttons[x]
                DispatchQueue.main.async {
                    button.setTitle(self.toDos[x], for: .normal)
                }
                if (self.states[x])
                {
                    //If the task is done, make the button green
                    DispatchQueue.main.async {
                        print("Making a green button")
                        button.layer.backgroundColor = UIColor.green.cgColor
                        button.setNeedsDisplay()
                        print("Made a green button")
                    }
                    
                }
                else
                {
                    //If the task is not done, make it be red
                    DispatchQueue.main.async {
                        print("Making a red button")
                        button.layer.backgroundColor = UIColor.red.cgColor
                        button.setNeedsDisplay()
                    }
                }
            }
        }
            //Trim off any extra buttons
        if (self.toDos.endIndex <= buttons.endIndex)
        {
            print("Trimming buttons")
            for x in self.toDos.endIndex..<buttons.endIndex
            {
                DispatchQueue.main.async {
                    self.buttonCollector.removeArrangedSubview(buttons[x])
                    self.buttonCollector.setNeedsDisplay()
                }
            }
        }
        self.buttonCollector.reloadInputViews()
        self.buttonCollector.setNeedsDisplay()
        print(self.toDos)
        print(self.states)
        }
        print("Out")
    }
    
    func addNewToDo(toDoSet: String) {
        //Construct a PUT request with the new toDo, initialized to be not done.
        let url = URL(string: "https://uniteserver.herokuapp.com")
        var json = [String:Any]()
        
        json[toDoSet] = false
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            var request = URLRequest(url: url!)
            request.httpMethod = "PUT"
            request.httpBody = data
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request){ (data, response, error) in
                //Parse the data in the response and update the UI based on that
                guard data != nil else {return}
                let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                self.toDos = jsonObj?.allKeys as! [String]
                self.toDos.sort()
                self.states = [Bool](repeating: true, count: self.toDos.endIndex)
                for x in self.toDos.startIndex..<self.toDos.endIndex
                {
                    self.states[x] = jsonObj?.value(forKey: self.toDos[x]) as! Bool
                }
                //DispatchQueue.main.async {
                    self.redrawAllButtons()
                //}
            }
            task.resume()
        } catch {
            
        }
    }
    
    @objc func toggleButton(sender: UIButton!) {
        //Get button information to send a PUT request to switch the button state when pressed
        let toDoName = sender.title(for: .normal)
        let url = URL(string: "https://uniteserver.herokuapp.com")
        var json = [String:Any]()
        
        let index = toDos.index(of: toDoName!)
        
        states[index!] = !states[index!]
        
        //Commented out section seems to have no effect
        
        /*DispatchQueue.main.async {
         if (self.states[index!])
         {
         sender.layer.backgroundColor = UIColor.green.cgColor
         sender.layer.setNeedsDisplay()
         }
         else
         {
         sender.layer.backgroundColor = UIColor.red.cgColor
         sender.layer.setNeedsDisplay()
         }
         }*/
        
        json[toDoName!] = states[index!]
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            var request = URLRequest(url: url!)
            request.httpMethod = "PUT"
            request.httpBody = data
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                //Parse data and update UI based on response
                guard data != nil else {return}
                let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                self.toDos = jsonObj?.allKeys as! [String]
                self.toDos.sort()
                for x in self.toDos.startIndex..<self.toDos.endIndex
                {
                    self.states[x] = jsonObj?.value(forKey: self.toDos[x]) as! Bool
                }
                //DispatchQueue.main.async {
                    self.redrawAllButtons()
                //}
            }
            task.resume()
        } catch {
            
        }
    }
    
    func buildToDo(toDoSet: String, isDoneSet: Bool) {
        //Add a new button to the stack view with the necessary title, color, actions, and constraints
        DispatchQueue.main.async {
            print("Making new button")
            let toAdd = self.newButton(toDo: toDoSet, isDone: isDoneSet)
            self.buttonCollector.addArrangedSubview(toAdd)
            let xConstraint = NSLayoutConstraint(item: toAdd, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.buttonCollector, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            self.buttonCollector.addConstraint(xConstraint)
            let widthConstraint = NSLayoutConstraint(item: toAdd, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.size.width)
            self.buttonCollector.addConstraint(widthConstraint)
            let heightConstraint = NSLayoutConstraint(item: toAdd, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 50)
            toAdd.addConstraint(heightConstraint)
        }
    }
    
    func newButton(toDo: String, isDone: Bool) -> UIButton
    {
        //Make a new button to return
        let toReturn = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        //Set button action
        toReturn.addTarget(self, action: #selector(toggleButton), for: .touchUpInside)
        
        //Create and add a swipe gesture recognizer
        let swiper = UISwipeGestureRecognizer(target: self, action: #selector(self.doSwipe))
        swiper.delegate = self
        swiper.direction = .left
        toReturn.addGestureRecognizer(swiper)
        
        //Set the button title and color
        toReturn.setTitle(toDo, for: .normal)
        if (isDone)
        {
            toReturn.layer.backgroundColor = UIColor.green.cgColor
        }
        else {
            toReturn.layer.backgroundColor = UIColor.red.cgColor
        }
        
        //Make the button look good
        toReturn.layer.cornerRadius = 10
        toReturn.layer.borderWidth = 2
        toReturn.layer.borderColor = UIColor.white.cgColor
        toReturn.layer.shadowColor = UIColor.black.cgColor
        toReturn.layer.shadowOpacity = 0.6
        toReturn.layer.shadowRadius = 3
        toReturn.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        //Return
        return toReturn
    }
    
    @objc func doSwipe(sender: UIGestureRecognizer!)
    {
        //Sends a DELETE request to remove the toDo when swiped
        let url = URL(string: "https://uniteserver.herokuapp.com")
        var json = [String:Any]()
        
        //First must get name of toDo by accessing the button tied to the swipeGestureRecognizer
        if (sender.view?.isKind(of: UIButton.self))!
        {
            let button = sender.view as! UIButton
            json[button.title(for: .normal)!] = true
            do {
                
                let data = try JSONSerialization.data(withJSONObject: json, options: [])
                var request = URLRequest(url: url!)
                request.httpMethod = "DELETE"
                request.httpBody = data
                
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                    //Parse response data and redraw buttons based on result
                    guard data != nil else {return}
                    print(String(data: data!, encoding: .utf8)!)
                    let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                    self.toDos = jsonObj?.allKeys as! [String]
                    self.toDos.sort()
                    for x in self.toDos.startIndex..<self.toDos.endIndex
                    {
                        self.states[x] = jsonObj?.value(forKey: self.toDos[x]) as! Bool
                    }
                    //DispatchQueue.main.async {
                        self.redrawAllButtons()
                    //}
                }
                
                task.resume()
            } catch {
                
            }
            DispatchQueue.main.async() {
                self.buttonCollector.removeArrangedSubview(sender.view!)
            }
        }
        else
        {
            print("ERROR! THIS IS NOT A BUTTON!")
        }
    }
    
    @IBAction func addButtonPushed(_ sender: UIButton!) {
        //Throw up an alert asking for a new toDo, then add it initialized to false
        let alert = UIAlertController(title: "Enter To-Do", message: "Please type the name of this list item the way you would like it to appear on your list", preferredStyle: .alert)
        alert.addTextField {
            (textField) in textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.addNewToDo(toDoSet: (textField?.text!)!)
            print("Text field: \(textField?.text ?? "null")")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            [weak alert] (_) in
            let textField = alert?.textFields![0]
            print("Text field: \(textField?.text ?? "null")")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

