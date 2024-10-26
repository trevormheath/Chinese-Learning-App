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
    
    func getSelectedTopicName() -> String? {
        lessonPlan.selectedTopic?.title
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
    
    func selectTopic(_ topic: Language.Topic) {
        lessonPlan.selectTopic(topic)
    }
    
    func createFlashCardDeck(_ cards: [Language.Term]) {
        lessonPlan.makeFlashcards(cards)
    }
    
    func flip(_ flashCard: Language.Term) {
        withAnimation(.easeIn(duration: 0.05)) {
            lessonPlan.flipCard(flashCard)
        }
    }
    
    
    // MARK: - Private helpers
}
