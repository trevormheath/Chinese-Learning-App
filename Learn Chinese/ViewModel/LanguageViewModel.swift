//
//  LanguageViewModel.swift
//  Learn Chinese
//
//  Created by IS 543 on 10/24/24.
//

import SwiftUI

@Observable class LanguageViewModel {
    // MARK: - Properties
    private var lessonPlan: LessonPlan = ChineseLessonPlan()
    
    // MARK: - Model access
    var languageName: String {
        lessonPlan.languageName
    }
    
    var topics: [Language.Topic] {
        lessonPlan.topics
    }
    
    var currentFlashcards: [Language.Term] {
        if let flashcards = lessonPlan.currentFlashcards {
            return flashcards
        }
        return []
    }
    
    var currentQuestions: [Language.QuizItem] {
        if let questions = lessonPlan.currentQuiz {
            return questions
        }
        return []
    }
    var quizBonusTimeRemaining: TimeInterval {
        lessonPlan.bonusTimeRemaining
    }
    var quizBonusTimePercent: Double {
        lessonPlan.bonusRemainingPercent
    }
    
    var currentTopic: Language.Topic {
        if let selectedTopic = lessonPlan.selectedTopic {
            return selectedTopic
        } else {
            return Language.Topic(title: "", lessonText: "", vocabulary: [], quiz: [])
        }
    }
    
    func progress(for title: String) -> Language.Progress {
        if let progressRecord = lessonPlan.progress.first(where: { $0.topicTitle == title}) {
            return progressRecord
        }
        
        let progressRecord = Language.Progress(topicTitle: title)
        lessonPlan.progress.append(progressRecord)
        return progressRecord
    }
    
    // MARK: - User intents
    func toggleLessonRead(for title: String) {
        lessonPlan.toggleLessonRead(for: title)
    }
    func toggleQuizComplete(for title: String) {
        lessonPlan.toggleQuizComplete(for: title)
    }
    func toggleFlashCardsComplete(for title: String) {
        lessonPlan.toggleFlashCardsComplete(for: title)
    }
    
    func saveHighscore(for title: String, with score: Int) {
        lessonPlan.saveLessonHighscore(for: title, with: score)
    }
    
    func selectTopic(_ topic: Language.Topic) {
        lessonPlan.selectTopic(topic)
    }
    
    func createFlashCardDeck(_ vocab: [Language.Term]) {
        lessonPlan.makeFlashcards(vocab)
    }
    
    func createQuizQuestions(_ questions: [Language.QuizItem]) {
        lessonPlan.makeQuiz(questions)
    }
    
    func flip(_ flashCard: Language.Term) {
        withAnimation(.easeIn(duration: 0.05)) {
            lessonPlan.flipCard(flashCard)
        }
    }
    
    func nextQuizQuestion() {
        lessonPlan.nextQuizQuestion()
    }
    
    func pickQuizAnswer(_ answer: Language.QuizItem) -> Int {
        lessonPlan.pickQuizAnswer(answer)
    }
}
