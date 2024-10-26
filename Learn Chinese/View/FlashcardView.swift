//
//  FlashcardView.swift
//  Learn Chinese
//
//  Created by IS 543 on 10/25/24.
//

import SwiftUI

struct FlashcardView: View {
    var languageViewModel: LanguageViewModel
    
    @State private var counter = 0
    @State private var isNext: Bool = false
    var vocab: [Language.Term] {
        languageViewModel.currentFlashcards
    }
    
    var body: some View {
        if vocab.isEmpty {
            Text("No vocab in this lesson!")
        } else {
            VStack {
                if vocab[counter].isTargetUp {
                    HStack {
                        Text(vocab[counter].targetWord)
                            .font(.title)
                        Text("(\(vocab[counter].pinyin))")
                            .font(.title)
                    }
                } else {
                    Text(vocab[counter].translation)
                        .font(.title)
                }
            }
            .cardify(isFaceUp: vocab[counter].isTargetUp)
            .onTapGesture {
                languageViewModel.flip(vocab[counter])
            }
            .animation(.easeInOut(duration: 1.0), value: vocab[counter].isTargetUp)
//            .transition(.scale)
            .transition(counterChangeTransition())
            .id(counter)
            
            HStack {
                Button {
                    withAnimation(.easeInOut) {
                        if counter > 0 {
                            isNext = false
                            counter -= 1
                        }
                    }
                } label: {
                    Text("Previous")
                }
                .padding(10)
                .background(.yellow)
                .cornerRadius(10)
                
                Button {
                    withAnimation(.easeInOut) {
                        if counter < vocab.count - 1 {
                            isNext = true
                            counter += 1
                        }
                    }
                } label: {
                    Text("Next")
                }
                .padding(10)
                .background(.yellow)
                .cornerRadius(10)
            }
            .padding(50)
        }
    }
    
    private func counterChangeTransition() -> AnyTransition {
        if (isNext) {
//            return .move(edge: .trailing)
            return AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .scale)
        } else {
//            return .move(edge: .leading)
            return AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .scale)
        }
    }
}

#Preview {
    FlashcardView(languageViewModel: LanguageViewModel())
}
