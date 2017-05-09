//
//  QuestionProvider.swift
//  TrueFalseStarter
//
//  Created by Leticia Rodriguez on 5/6/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import GameplayKit

struct QuestionProvider {
    // It is assumed that the correct answers are always in the first position of the array.
    let trivia: [[String : [String]]] = [
        ["Question": ["Only female koalas can whistle"], "Answer": ["koalas1", "koalas2", "koalas3", "koalas4"], "CorrectAnswer": ["koalas2"]],
        ["Question": ["Blue whales are technically whales"], "Answer": ["whales1", "whales2","whales3"], "CorrectAnswer": ["whales3"]],
        ["Question": ["Camels are cannibalistic"], "Answer": ["Camels1", "Camels2", "Camels3", "Camels4"], "CorrectAnswer": ["Camels4"]],
        ["Question": ["All ducks are birds"], "Answer": ["ducks1", "ducks2", "ducks3"], "CorrectAnswer": ["ducks1"]]
    ]
    
    func randomIndexOfSelectedQuestion() -> Int {
        let indexOfSelectedQuestion = GKRandomSource.sharedRandom().nextInt(upperBound: trivia.count)
        
        return indexOfSelectedQuestion
    }
    
    func randomQuestion(indexOfSelectedQuestion: Int) -> String {
        let question = ""
        let questionDictionary = trivia[indexOfSelectedQuestion]
        
        if let question = questionDictionary["Question"] {
            return question[0]
        }
        else{
            return question
        }
    }
    
    func randomAnswer(indexOfSelectedQuestion: Int) -> [String] {
        let answer: [String] = Array()
        let questionDictionary = trivia[indexOfSelectedQuestion]
        
        if let answer = questionDictionary["Answer"] {
            return answer
        }
        else{
            return answer
            }
    }

}
