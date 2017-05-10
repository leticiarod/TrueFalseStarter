//
//  ViewController.swift
//  TrueFalseStarter
//
//  Created by Pasan Premaratne on 3/9/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import UIKit
import GameKit
import AudioToolbox


class ViewController: UIViewController {
    // initial code
    let questionsPerRound = 4
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedQuestion: Int = 0
    
    var gameSound: SystemSoundID = 0
    var gameCorrectAnswerSound: SystemSoundID = 0
    var gameIncorrectAnswerSound: SystemSoundID = 0
    var gameEndOfGameSound: SystemSoundID = 0
    var gameErrorGameSound: SystemSoundID = 0
    var gameLoserSound: SystemSoundID = 0
    var gameBadassVictorySound: SystemSoundID = 0
    
    let questionProvider = QuestionProvider()
 
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var firstAnswerButton: UIButton!
    @IBOutlet weak var secondAnswerButton: UIButton!
    @IBOutlet weak var thirdAnswerButton: UIButton!
    @IBOutlet weak var fourthAnswerButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var nextQuestionButton: UIButton!
    @IBOutlet var firstAnswerButtonTopConstraint: NSLayoutConstraint!
    
    // Constraints
    var xConstraint = NSLayoutConstraint()
    var yConstraint = NSLayoutConstraint()
    var firstAnswerButtonHeightConstraint = NSLayoutConstraint()
    var secondAnswerButtonHeightConstraint = NSLayoutConstraint()
    
    // Array containing the answered questions indexes
    var answeredQuestionIndexesArray: [Int] = Array()
    
    var correctAnswer = ""
    var task = DispatchWorkItem(block: {()})
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameSounds()
        // Start game
        playGameStartSound()
        // creo las constraints
        createConstraintsThreeOptionsQuestions()
        displayQuestion()
        displayAnswer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayQuestion() {
        
        indexOfSelectedQuestion = questionProvider.randomIndexOfSelectedQuestion()
        var isRepeated = isIndexOfSelectedQuestionRepetead()
        while isRepeated {
            indexOfSelectedQuestion = questionProvider.randomIndexOfSelectedQuestion()
            isRepeated = isIndexOfSelectedQuestionRepetead()
        }
        answeredQuestionIndexesArray.append(indexOfSelectedQuestion)
        let question = questionProvider.randomQuestion(indexOfSelectedQuestion: indexOfSelectedQuestion)
        questionField.text = question
        playAgainButton.isHidden = true
        playAgainButton.isEnabled = false
        nextQuestionButton.isHidden = true
        nextQuestionButton.isEnabled = false
        correctAnswerLabel.isHidden = true
    }
    
    func displayAnswer(){
        
        let answerArrays = questionProvider.randomAnswer(indexOfSelectedQuestion: indexOfSelectedQuestion)
        
        if answerArrays.count == 3 {
            fourthAnswerButton.isHidden = true
            firstAnswerButton.setTitle(answerArrays[0], for: .normal)
            secondAnswerButton.setTitle(answerArrays[1], for: .normal)
            thirdAnswerButton.setTitle(answerArrays[2], for: .normal)
            
            // The constraints for 3-option questions are activated and deactivated.
            NSLayoutConstraint.activate([xConstraint, yConstraint, firstAnswerButtonHeightConstraint,secondAnswerButtonHeightConstraint])
            NSLayoutConstraint.deactivate([firstAnswerButtonTopConstraint])
            
       }
        else {
            // if amount of answer is 4
            fourthAnswerButton.isHidden = false
            firstAnswerButton.setTitle(answerArrays[0], for: .normal)
            secondAnswerButton.setTitle(answerArrays[1], for: .normal)
            thirdAnswerButton.setTitle(answerArrays[2], for: .normal)
            fourthAnswerButton.setTitle(answerArrays[3], for: .normal)
            
            // The constraints for 3-option questions are deactivated (and activated in one case) since at this point we are on the case of 4-option questions.
            NSLayoutConstraint.activate([firstAnswerButtonTopConstraint]) 
            NSLayoutConstraint.deactivate([xConstraint, yConstraint, firstAnswerButtonHeightConstraint,secondAnswerButtonHeightConstraint])
        }
        
        //
        disableButtonsWithDelay(seconds: 5)
    }
    
    func displayScore() {
        
        if correctQuestions == questionsPerRound {
            playBadassVictoryGameSound()
        }
        else {
            if correctQuestions == 0 {
                playloserGameSound()
            }
            else {
                playGameEndOfGameSound()
            }
        }
        
        // Hide the answer buttons
        
        firstAnswerButton.isHidden = true
        secondAnswerButton.isHidden = true
        thirdAnswerButton.isHidden = true
        fourthAnswerButton.isHidden = true
        correctAnswerLabel.isHidden = true
        
        nextQuestionButton.isEnabled = false
        nextQuestionButton.isHidden = true
        
        // Display play again button
        playAgainButton.isHidden = false
        playAgainButton.isEnabled = true
        questionField.text = "Way to go!\nYou got \(correctQuestions) out of \(questionsPerRound) correct!"
        
    }
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        // If an option button is pressed the DispatchWorkItem task is cancelled.
        task.cancel()
        // Obtains the correct answer (the actual question) from the QuestionProvider given the index.
        correctAnswer = questionProvider.getCorrectAnswerByQuestion(in: indexOfSelectedQuestion)
      
        if (sender === firstAnswerButton &&  firstAnswerButton.titleLabel?.text == correctAnswer) ||
            (sender === secondAnswerButton && secondAnswerButton.titleLabel?.text == correctAnswer) ||
            (sender === thirdAnswerButton &&  thirdAnswerButton.titleLabel?.text == correctAnswer) ||
        (sender === fourthAnswerButton &&  fourthAnswerButton.titleLabel?.text == correctAnswer)
        {
            let color = UIColor(red:0.00, green:0.58, blue:0.53, alpha:1.0)
            correctAnswerLabel.textColor = color
            correctQuestions += 1
            correctAnswerLabel.text = "Correct!"
            playGameCorrectAnswerSound()
            
        } else {
            let color = UIColor(red:0.99, green:0.64, blue:0.41, alpha:1.0)
            correctAnswerLabel.textColor = color
            correctAnswerLabel.text = "Sorry, that's not it!"
            playGameIncorrectAnswerSound()
        }
        
        // The style constraints are setted for disabled buttons.
        disableButtons()
       
        // Sets visible the correct answer label
        
        correctAnswerLabel.isHidden = false
    }
    
    func nextRound() {
        if questionsAsked == questionsPerRound {
            // If current round is finished the DispatchWorkItem task is cancelled.
            task.cancel()
            // Game is over
            displayScore()
        } else {
            // Continue game
            enableButtons()
            displayQuestion()
            displayAnswer()
        }
    }
    
    @IBAction func playAgain() {
        // Show the answer buttons
        firstAnswerButton.isHidden = false
        secondAnswerButton.isHidden = false
        thirdAnswerButton.isHidden = false
        fourthAnswerButton.isHidden = false
        correctAnswerLabel.isHidden = false
        
        questionsAsked = 0
        correctQuestions = 0
        answeredQuestionIndexesArray = Array()
        nextRound()
    }
    
    @IBAction func nextQuestion() {
        // Increment the questions asked counter
        questionsAsked += 1
        nextQuestionButton.isEnabled = false
         loadNextRoundWithDelay(seconds: 1)
    }
    
    
    // MARK: Helper Methods
    
    func loadNextRoundWithDelay(seconds: Int) {
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        
        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.nextRound()
        }
    }

    func disableButtonsWithDelay(seconds: Int) {
        // A DispatchWorkItem task is created and assigned it into a global var to be able to run it as well as cancel it (from any part in the code)  if necessary.
        task = DispatchWorkItem(block: {self.disableButtons(); self.playErrorGameSound()})
        
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        
        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: task)
        
    }

    func loadGameSounds() {
        let pathToSoundFile = Bundle.main.path(forResource: "GameSound", ofType: "wav")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSound)
        
        let pathToCorrectAnswerSoundFile = Bundle.main.path(forResource: "CorrectAnswer", ofType: "wav")
        let correctAnswerSoundURL = URL(fileURLWithPath: pathToCorrectAnswerSoundFile!)
        AudioServicesCreateSystemSoundID(correctAnswerSoundURL as CFURL, &gameCorrectAnswerSound)
        
        let pathToIncorrectAnswerSoundFile = Bundle.main.path(forResource: "IncorrectAnswer", ofType: "wav")
        let incorrectAnswerSoundURL = URL(fileURLWithPath: pathToIncorrectAnswerSoundFile!)
        AudioServicesCreateSystemSoundID(incorrectAnswerSoundURL as CFURL, &gameIncorrectAnswerSound)
        
        let pathToEndOfGameSoundFile = Bundle.main.path(forResource: "EndOfGame", ofType: "wav")
        let endOfGameSoundURL = URL(fileURLWithPath: pathToEndOfGameSoundFile!)
        AudioServicesCreateSystemSoundID(endOfGameSoundURL as CFURL, &gameEndOfGameSound)
        
        let pathToErrorSoundFile = Bundle.main.path(forResource: "ErrorSound", ofType: "wav")
        let errorSoundURL = URL(fileURLWithPath: pathToErrorSoundFile!)
        AudioServicesCreateSystemSoundID(errorSoundURL as CFURL, &gameErrorGameSound)
        
        let pathToLoserSoundFile = Bundle.main.path(forResource: "LoserSound", ofType: "wav")
        let loserSoundURL = URL(fileURLWithPath: pathToLoserSoundFile!)
        AudioServicesCreateSystemSoundID(loserSoundURL as CFURL, &gameLoserSound)
        
        let pathToBadassVictorySoundFile = Bundle.main.path(forResource: "BadassVictory", ofType: "wav")
        let badassVictorySoundURL = URL(fileURLWithPath: pathToBadassVictorySoundFile!)
        AudioServicesCreateSystemSoundID(badassVictorySoundURL as CFURL, &gameBadassVictorySound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
    
    func playGameCorrectAnswerSound() {
        AudioServicesPlaySystemSound(gameCorrectAnswerSound)
    }
    
    func playGameIncorrectAnswerSound() {
        AudioServicesPlaySystemSound(gameIncorrectAnswerSound)
    }
    
    func playGameEndOfGameSound() {
        AudioServicesPlaySystemSound(gameEndOfGameSound)
    }
    
    func playErrorGameSound() {
        AudioServicesPlaySystemSound(gameErrorGameSound)
    }
    func playloserGameSound() {
        AudioServicesPlaySystemSound(gameLoserSound)
    }
    func playBadassVictoryGameSound() {
        AudioServicesPlaySystemSound(gameBadassVictorySound)
    }
    
    func createConstraintsThreeOptionsQuestions(){
        
        // The necessary constraints are created to have 3 options displayed on the screen.
        xConstraint = NSLayoutConstraint(item: secondAnswerButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        yConstraint = NSLayoutConstraint(item: secondAnswerButton, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        firstAnswerButtonHeightConstraint = NSLayoutConstraint(item: firstAnswerButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
        secondAnswerButtonHeightConstraint = NSLayoutConstraint(item: secondAnswerButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
       
    }
    
    func isIndexOfSelectedQuestionRepetead() -> Bool {
        var isRepeated = false
        var i = 0
        while !isRepeated && i < answeredQuestionIndexesArray.count {
            if(answeredQuestionIndexesArray[i] == indexOfSelectedQuestion){
                isRepeated = true
            }
            else {
                i+=1
            }
        }
        return isRepeated
    }
    
    func getButtonForCorrectAnswer(correctAnswer: String) -> UIButton {
        
        if firstAnswerButton.titleLabel?.text == correctAnswer {
            return firstAnswerButton
        }
        else {
            if secondAnswerButton.titleLabel?.text == correctAnswer {
                return secondAnswerButton
            }
            else {
                if thirdAnswerButton.titleLabel?.text == correctAnswer {
                    return thirdAnswerButton
                }
                else {
                    return fourthAnswerButton
                }
            }
        }
    }
    
    func disableButtons() {
        
        // The style constraints are setted for disabled buttons.
        
        // Obtains the correct answer (the actual question) from the QuestionProvider given the index.
        
        correctAnswer = questionProvider.getCorrectAnswerByQuestion(in: indexOfSelectedQuestion)
        
        let correctAnswerButton = getButtonForCorrectAnswer(correctAnswer: correctAnswer)
        
        let backgroundColorDisabledButton = UIColor(red:0.05, green:0.24, blue:0.33, alpha:1.0)
        let textColorDisabledButton = UIColor(red:0.28, green:0.38, blue:0.43, alpha:1.0)
        
        firstAnswerButton.backgroundColor = backgroundColorDisabledButton
        firstAnswerButton.setTitleColor(textColorDisabledButton, for: .normal)
        
        secondAnswerButton.backgroundColor = backgroundColorDisabledButton
        secondAnswerButton.setTitleColor(textColorDisabledButton, for: .normal)
        
        thirdAnswerButton.backgroundColor = backgroundColorDisabledButton
        thirdAnswerButton.setTitleColor(textColorDisabledButton, for: .normal)
        
        fourthAnswerButton.backgroundColor = backgroundColorDisabledButton
        fourthAnswerButton.setTitleColor(textColorDisabledButton, for: .normal)
        
        // A different text color is setted to the correct answer.
        let textColorDisabledButtonCorrectAnswer = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        correctAnswerButton.setTitleColor(textColorDisabledButtonCorrectAnswer, for: .normal)
        
        // The buttons are disabled.
        
        firstAnswerButton.isEnabled = false
        secondAnswerButton.isEnabled = false
        thirdAnswerButton.isEnabled = false
        fourthAnswerButton.isEnabled = false
        firstAnswerButton.isHighlighted = false
        secondAnswerButton.isHighlighted = false
        thirdAnswerButton.isHighlighted = false
        fourthAnswerButton.isHighlighted = false
        
        nextQuestionButton.isHidden = false
        nextQuestionButton.isEnabled = true
        

    }
    
    func enableButtons() {
        // The style constraints are setted for enabled buttons
        let backgroundColorEnabledButton = UIColor(red:0.09, green:0.47, blue:0.58, alpha:1.0)
        let textColorEnabledButton = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        
        firstAnswerButton.backgroundColor = backgroundColorEnabledButton
        firstAnswerButton.setTitleColor(textColorEnabledButton, for: .normal)
        
        secondAnswerButton.backgroundColor = backgroundColorEnabledButton
        secondAnswerButton.setTitleColor(textColorEnabledButton, for: .normal)
        
        thirdAnswerButton.backgroundColor = backgroundColorEnabledButton
        thirdAnswerButton.setTitleColor(textColorEnabledButton, for: .normal)
        
        fourthAnswerButton.backgroundColor = backgroundColorEnabledButton
        fourthAnswerButton.setTitleColor(textColorEnabledButton, for: .normal)
        
        // The buttons are enabled.
        firstAnswerButton.isEnabled = true
        secondAnswerButton.isEnabled = true
        thirdAnswerButton.isEnabled = true
        fourthAnswerButton.isEnabled = true
        
    }

}

