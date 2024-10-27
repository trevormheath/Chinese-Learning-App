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
        var lessonText: String
        var vocabulary: [Term]
        var quiz: [QuizItem]
    }
    
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
        var answers: [String]
        var correctAnswer: String
//        var questionType: QuestionType
    }
    
    struct Progress {
        let topicTitle: String
        var lessonRead = false
        var vocabStudied = false
        var quizPassed = false
        var quizHighScore: Int = 0
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
    var currentQuiz: [Language.QuizItem]? {get set}
    var languageName: String {get}
    var topics: [Language.Topic] {get}
    var progress: [Language.Progress] {get set}
    var bonusTimeRemaining: TimeInterval {get}
    var bonusRemainingPercent: Double {get}
    
    mutating func selectTopic(_ title: Language.Topic)
    mutating func flipCard(_ term: Language.Term)
    mutating func makeFlashcards(_ terms: [Language.Term])
    mutating func makeQuiz(_ questions: [Language.QuizItem])
    mutating func toggleLessonRead(for title: String)
    mutating func nextQuizQuestion()
    mutating func pickQuizAnswer(_ answer: Language.QuizItem) -> Int
    mutating func saveLessonHighscore(for title: String, with score: Int)
    mutating func toggleQuizComplete(for title: String)
    mutating func toggleFlashCardsComplete(for title: String)
}

struct ChineseLessonPlan: LessonPlan {
    // MARK: -  Properties
    var selectedTopic: Language.Topic?
    var currentFlashcards: [Language.Term]?
    var currentQuiz: [Language.QuizItem]?
    var timeStarted: Date?
    
    let languageName = "Chinese"
    let topics = Data.chineseTopics
    var progress: [Language.Progress] = ChineseLessonPlan.readProgressRecords()
    fileprivate(set) var bonusTimeLimit: TimeInterval = 20
    
    // MARK: - Helpers
    mutating func selectTopic(_ topic: Language.Topic) {
        selectedTopic = topic
    }
    
    mutating func flipCard(_ term: Language.Term) {
        if var flashcards = currentFlashcards, let index = flashcards.firstIndex(where: {$0.id == term.id}) {
            flashcards[index].isTargetUp.toggle()
            currentFlashcards = flashcards
        }
    }
    
    mutating func makeFlashcards(_ terms: [Language.Term]) {
        currentFlashcards = terms.shuffled()
    }
    
    mutating func makeQuiz(_ questions: [Language.QuizItem]) {
        currentQuiz = questions.shuffled()
    }
    
    var bonusTimeRemaining: TimeInterval {
        return max(0, bonusTimeLimit - timeRunning)
    }
    
    var bonusRemainingPercent: Double {
        (bonusTimeLimit > 0 && bonusTimeRemaining > 0)
        ? bonusTimeRemaining / bonusTimeLimit
        : 0
    }
    
    mutating func pickQuizAnswer(_ answer: Language.QuizItem) -> Int {
        let score = bonusScore
        stopUsingBonusTime()
        return score
    }
    
    mutating func nextQuizQuestion() {
        startUsingBonusTime()
    }
    
    private var timeRunning: TimeInterval {
        if let timeStarted {
            Date().timeIntervalSince(timeStarted)
        } else {
            20
        }
    }
    
    private var bonusScore: Int {
        return Int(ceil((bonusTimeRemaining) / 2))
    }
    
    private mutating func startUsingBonusTime() {
        if timeStarted == nil {
            timeStarted = Date()
        }
    }
    
    private mutating func stopUsingBonusTime() {
        timeStarted = nil
    }
    
    // MARK: - Save Progress
    mutating func saveLessonHighscore(for title: String, with score: Int) {
        if let index = progress.firstIndex(where: {$0.topicTitle == title}) {
            progress[index].quizHighScore = max(progress[index].quizHighScore, score)
            UserDefaults.standard
                .set(
                    progress[index].quizHighScore,
                    forKey: key(for: title, type: Key.highScore)
                )
        } else {
            progress.append(Language.Progress(topicTitle: title))
            saveLessonHighscore(for: title, with: score)
        }
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
    
    mutating func toggleQuizComplete(for title: String) {
        if let index = progress.firstIndex(where: {$0.topicTitle == title}) {
            progress[index].quizPassed.toggle()
            UserDefaults.standard
                .set(
                    progress[index].quizPassed,
                    forKey: key(for: title, type: Key.quizPassed)
                )
        } else {
            progress.append(Language.Progress(topicTitle: title))
            toggleQuizComplete(for: title)
        }
    }
    mutating func toggleFlashCardsComplete(for title: String) {
        if let index = progress.firstIndex(where: {$0.topicTitle == title}) {
            progress[index].vocabStudied.toggle()
            UserDefaults.standard
                .set(
                    progress[index].vocabStudied,
                    forKey: key(for: title, type: Key.vocabStudied)
                )
        } else {
            progress.append(Language.Progress(topicTitle: title))
            toggleFlashCardsComplete(for: title)
        }
    }
    
    private static func readProgressRecords() -> [Language.Progress] {
        var progressRecords = [Language.Progress]()
        
        Data.chineseTopics.forEach { topic in
            var progressRecord = Language.Progress(topicTitle: topic.title)
            
            progressRecord.lessonRead = UserDefaults.standard.bool(forKey: key(for: topic.title, type: Key.lessonRead))
            
            progressRecord.quizHighScore = UserDefaults.standard.integer(forKey: key(for: topic.title, type: Key.highScore))
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
                lessonText: """
                    Greetings are an essential part of communication in any culture, and in Chinese, they carry significant social meaning. While basic greetings like "hello" are common in both English and Chinese, the nuances and contexts differ.
                
                In English, "Hello" can be used at any time, which isn’t the case in Chinese. Using the correct greeting for the time of day reflects attentiveness and respect. It is common to say good morning and good afternoon when greating people throughout the day.
                """,
                vocabulary: [
                    Language.Term(targetWord: "你好", pinyin: "nǐ hǎo", translation: "Hello"),
                    Language.Term(targetWord: "早上好", pinyin: "zǎoshang hǎo", translation: "Good morning"),
                    Language.Term(targetWord: "下午好", pinyin: "xiàwǔ hǎo", translation: "Good afternoon"),
                    Language.Term(targetWord: "晚上好", pinyin: "wǎnshàng hǎo", translation: "Good evening"),
                    Language.Term(targetWord: "你好吗?", pinyin: "nǐ hǎo ma", translation: "How are you"),
                    Language.Term(targetWord: "再见", pinyin: "zàijiàn", translation: "Goodbye"),
                ],
                quiz: [
                    Language.QuizItem(
                        question: "How would you say 'Hello'?",
                        answers: ["再见", "你好", "早上好", "下午好"],
                        correctAnswer: "你好"
                    ),
                    Language.QuizItem(
                        question: "What does '早上好' mean in English?",
                        answers: ["Goodbye", "Good morning", "How are you", "Good evening"],
                        correctAnswer: "Good morning"
                    ),
                    Language.QuizItem(
                        question: "What is the translation for 'Goodbye'?",
                        answers: ["再见", "你好", "谢谢", "欢迎"],
                        correctAnswer: "再见"
                    ),
                    Language.QuizItem(
                        question: "How do you say 'Good evening' in Chinese?",
                        answers: ["晚上好", "再见", "你好", "谢谢"],
                        correctAnswer: "晚上好"
                    ),
                    Language.QuizItem(
                           question: "What is the pinyin for '你好吗'?",
                           answers: ["nǐ hǎo ma", "nǐ zěnme yàng", "nǐ hǎo", "nǐ jǐ suì"],
                           correctAnswer: "nǐ hǎo ma"
                    ),
                    Language.QuizItem(
                        question: "What is the pinyin for '下午好'?",
                        answers: ["nǐ hǎo", "zhōngwǔ hǎo", "wǎnshàng hǎo", "xiàwǔ hǎo"],
                        correctAnswer: "xiàwǔ hǎo"
                    ),
                ]
            ),
            Language.Topic (
                title: "Ordering Food",
                lessonText: """
                    Ordering food is an essential skill when visiting a Chinese-speaking country. Understanding the menu and knowing how to ask for food can enhance your dining experience.
                    
                    In Chinese, it's common to start by saying "请给我" (qǐng gěi wǒ), meaning "Please give me," followed by the dish you would like to order. 
                """,
                vocabulary: [
                    Language.Term(targetWord: "请给我", pinyin: "qǐng gěi wǒ", translation: "Please give me"),
                    Language.Term(targetWord: "米饭", pinyin: "mǐ fàn", translation: "Rice"),
                    Language.Term(targetWord: "面条", pinyin: "miàn tiáo", translation: "Noodles"),
                    Language.Term(targetWord: "牛肉", pinyin: "niú ròu", translation: "Beef"),
                    Language.Term(targetWord: "鸡肉", pinyin: "jī ròu", translation: "Chicken"),
                    Language.Term(targetWord: "菜单", pinyin: "cài dān", translation: "Menu"),
                ],
                quiz: [
                    Language.QuizItem(
                        question: "How would you say 'Please give me rice'?",
                        answers: ["请给我米饭", "请给我面条", "请给我牛肉", "请给我鸡肉"],
                        correctAnswer: "请给我米饭"
                    ),
                    Language.QuizItem(
                        question: "What does '菜单' mean in English?",
                        answers: ["Rice", "Noodles", "Menu", "Beef"],
                        correctAnswer: "Menu"
                    ),
                    Language.QuizItem(
                        question: "How do you say 'Noodles' in Chinese?",
                        answers: ["米饭", "面条", "牛肉", "鸡肉"],
                        correctAnswer: "面条"
                    ),
                    Language.QuizItem(
                        question: "What is the pinyin for '鸡肉'?",
                        answers: ["jī ròu", "niú ròu", "mǐ fàn", "miàn tiáo"],
                        correctAnswer: "jī ròu"
                    ),
                ]
            ),
            Language.Topic(
                title: "Shopping",
                lessonText: """
                    Shopping in a Chinese-speaking country can be an enjoyable experience. Knowing how to ask for prices and sizes can help you find what you need.
                    
                    Common phrases include "这个多少钱?" (zhège duōshao qián?) which means "How much is this?"
                """,
                vocabulary: [
                    Language.Term(targetWord: "这个", pinyin: "zhège", translation: "This"),
                    Language.Term(targetWord: "多少钱", pinyin: "duōshao qián", translation: "How much"),
                    Language.Term(targetWord: "太贵了", pinyin: "tài guì le", translation: "Too expensive"),
                    Language.Term(targetWord: "便宜一点", pinyin: "piányí yīdiǎn", translation: "Cheaper, please"),
                    Language.Term(targetWord: "我想要", pinyin: "wǒ xiǎng yào", translation: "I want"),
                    Language.Term(targetWord: "尺码", pinyin: "chǐmǎ", translation: "Size"),
                ],
                quiz: [
                    Language.QuizItem(
                        question: "How would you ask 'How much is this?' in Chinese?",
                        answers: ["这个多少钱?", "太贵了", "便宜一点", "我想要尺码"],
                        correctAnswer: "这个多少钱?"
                    ),
                    Language.QuizItem(
                        question: "What does '尺码' mean in English?",
                        answers: ["Price", "Size", "This", "Cheap"],
                        correctAnswer: "Size"
                    ),
                    Language.QuizItem(
                        question: "What is the pinyin for '便宜一点'?",
                        answers: ["piányí yīdiǎn", "tài guì le", "wǒ xiǎng yào", "zhège"],
                        correctAnswer: "piányí yīdiǎn"
                    ),
                ]
            ),
            Language.Topic(
                title: "Travel",
                lessonText: """
                    Traveling in a Chinese-speaking country can be exciting, but it helps to know some key phrases to navigate around.
                    
                    Phrases like "我想去..." (wǒ xiǎng qù...) meaning "I want to go to..." are very useful.
                """,
                vocabulary: [
                    Language.Term(targetWord: "我想去", pinyin: "wǒ xiǎng qù", translation: "I want to go to"),
                    Language.Term(targetWord: "哪里", pinyin: "nǎlǐ", translation: "Where"),
                    Language.Term(targetWord: "火车站", pinyin: "huǒchē zhàn", translation: "Train station"),
                    Language.Term(targetWord: "机场", pinyin: "jīchǎng", translation: "Airport"),
                    Language.Term(targetWord: "酒店", pinyin: "jiǔdiàn", translation: "Hotel"),
                    Language.Term(targetWord: "帮助", pinyin: "bāngzhù", translation: "Help"),
                ],
                quiz: [
                    Language.QuizItem(
                        question: "How would you say 'I want to go to the airport'?",
                        answers: ["我想去火车站", "我想去机场", "我想去酒店", "我想去哪里"],
                        correctAnswer: "我想去机场"
                    ),
                    Language.QuizItem(
                        question: "What does '火车站' mean in English?",
                        answers: ["Airport", "Help", "Train station", "Hotel"],
                        correctAnswer: "Train station"
                    ),
                    Language.QuizItem(
                        question: "What is the pinyin for '哪里'?",
                        answers: ["nǎlǐ", "jīchǎng", "huǒchē zhàn", "jiǔdiàn"],
                        correctAnswer: "nǎlǐ"
                    ),
                ]
            ),
            Language.Topic(
                title: "Weather",
                lessonText: """
                    Talking about the weather is a common conversation starter in any culture. In Chinese, you can describe different weather conditions and ask about the forecast.
                    
                    Key phrases include "今天天气怎么样?" (jīntiān tiānqì zěnme yàng?), meaning "How is the weather today?"
                """,
                vocabulary: [
                    Language.Term(targetWord: "天气", pinyin: "tiānqì", translation: "Weather"),
                    Language.Term(targetWord: "今天", pinyin: "jīntiān", translation: "Today"),
                    Language.Term(targetWord: "晴天", pinyin: "qíngtiān", translation: "Sunny day"),
                    Language.Term(targetWord: "下雨", pinyin: "xià yǔ", translation: "Rain"),
                    Language.Term(targetWord: "很热", pinyin: "hěn rè", translation: "Very hot"),
                    Language.Term(targetWord: "冷", pinyin: "lěng", translation: "Cold"),
                ],
                quiz: [
                    Language.QuizItem(
                        question: "How would you ask 'How is the weather today?' in Chinese?",
                        answers: ["今天很热", "今天天气怎么样?", "下雨了", "天气冷"],
                        correctAnswer: "今天天气怎么样?"
                    ),
                    Language.QuizItem(
                        question: "What does '晴天' mean in English?",
                        answers: ["Sunny day", "Rain", "Cold", "Weather"],
                        correctAnswer: "Sunny day"
                    ),
                    Language.QuizItem(
                        question: "What is the pinyin for '下雨'?",
                        answers: ["hěn rè", "xià yǔ", "lěng", "tiānqì"],
                        correctAnswer: "xià yǔ"
                    ),
                ]
            ),
            Language.Topic(
                title: "Family",
                lessonText: """
                    Understanding family terms in Chinese is essential for social conversations and understanding relationships.
                    
                    In Chinese culture, family plays a significant role, and knowing how to refer to family members is important.
                """,
                vocabulary: [
                    Language.Term(targetWord: "爸爸", pinyin: "bàba", translation: "Father"),
                    Language.Term(targetWord: "妈妈", pinyin: "māmā", translation: "Mother"),
                    Language.Term(targetWord: "兄弟", pinyin: "xiōngdì", translation: "Brother"),
                    Language.Term(targetWord: "姐妹", pinyin: "jiěmèi", translation: "Sister"),
                    Language.Term(targetWord: "家", pinyin: "jiā", translation: "Family/Home"),
                    Language.Term(targetWord: "孩子", pinyin: "háizi", translation: "Child"),
                ],
                quiz: [
                    Language.QuizItem(
                        question: "How do you say 'Mother' in Chinese?",
                        answers: ["爸爸", "孩子", "妈妈", "家"],
                        correctAnswer: "妈妈"
                    ),
                    Language.QuizItem(
                        question: "What does '兄弟' mean in English?",
                        answers: ["Sister", "Brother", "Father", "Child"],
                        correctAnswer: "Brother"
                    ),
                    Language.QuizItem(
                        question: "What is the pinyin for '家'?",
                        answers: ["jiā", "háizi", "māmā", "bàba"],
                        correctAnswer: "jiā"
                    ),
                ]
            )
        ]
    }
}
