//
//  PublisherAndSubscriber.swift
//  APICallingWithCombine
//
//  Created by Tisha Dhamu on 17/02/25.
//
import SwiftUI
import Combine

class DataManager {
    
    func fetchData(url : URL) -> AnyPublisher<[UserModel], Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [UserModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
    }
}


class ViewModel : ObservableObject {
    @Published var users : [UserModel] = []
    var dataManager = DataManager()
    var cancellable : Set<AnyCancellable> = []
    
    func getData() {
        let publisher = dataManager.fetchData(url: URL(string: "https://api.github.com/users")!)
        
        publisher.sink { completion in
            switch completion {
            case .finished:
                print("succeed")
            case .failure(let error) :
                print(error)
                
            }
        } receiveValue: { value in
            self.users = value
        }.store(in: &cancellable)
    }
}


struct PublisherAndSubscriberPractice : View {
    @StateObject var viewModel = ViewModel()
    
    var body : some View {
        
        NavigationView {
            
            ZStack {
                
                Color.brown.ignoresSafeArea().opacity(  0.07)
                
                List(viewModel.users, id:\.self){user in
                    HStack{
                        AsyncImage(url: URL(string:"https://picsum.photos/200/300"))
                            .clipShape(Circle())
                            .frame(width:50,height:50)
                        Spacer()
                        Text(user.login)
                    }
                    .listRowBackground(Color.brown.opacity(0.15))     // to change colour of the list row
                    
                }
                .listRowSpacing(5)
                .navigationTitle("Fetch data with Combine")
                .scrollContentBackground(.hidden)           //to hide the default list background color
                
            }
        }
        .onAppear() {
            viewModel.getData()
        }
        
    }
}

struct PublisherAndSubscriberPractice_Previews : PreviewProvider {
    static var previews: some View {
        PublisherAndSubscriberPractice()
    }
}
