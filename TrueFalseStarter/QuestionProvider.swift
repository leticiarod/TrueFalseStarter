//
//  QuestionProvider.swift
//  TrueFalseStarter
//
//  Created by Leticia Rodriguez on 5/6/17.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import GameplayKit

struct QuestionProvider {
    let trivia: [[String : String]] = [
        ["Question": "Only female koalas can whistle", "Answer": "False"],
        ["Question": "Blue whales are technically whales", "Answer": "True"],
        ["Question": "Camels are cannibalistic", "Answer": "False"],
        ["Question": "All ducks are birds", "Answer": "True"]
    ]
    
    func randomQuestion() -> String {
        let question = ""
        let indexOfSelectedQuestion = GKRandomSource.sharedRandom().nextInt(upperBound: trivia.count)
        let questionDictionary = trivia[indexOfSelectedQuestion]
        
        if let question = questionDictionary["Question"] {
            return question
        }
        else{
            return question
        }
        
}
}
