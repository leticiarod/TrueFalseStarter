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
    
    let questionProvider = QuestionProvider()
 
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var firstAnswerButton: UIButton!
    @IBOutlet weak var secondAnswerButton: UIButton!
    @IBOutlet weak var thirdAnswerButton: UIButton!
    @IBOutlet weak var fourthAnswerButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    
    // constraints
    var xConstraint = NSLayoutConstraint()
    var yConstraint = NSLayoutConstraint()
    var firstAnswerButtonHeightConstraint = NSLayoutConstraint()
    var secondAnswerButtonHeightConstraint = NSLayoutConstraint()
    var secondAnswerButtonBottomMarginConstraint = NSLayoutConstraint()
    var secondAnswerButtonTopMarginConstraint = NSLayoutConstraint()
    var playAgainButtonBottomMarginConstraint = NSLayoutConstraint()
    
    // Array containing the answered questions indexes
    
    var answeredQuestionIndexesArray: [Int] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameStartSound()
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
        
    }
    
    func displayAnswer(){
        let answerArrays = questionProvider.randomAnswer(indexOfSelectedQuestion: indexOfSelectedQuestion)
        
        if answerArrays.count == 3 {
            fourthAnswerButton.isHidden = true
            firstAnswerButton.setTitle(answerArrays[0], for: .normal)
            secondAnswerButton.setTitle(answerArrays[1], for: .normal)
            thirdAnswerButton.setTitle(answerArrays[2], for: .normal)
            
            // The constraints for 3-option questions are activated.
            NSLayoutConstraint.activate([xConstraint, yConstraint, firstAnswerButtonHeightConstraint,secondAnswerButtonHeightConstraint, secondAnswerButtonBottomMarginConstraint, secondAnswerButtonTopMarginConstraint])
       }
        else {
            // if amount of answer is 4
            fourthAnswerButton.isHidden = false
            firstAnswerButton.setTitle(answerArrays[0], for: .normal)
            secondAnswerButton.setTitle(answerArrays[1], for: .normal)
            thirdAnswerButton.setTitle(answerArrays[2], for: .normal)
            fourthAnswerButton.setTitle(answerArrays[3], for: .normal)
            
            // The constraints for 3-option questions are deactivated since at this point we are on the case of 4-option questions.
            NSLayoutConstraint.deactivate([xConstraint, yConstraint, firstAnswerButtonHeightConstraint,secondAnswerButtonHeightConstraint, secondAnswerButtonBottomMarginConstraint, secondAnswerButtonTopMarginConstraint])
        }
    }
    
    func displayScore() {
        // Hide the answer buttons
        firstAnswerButton.isHidden = true
        secondAnswerButton.isHidden = true
        thirdAnswerButton.isHidden = true
        fourthAnswerButton.isHidden = true
        correctAnswerLabel.isHidden = true
        
        // Display play again button
        playAgainButton.isHidden = false
        
        questionField.text = "Way to go!\nYou got \(correctQuestions) out of \(questionsPerRound) correct!"
        
    }
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        // Increment the questions asked counter
        questionsAsked += 1
        
        // Obtains the correct answer from the QuestionProvider given the index in wich is the actual question.
        let correctAnswer = questionProvider.getCorrectAnswerByQuestion(in: indexOfSelectedQuestion)
      
        if (sender === firstAnswerButton &&  firstAnswerButton.titleLabel?.text == correctAnswer) ||
            (sender === secondAnswerButton && secondAnswerButton.titleLabel?.text == correctAnswer) ||
            (sender === thirdAnswerButton &&  thirdAnswerButton.titleLabel?.text == correctAnswer) ||
        (sender === fourthAnswerButton &&  fourthAnswerButton.titleLabel?.text == correctAnswer)
        {
            correctQuestions += 1
            correctAnswerLabel.text = "Correct!"
        } else {
            correctAnswerLabel.text = "Sorry, that's not it!"
        }
        loadNextRoundWithDelay(seconds: 2)
    }
    
    func nextRound() {
        if questionsAsked == questionsPerRound {
            // Game is over
            displayScore()
        } else {
            // Continue game
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
    
    func loadGameStartSound() {
        let pathToSoundFile = Bundle.main.path(forResource: "GameSound", ofType: "wav")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
    
    func createConstraintsThreeOptionsQuestions(){
        
        // The necessary constraints are created to have 3 options displayed on the screen.
        xConstraint = NSLayoutConstraint(item: secondAnswerButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        yConstraint = NSLayoutConstraint(item: secondAnswerButton, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        firstAnswerButtonHeightConstraint = NSLayoutConstraint(item: firstAnswerButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 32)
        secondAnswerButtonHeightConstraint = NSLayoutConstraint(item: secondAnswerButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 32)
        secondAnswerButtonBottomMarginConstraint = NSLayoutConstraint(item: secondAnswerButton, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: thirdAnswerButton, attribute: .bottom, multiplier: 1, constant: 90)
        secondAnswerButtonTopMarginConstraint = NSLayoutConstraint(item: secondAnswerButton, attribute: .top, relatedBy: .lessThanOrEqual, toItem: firstAnswerButton, attribute: .top, multiplier: 1, constant: 90)
       // playAgainButtonBottomMarginConstraint = NSLayoutConstraint(item: playAgainButton, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 60)
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
}

