//
//  AIView.swift
//  ReviewMyThing
//
//  Created by Kent Karlsson on 2024-11-23.
//

import SwiftUI
import OpenAI
import AVKit

class Compujter {
    static let shared = Compujter()
    private let openAI = OpenAI(apiToken: Settings.shared.openAIKey)
    
    func getAudio(text: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let query = AudioSpeechQuery(model: "gpt-4o-audio-preview", input: text, voice: .onyx, speed: nil)
        openAI.audioCreateSpeech(query: query) { result in
            switch result {
            case .success(let response):
                completion(.success(response.audio))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
        
    func inspectImage(prompt: String, image: Data, completion: @escaping (Result<String, Error>) -> Void) {
        typealias VisionContent = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam.Content.VisionContent
        typealias ImageURL = VisionContent.ChatCompletionContentPartImageParam.ImageURL
        
        print("Sending query: \(prompt) (with image of length \(image.count))")
        let visionContent = VisionContent(chatCompletionContentPartImageParam: .init(imageUrl: ImageURL(url: image, detail:.auto)))
        let query = ChatQuery(messages: [
            .init(role: .system, content: "Your job is to describe images, but you dont want to so your tone is short. To make things more fun, you find a way to describe them that is the least useful possible")!,
            .init(role: .user, content: [visionContent])!
        ], model: .gpt4_o_mini, maxTokens: 1000)

        openAI.chats(query: query) { result in
            switch result {
            case .success(let response):
                completion(.success(response.choices.first?.message.content?.string ?? "no?"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getResponse(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        print("Sending query: \(prompt)")
        let query = ChatQuery(messages: [.init(role: .user, content: "Hello!")!], model: .gpt3_5Turbo, maxTokens: 300)
//        let result = try await openAI.chats(query: query)
//        let query = CompletionsQuery(model: .gpt4_o_mini, prompt: prompt, maxTokens: 300)
        openAI.chats(query: query) { result in
            switch result {
            case .success(let response):
                completion(.success(response.choices.first?.message.content?.string ?? "no?"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

struct AIView: View {
    @Binding var isPresented: Bool
    @Binding var adventure: ChooseYourAdventureViewModel
    @State var waitingForAI: Bool = true
    @State var aiResponse: String = ""
    @State var aiAudio: Data? = nil
    @State var player:AVAudioPlayer? = nil
    
    var body: some View {
        if $waitingForAI.wrappedValue {
            ProgressView("Talking to AI")
                .onAppear {
                    if let jpegData = adventure.jpegData {
                        Compujter.shared.inspectImage(prompt: "Please describe this image", image: jpegData) { result in
                            switch result {
                            case .success(let response):
                                print("AI response: \(response)")
                                
                                Compujter.shared.getAudio(text: response) { result in
                                    switch result {
                                    case .success(let audioResponse):
                                        print("AI Audio: \(audioResponse.count) bytes")
                                        aiAudio = audioResponse
                                        aiResponse = response
                                        waitingForAI = false
                                    case .failure(let error):
                                        print("AI error: \(error)")
                                        aiResponse = response
                                        waitingForAI = false
                                    }
                                }
                            case .failure(let error):
                                print("AI error: \(error)")
                                isPresented = false
                            }
                        }
                            
                    } else {
                        Compujter.shared.getResponse(prompt: "Hello, AI") { result in
                            switch result {
                            case .success(let response):
                                print("AI response: \(response)")
                                aiResponse = response
                                waitingForAI = false
                            case .failure(let error):
                                print("AI error: \(error)")
                                isPresented = false
                            }
                        }
                    }
                }
        } else {
            Text(aiResponse)
                .padding()
                .onTapGesture {
                    isPresented = false
                }
                .onAppear {
                    guard let audio = aiAudio else {
                        print("No audio?")
                        return
                    }
                    
                    do {
                        player = try AVAudioPlayer(data: audio)
                        player?.play()
                        
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
        }
    }
}

//#Preview {
//    AIView()
//}
