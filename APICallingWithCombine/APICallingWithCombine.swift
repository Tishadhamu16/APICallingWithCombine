//
//  APICallingWithCombine.swift
//  APICallingWithCombine
//
//  Created by Tisha Dhamu on 15/02/25.
//

import SwiftUI
import Combine

class CombineDataManager {
    
    //function to fetch multiple images with combien
    func fetchMultipleImagesWithCombine() -> AnyPublisher<[UIImage], Error> {
        let urlPool : [URL] = [ URL(string: "https://picsum.photos/200/300")!, URL(string: "https://picsum.photos/200/300")!, URL(string: "https://picsum.photos/200/300")!, URL(string: "https://picsum.photos/200/300")!]
        
        let publishers = urlPool.map {
            fetchSingleImageWithCOmbine(url: $0)
        }
        
        return Publishers.MergeMany(publishers)   //merge multiple request
            .collect() //this will collect all the images into a singlw array
            .eraseToAnyPublisher()
        
    }
    
    //fetch single image with combine
    func fetchSingleImageWithCOmbine(url: URL) -> AnyPublisher<UIImage,Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map {$0.data}         //extracted data from the response
            .tryMap{ data in
                guard let image = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                return image
            }
            .receive(on: DispatchQueue.main)  // ensure that ui updates on the main thread
            .eraseToAnyPublisher()
        
    }
}

//this is a view model for the application

class CombineViewModel : ObservableObject {
    @Published var images : [UIImage] = []
    var cancellables = Set<AnyCancellable>()
    var dataManager = CombineDataManager()
    
    @MainActor
    func getImage() {
        dataManager.fetchMultipleImagesWithCombine()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching images:", error.localizedDescription)
                
                }
            }, receiveValue: { [weak self] images in
                self?.images.append(contentsOf: images)
            })
            .store(in: &cancellables) // Store subscription
    }
}

//this the main view
struct CombinePractice : View {
    @StateObject var viewModel = CombineViewModel()
    
    var body : some View {
        NavigationView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(viewModel.images, id:\.self) {image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            }
            .navigationTitle("Fetch data with Combine")
        }
        .onAppear() {
            viewModel.getImage()
        }
    }
}

struct CombinePractice_Previews : PreviewProvider {
    static var previews: some View {
        CombinePractice()
    }
}
