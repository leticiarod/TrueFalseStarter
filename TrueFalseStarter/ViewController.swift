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
    
    // constraints
    var xConstraint = NSLayoutConstraint()
    var yConstraint = NSLayoutConstraint()
    var firstAnswerButtonHeightConstraint = NSLayoutConstraint()
    var secondAnswerButtonHeightConstraint = NSLayoutConstraint()
    
    // Array containing the answered questions indexes
    var answeredQuestionIndexesArray: [Int] = Array()
    
    //
    var correctAnswer = ""
    
    //
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
        // Hide the answer buttons
        playGameEndOfGameSound()
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
        //
        task.cancel()
        // Obtains the correct answer from the QuestionProvider given the index in wich is the actual question.
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
        
        // seteo los colores de disabled en los botones
        disableButtons()
       
        //hago visible la correct answer label 
        
        correctAnswerLabel.isHidden = false
        
        // loadNextRoundWithDelay(seconds: 2)
    }
    
    func nextRound() {
        if questionsAsked == questionsPerRound {
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
        task = DispatchWorkItem(block: {self.disableButtons()})
        
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        
        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: task)
        //{
          //  self.disableButtons()
       // }
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
        
        // seteo los colores de disbaled en los botones
        
        // Obtains the correct answer from the QuestionProvider given the index in wich is the actual question.
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
        
        // seteo un color distinto a la respuesta correcta
        let textColorDisabledButtonCorrectAnswer = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
        correctAnswerButton.setTitleColor(textColorDisabledButtonCorrectAnswer, for: .normal)
        
        // inhabilito los botones
        
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
        // seteo los colores de disbaled en los botones
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
        
        // habilito los botones
        
        firstAnswerButton.isEnabled = true
        secondAnswerButton.isEnabled = true
        thirdAnswerButton.isEnabled = true
        fourthAnswerButton.isEnabled = true
        
    }

}

