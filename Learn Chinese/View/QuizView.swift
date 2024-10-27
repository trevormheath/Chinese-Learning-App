//
//  QuizView.swift
//  Learn Chinese
//
//  Created by IS 543 on 10/25/24.
//

import SwiftUI

struct QuizView: View {
    var languageViewModel: LanguageViewModel
    @State private var counter = 0
    @State private var currentScore = 0
    @State private var animatedBonusRemaining = 0.0
    @State private var selectedAnswer: String? = nil
    @State private var wrongAnswers: Int = 0
    @State private var isCorrect: Bool = false
    @Environment(\.presentationMode) var presentationMode
    var questions: [Language.QuizItem] {
        languageViewModel.currentQuestions
    }
    var title: String {
        languageViewModel.currentTopic.title
    }
    
    var body: some View {
        VStack {
            Text("\(title) Quiz")
                .font(.largeTitle)
            HStack {
                Text("Score: \(currentScore)")
                Text("Highscore: \(languageViewModel.progress(for: title).quizHighScore)")
            }
            Rectangle()
                .fill(.softGreen)
                .frame(width: Constants.countDownWidth * min(1, animatedBonusRemaining), height: Constants.countDownHeight)
                .onAppear {
                    startAnimation()
                }
            VStack {
                Text(questions[counter].question)
                    .font(.title2)
                    .padding(.top, Constants.largePadding)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(questions[counter].answers, id: \.self) { answer in
                        Button(action: {
                            selectedAnswer = answer
                            stopAnimation()
                            
                            if answer == questions[counter].correctAnswer {
                                let bonusPoints = languageViewModel.pickQuizAnswer(questions[counter])
                                currentScore += Constants.baseScore + bonusPoints
                                isCorrect = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.animationDuration) {
                                    isCorrect = false
                                }
                            } else {
                                // Handle incorrect answer (e.g., show a message)
                                withAnimation(.default) {
                                    wrongAnswers += 1
                                }
                            }
                        }) {
                            Text(answer)
                                .padding()
                                .background(
                                    selectedAnswer == nil ? .defaultButton :
                                        (selectedAnswer != nil && answer == questions[counter].correctAnswer) ? Color.green :
                                        (selectedAnswer == answer && answer != questions[counter].correctAnswer) ? .exitButton :
                                            .defaultButton
                                )
                                .foregroundColor(.black)
                                .cornerRadius(Constants.cornerRadius)
                        }
                        .disabled(selectedAnswer != nil)
                    }
                }
                .padding()
                
                Button {
                    if (counter < questions.count - 1) {
                        withAnimation(.easeInOut){
                            counter += 1
                            selectedAnswer = nil
                            languageViewModel.nextQuizQuestion()
                        }
                        startAnimation()
                    } else {
                        if wrongAnswers <= 0 {
                            if !languageViewModel.progress(for: title).quizPassed {
                                languageViewModel.toggleQuizComplete(for: title)
                            }
                        }
                        languageViewModel.saveHighscore(for: title, with: currentScore)
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    if (counter < questions.count - 1){
                        Text("Next")
                    } else {
                        Text("Finish Test")
                    }
                }
                .padding(.bottom, Constants.largePadding)
                .disabled(selectedAnswer == nil)
            }
            .cardify(isFaceUp: true)
            .modifier(Shake(animatableData: CGFloat(wrongAnswers)))
            .transition(.slide)
            .id(counter)
            
        }
        .background(isCorrect ? Color("SoftGreen") : Color.clear)
        .animation(.easeInOut(duration: Constants.animationDuration), value: isCorrect)
    }
    
    struct Shake: GeometryEffect {
        var amount: CGFloat = 10
        var shakesPerUnit = 3
        var animatableData: CGFloat

        func effectValue(size: CGSize) -> ProjectionTransform {
            ProjectionTransform(CGAffineTransform(translationX:
                amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0))
        }
    }
    
    private func startAnimation() {
        animatedBonusRemaining = languageViewModel.quizBonusTimePercent
        withAnimation(.easeInOut(duration: languageViewModel.quizBonusTimeRemaining)) {
            animatedBonusRemaining = 0
        }
    }
    private func stopAnimation() {
        // Set to 100% so it stops decreasing
        animatedBonusRemaining = 1.0
    }
    
    private struct Constants {
        static let smallPadding: CGFloat = 10
        static let largePadding: CGFloat = 25
        static let cornerRadius: CGFloat = 10
        static let animationDuration: TimeInterval = 0.5
        static let countDownWidth: CGFloat = 300
        static let countDownHeight: CGFloat = 30
        static let baseScore: Int = 10
    }
}

#Preview {
    let languageViewModel = LanguageViewModel()
    languageViewModel.createQuizQuestions([
        Language.QuizItem(
               question: "What is the pinyin for '你好吗'?",
               answers: ["nǐ hǎo ma", "nǐ zěnme yàng", "nǐ hǎo", "nǐ jǐ suì"],
               correctAnswer: "nǐ hǎo ma"
        ),
        Language.QuizItem(
            question: "How would you say 'Hello'?",
            answers: ["再见", "你好", "早上好", "下午好"],
            correctAnswer: "你好"
        ),
    ])
    
    let topic = Language.Topic(
       title: "This is a test",
       lessonText: "",
       vocabulary: [],
       quiz: []
    )
    
    languageViewModel.selectTopic(topic)
    languageViewModel.nextQuizQuestion()
    return QuizView(languageViewModel: languageViewModel)
}
