//
//  LessonView.swift
//  Learn Chinese
//
//  Created by IS 543 on 10/24/24.
//

import SwiftUI

struct LessonView: View {
    var Topic: Language.Topic
    var languageViewModel: LanguageViewModel
    @State private var showPopUp: Bool = false
    @State private var popupMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Text(Topic.title)
                        .font(.largeTitle)
                    
                    Text(Topic.lessonText)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("Vocabulary Words")
                        .font(.headline)
                    List(Topic.vocabulary) { term in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(term.targetWord)
                                    .font(.headline)
                                Text("(\(term.pinyin))")
                            }
                            
                            Text(term.translation)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(Constants.smallPadding)
                        .background(.softGreen)
                        .cornerRadius(Constants.cornerRadius)
                    }
                    
                    NavigationLink(destination: FlashcardView(languageViewModel: languageViewModel)) {
                        Text("Review Flashcards")
                    }.frame(maxWidth: .infinity)
                        .padding(Constants.smallPadding)
                        .background(.defaultButton)
                        .cornerRadius(Constants.cornerRadius)
                        .simultaneousGesture(TapGesture().onEnded {
                            languageViewModel.createFlashCardDeck(Topic.vocabulary)
                        })
                        .disabled(showPopUp)
                    
                    NavigationLink(destination: QuizView(languageViewModel: languageViewModel)) {
                        Text("Take Quiz")
                    }.frame(maxWidth: .infinity)
                        .padding(Constants.smallPadding)
                        .background(.defaultButton)
                        .cornerRadius(Constants.cornerRadius)
                        .simultaneousGesture(TapGesture().onEnded {
                            languageViewModel.createQuizQuestions(Topic.quiz)
                            languageViewModel.nextQuizQuestion()
                        })
                        .disabled(showPopUp)
                    
                    Button {
                        showPopUp = true
                    } label: {
                        Text("Mark Complete")
                    }
                }
                .onAppear {
                    languageViewModel.selectTopic(Topic)
                    //lesson is at topic so it is read if you open it
                    languageViewModel.toggleLessonRead(for: Topic.title)
                }
                .padding()
                
                if showPopUp {
                    VStack(spacing: 20) {
                        Text("Choose an Action")
                            .font(.headline)
                            .padding()
                        
                        VStack {
                            Button {
                                popupMessage = "Lesson Status Updated!"
                                showPopUp = false
                                languageViewModel.toggleLessonRead(for: Topic.title)
                            } label: {
                                if languageViewModel.progress(for: Topic.title).lessonRead {
                                    Text("Mark Lesson as Unread")
                                } else {
                                    Text("Mark Lesson Read")
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.defaultButton)
                            .cornerRadius(Constants.cornerRadius)
                            
                            Button {
                                popupMessage = "Flashcards Status Updated!"
                                showPopUp = false
                                languageViewModel.toggleFlashCardsComplete(for: Topic.title)
                            } label: {
                                if languageViewModel.progress(for: Topic.title).vocabStudied {
                                    Text("Mark Flashcards Incomplete")
                                } else {
                                    Text("Mark Flashcards Complete")
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.defaultButton)
                            .cornerRadius(Constants.cornerRadius)
                            
                            Button {
                                popupMessage = "Quiz Status Updated!"
                                showPopUp = false
                                languageViewModel.toggleQuizComplete(for: Topic.title)
                            } label: {
                                if languageViewModel.progress(for: Topic.title).quizPassed {
                                    Text("Mark Quiz Incomplete")
                                } else {
                                    Text("Mark Quiz Complete")
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.defaultButton)
                            .cornerRadius(Constants.cornerRadius)
                        }
                        
                        Button {
                            showPopUp = false // Close the pop-up
                        } label: {
                            Text("Close")
                        }
                        .padding()
                        .background(.exitButton)
                        .foregroundColor(.black)
                        .cornerRadius(Constants.cornerRadius)
                    }
                    .padding(Constants.largePadding)
                    .background(.lightGrayBackground)
                    .cornerRadius(Constants.cornerRadius)
                    .shadow(radius: Constants.shadowRadius)
                }
            }
        }
        .alert(isPresented: .constant(!popupMessage.isEmpty)) {
            Alert(
                title: Text("Notification"),
                message: Text(popupMessage),
                dismissButton: .default(Text("OK")) {
                    popupMessage = ""
                }
            )
        }
    }
    
    private struct Constants {
        static let smallPadding: CGFloat = 10
        static let largePadding: CGFloat = 25
        static let cornerRadius: CGFloat = 10
        static let animationDuration: TimeInterval = 0.5
        static let shadowRadius: CGFloat = 30
    }
}

#Preview {
    LessonView(Topic: LanguageViewModel().topics[0], languageViewModel: LanguageViewModel())
}
