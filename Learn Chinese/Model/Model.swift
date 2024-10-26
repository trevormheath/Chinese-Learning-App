//
//  Model.swift
//  Learn Chinese
//
//  Created by IS 543 on 10/17/24.
//

import Foundation

struct Language {
    
    struct Topic: Identifiable {
        var id = UUID()
        var title: String
        var lesonText: String
        var vocabulary: [Term]
        var quiz: [QuizItem]
    }
    
//    struct Flashcard<Term> where Term: Identifiable {
//        var cards: Array<Term>
//        
//        init(cards: Array<Term>) {
//            self.cards = cards.shuffled()
//        }
//        
//        mutating func flipCard(_ flashcard: Term) {
//            if let index = cards.firstIndex(where: { $0.id == flashcard.id}) {
//                cards[index]
//            }
//        }
//    }
//    
//    mutating func flipCard(_ flashcard: Term) {
//        if let index = cards.firstIndex(where: { $0.id == flashcard.id}) {
//            cards[index].toggleTargetUp()
//        }
//    }
    
    
    struct Term: Identifiable {
        var id = UUID()
        var targetWord: String
        var pinyin: String
        var translation: String
        var isTargetUp: Bool = true;
    }
    
//    enum QuestionType {
//        case trueFalse
//        case multipleChoice
//        case fillInTheBlank
//    }

    struct QuizItem {
        var question: String
        var answers: [String]? //if array is empty then correctAnswer is fill in the blank
        var correctAnswer: String
//        var questionType: QuestionType
    }
    
    //progress for each lesson
    struct Progress {
        let topicTitle: String
        var lessonRead = false
        var vocabStudied = false
        var quizPassed = false
        var quizHighScore: Int?
    }
    

}

extension Language.Progress: Identifiable {
    var id: String {topicTitle}
}

private func key(for title: String, type: String) -> String {
    "\(title).\(type)"
}

protocol LessonPlan {
    var selectedTopic: Language.Topic? {get set}
    var currentFlashcards: [Language.Term]? {get set}
    var languageName: String {get}
    var topics: [Language.Topic] {get}
    var progress: [Language.Progress] {get set}
    
    mutating func selectTopic(_ title: Language.Topic)
    mutating func flipCard(_ term: Language.Term)
    mutating func toggleLessonRead(for title: String)
    mutating func makeFlashcards(_ terms: [Language.Term])
}

struct ChineseLessonPlan: LessonPlan {
    // MARK: -  Properties
    var selectedTopic: Language.Topic?
    var currentFlashcards: [Language.Term]?
//    var selectedTerm: Language.Term?
    
    let languageName = "Chinese"
    let topics = Data.chineseTopics
    
    var progress: [Language.Progress] = ChineseLessonPlan.readProgressRecords()
    
    // MARK: - Helpers
    mutating func selectTopic(_ topic: Language.Topic) {
        selectedTopic = topic
//        selectedTerm = nil
    }
//    mutating func selectTerm(_ term: Language.Term) {
//        selectedTerm = term
//    }
    
    mutating func flipCard(_ term: Language.Term) {
        if var flashcards = currentFlashcards, let index = flashcards.firstIndex(where: {$0.id == term.id}) {
            flashcards[index].isTargetUp.toggle()
            currentFlashcards = flashcards
            print("flip", flashcards[index].targetWord)
        }
    }
    
    mutating func makeFlashcards(_ terms: [Language.Term]) {
        currentFlashcards = terms.shuffled()
    }
    
    mutating func toggleLessonRead(for title: String) {
        if let index = progress.firstIndex(where: {$0.topicTitle == title}) {
            progress[index].lessonRead.toggle()
            UserDefaults.standard
                .set(
                    progress[index].lessonRead,
                    forKey: key(for: title, type: Key.lessonRead)
                )
        } else {
            progress.append(Language.Progress(topicTitle: title))
            toggleLessonRead(for: title)
        }
    }
    //helpers to update progress
    
    private static func readProgressRecords() -> [Language.Progress] {
        var progressRecords = [Language.Progress]()
        
        Data.chineseTopics.forEach { topic in
            var progressRecord = Language.Progress(topicTitle: topic.title)
            
            progressRecord.lessonRead = UserDefaults.standard.bool(forKey: key(for: topic.title, type: Key.lessonRead))
            
            //implement this for the other three progress items
            progressRecords.append(progressRecord)
        }
        return progressRecords
    }
    
    // MARK: - Constants
    private struct Key {
        static let lessonRead = "lessonRead"
        static let vocabStudied = "vocabStudied"
        static let quizPassed = "quizPassed"
        static let highScore = "highScore"
    }
    
    private struct Data {
        static let chineseTopics = [
            Language.Topic (
                title: "Basic Greetings",
                lesonText: """
                    Greetings are an essential part of communication in any culture, and in Chinese, they carry significant social meaning. While basic greetings like "hello" are common in both English and Chinese, the nuances and contexts differ.
                
                In English, "Hello" can be used at any time, which isn’t the case in Chinese. Using the correct greeting for the time of day reflects attentiveness and respect. It is common to say good morning and good afternoon when greating people throughout the day.
                """,
                vocabulary: [
                    Language.Term(targetWord: "你好", pinyin: "nǐ hǎo", translation: "Hello"),
                    Language.Term(targetWord: "早上好", pinyin: "zǎoshang hǎo", translation: "Good morning"),
                    Language.Term(targetWord: "下午好", pinyin: "xiàwǔ hǎo", translation: "Good afternoon"),
                    Language.Term(targetWord: "晚上好", pinyin: "wǎnshàng hǎo", translation: "Good evening"),
                    Language.Term(targetWord: "你好吗?", pinyin: "nǐ hǎo ma?", translation: "How are you?"),
                    Language.Term(targetWord: "再见", pinyin: "zàijiàn", translation: "Goodbye"),
                ],
                quiz: [
                    Language.QuizItem(
                        question: "How would you say 'Hello'?",
                        answers: ["Hello", "你好"],
                        correctAnswer: "你好")
                ]),
            Language.Topic (
                title: "What do you like",
                lesonText: """
                    This is a test
                """,
                vocabulary: [
                    Language.Term(targetWord: "喜歡", pinyin: "xihuan", translation: "like"),
                ],
                quiz: [
                    Language.QuizItem(
                        question: "Which of the following mean 'like'?",
                        answers: ["你好", "喜歡"],
                        correctAnswer: "喜歡")
                ]),
        ]
    }
}
