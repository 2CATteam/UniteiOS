//
//  ToDoButtonView.swift
//  Unite Client
//
//  Created by Daniel Royer on 9/3/18.
//  Copyright © 2018 Union Interpretation Team (UnITe). All rights reserved.
//

import UIKit

class ToDoButton: UIView {
    
    let nibName = "ToDoButtonView"
    
    var toDoText = "Placeholder Text"
    var isDone = false
    
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var Button: UIButton!
    var view: UIView!

    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
        xibSetUp()
    }
    override init(frame:CGRect) {
        super.init(frame:frame)
        xibSetUp()
    }
    
    init(frame:CGRect, toDoSet: String, isDoneSet: Bool) {
        super.init(frame:frame)
        xibSetUp()
        toDoText = toDoSet
        isDone = isDoneSet
        Button.setTitle(toDoText, for: .normal)
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 3
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        
    }
    
    func xibSetUp() {
        Bundle.main.loadNibNamed("ToDoButtonView", owner: self, options: nil)
        addSubview(ContentView)
        ContentView.frame = self.bounds
        ContentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        self.removeFromSuperview()
        let url = URL(string: "https://uniteserver.herokuapp.com")
        var json = [String:Any]()
        
        json[toDoText] = true
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            var request = URLRequest(url: url!)
            request.httpMethod = "DELETE"
            request.httpBody = data
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        } catch {
            
        }
    }
    
    @IBAction func toggleIsDone(_ sender: UIButton) {
        isDone = !isDone
        if (isDone)
        {
            Button.backgroundColor = UIColor.green
        }
        else
        {
            Button.backgroundColor = UIColor.red
        }
        let url = URL(string: "https://uniteserver.herokuapp.com")
        var json = [String:Any]()
        
        json[toDoText] = isDone
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            var request = URLRequest(url: url!)
            request.httpMethod = "PUT"
            request.httpBody = data
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        } catch {
            
        }
        sender.setNeedsDisplay()
        self.superview?.setNeedsLayout()
    }
    
}
