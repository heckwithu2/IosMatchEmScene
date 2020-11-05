//
//  ViewController.swift
//  RandomRectangles
//
//  Created by Dale Haverstock on 10/13/20.

//  modified by Jeremiah Heck

//  Copyright © 2020 Emanon. All rights reserved.
//

import UIKit

class GameSceneViewController: UIViewController {
    // MARK: - ==== Config Properties ====
    //================================================
    private var prevRect: UIButton?
    private var isPair:Bool = false
    private var prevColor: UIColor?
    // Min and max width and height for the rectangles
    private let rectSizeMin:CGFloat =  50.0
    private let rectSizeMax:CGFloat = 150.0
    
    // How long for the rectangle to fade away
    private var fadeDuration: TimeInterval = 0.8
    
    // Game duration
    private var gameDuration: TimeInterval = 12.0
    
    // Random transparency on or off
    private var randomAlpha = false
    
    // Rectangle creation interval
    private var newRectInterval: TimeInterval = 1.2
    
    // MARK: - ==== Internal Properties ====
    @IBOutlet weak var gameInfoLabel: UILabel!
    

    private var gameInfo : String {
        let labelText = "Time: \(TimeInterval(gameTimerCounter)) Pairs: \(rectanglesCreated) - Matched: \(rectanglesTouched)"
        return labelText
    }
    
    // Keep track of all rectangles created
    private var rectangles = [UIButton]()
    
    // Rectangle creation, so the timer can be stopped
    private var newRectTimer: Timer?
    
    private var gameTimerCount: Timer?
    
    var gameTimerCounter = 12.0
    // Game timer
    private var gameTimer: Timer?
    
    // A game is in progress
    private var gameInProgress = false
    
    // Counters, property observers used
    private var rectanglesCreated = 0 {
        didSet { gameInfoLabel?.text = gameInfo } }
    
    private var rectanglesTouched = 0 {
        didSet { gameInfoLabel?.text = gameInfo } }

    // MARK: - ==== View Controller Methods ====
    //================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //================================================
    override func viewWillAppear(_ animated: Bool) {
        // Don't forget the call to super in these methods
        super.viewWillAppear(animated)
                        
        // Create rectangles
        startGameRunning()
    }
    
    //================================================
    @objc private func handleTouch(sender: UIButton) {
        //touch stuff
        if !gameInProgress {
            return
        }
        
        
        
        //if the next touch is pair, Then carry on with fade
        if isPair == false {
            //first touch
            //measure and save data
            prevColor = sender.backgroundColor
            sender.setTitle("🐹", for: .normal)
            prevRect = sender
            isPair = true
            return
            
        }
        
        if prevColor == sender.backgroundColor && isPair == true{
            sender.setTitle("🐹", for: .normal)
            isPair = false
            // Remove the rectangle
            removeRectangle(rectangle: sender)
            removeRectangle(rectangle: prevRect!)
            rectanglesTouched += 1
        } else {
            prevRect!.setTitle("", for: .normal)
            isPair = false
        }
      
    }
    
    //================================================
    override var prefersStatusBarHidden: Bool {
               return true
    }
}

// MARK: - ==== Rectangle Methods ====
extension GameSceneViewController {
    //================================================
    private func createRectangle() {
        
        let randSize     = Utility.getRandomSize(fromMin: rectSizeMin,
                                                 throughMax: rectSizeMax)
        
        let color = Utility.getRandomColor(randomAlpha: randomAlpha)

        var i = 0
        while i < 2 {
            // Get random values for size and location
           
            let randLocation = Utility.getRandomLocation(size: randSize,
                                                         screenSize: view.bounds.size)
            let randomFrame  = CGRect(origin: randLocation, size: randSize)
            
            // Create a rectangle
            let rectangle = UIButton(frame: randomFrame)
            
            // Save the rectangle till the game is over
            rectangles.append(rectangle)
                
            // Do some button/rectangle setup
            //rectangle.backgroundColor = Utility.getRandomColor(randomAlpha: randomAlpha)
            rectangle.backgroundColor = color
            
            rectangle.setTitle("", for: .normal)
            rectangle.setTitleColor(.black, for: .normal)
            rectangle.titleLabel?.font = .systemFont(ofSize: 50)
            rectangle.showsTouchWhenHighlighted = true
            
            // Target/action to set up connect of button to the VC
            rectangle.addTarget(self,
                             action: #selector(self.handleTouch(sender:)),
                             for: .touchUpInside)
                
            // Make the rectangle visible
            self.view.addSubview(rectangle)
            
            i += 1
        }
        rectanglesCreated += 1
        // Move label to the front
        view.bringSubviewToFront(gameInfoLabel!)
    }
    
    //================================================
    func removeRectangle(rectangle: UIButton) {
        // Rectangle fade animation
        let pa = UIViewPropertyAnimator(duration: fadeDuration,
                                        curve: .easeInOut,
                                      animations: nil)
        
        pa.addAnimations {
            rectangle.alpha = 0.0
        }
        pa.startAnimation()
    }
    
    //================================================
    func removeSavedRectangles() {
        // Remove all rectangles from superview
        for rectangle in rectangles {
            rectangle.removeFromSuperview()
        }
        
        // Clear the rectangles array
        rectangles.removeAll()
    }
}

// MARK: - ==== Timer Functions ====
extension GameSceneViewController {
    private func runTimer() {
        
        gameTimerCount = Timer.scheduledTimer(withTimeInterval: 1,
                                                  repeats: true)
                                   { _ in self.updateTimer() }
    }
    private func updateTimer() {
        gameTimerCounter -= 1
    }
    //================================================
    private func startGameRunning()
    {
        //
        removeSavedRectangles()
        runTimer()
        // Timer to produce the rectangles
        newRectTimer = Timer.scheduledTimer(withTimeInterval: newRectInterval,
                                     repeats: true)
                                     { _ in self.createRectangle() }
        
    
        // Timer to end the game
        gameTimer = Timer.scheduledTimer(withTimeInterval: gameDuration,
                                                  repeats: false)
                                   { _ in self.stopGameRunning() }
        
        
        gameInProgress = true
    }
    
    //================================================
    private func stopGameRunning() {
        // Stop the timer
        if let timer = newRectTimer { timer.invalidate() }

        // Remove the reference to the timer object
        self.newRectTimer = nil
        
        //
        gameInProgress = false

    }
}

