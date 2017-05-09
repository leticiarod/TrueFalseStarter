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
        Question(questionTitle: "Only female koalas can whistle", answerOptions: ["koalas1", "koalas2", "koalas3", "koalas4"], correctAnswer: "koalas2"),
        Question(questionTitle: "Blue whales are technically whales", answerOptions: ["whales1", "whales2","whales3"], correctAnswer: "whales3"),
        Question(questionTitle: "Camels are cannibalistic", answerOptions: ["Camels1", "Camels2", "Camels3", "Camels4"], correctAnswer: "Camels4"),
        Question(questionTitle: "All ducks are birds", answerOptions: ["ducks1", "ducks2", "ducks3"], correctAnswer: "ducks1")
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
