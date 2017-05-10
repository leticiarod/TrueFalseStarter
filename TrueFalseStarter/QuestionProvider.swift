//
//  QuestionProvider.swift
//  TrueFalseStarter
//
//  Created by Leticia Rodriguez on 5/6/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import GameplayKit

struct Question {
    var questionTitle: String
    var answerOptions: [String]
    var correctAnswer: String
}

struct QuestionProvider {
    
    let trivia: [Question] = [
        Question(questionTitle: "2 + 2?", answerOptions: ["6", "4", "10", "7"], correctAnswer: "4"),
        Question(questionTitle: "4 x 3?", answerOptions: ["8", "3","12"], correctAnswer: "12"),
        Question(questionTitle: "6 + 5?", answerOptions: ["20", "25", "11", "31"], correctAnswer: "11"),
        Question(questionTitle: "28 - 1", answerOptions: ["27", "26", "0"], correctAnswer: "27")
    ]
    
    func randomIndexOfSelectedQuestion() -> Int {
        let indexOfSelectedQuestion = GKRandomSource.sharedRandom().nextInt(upperBound: trivia.count)
        
        return indexOfSelectedQuestion
    }
    
    func randomQuestion(indexOfSelectedQuestion: Int) -> String {
        
        let questionArray = trivia[indexOfSelectedQuestion]
        
       return questionArray.questionTitle
   
    }
    
    func randomAnswer(indexOfSelectedQuestion: Int) -> [String] {
       
        let questionArray = trivia[indexOfSelectedQuestion]
        
        return questionArray.answerOptions
        
    }
    
    func getCorrectAnswerByQuestion(in index: Int) -> String {
        let questionArray = trivia[index]
        
        return questionArray.correctAnswer
    }
}
