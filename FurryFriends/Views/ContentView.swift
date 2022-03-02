//
//  ContentView.swift
//  FurryFriends
//
//  Created by Russell Gordon on 2022-02-26.
//

import SwiftUI

struct ContentView: View {
      
        
        @Environment(\.scenePhase) var scenePhase
        
        @State var currentContent: Content = Content(
                                                file: "https://dog.ceo/api/breeds/image/random")
       
        @State var favourites: [Content] = []
        
      
        @State var currentContentAddedToFavourites: Bool = false
        
        // MARK: Computed Properties
        
        var body: some View {
            VStack {
                RemoteImageView(fromURL: URL(string: currentContent.file)!)
                
                    .padding(10)
                Image(systemName: "heart.circle")
                    .resizable()
                    .frame(width: 40,
                           height: 40)
                
                    .foregroundColor(currentContentAddedToFavourites == true ? .red : .secondary)
                    .onTapGesture {
                        
                     
                        if currentContentAddedToFavourites == false {
                            
                            
                            favourites.append(currentContent)
                            
                           
                            currentContentAddedToFavourites = true
                        }
                        
                    }
                
                Button(action: {
                   
                    Task {
                     
                        await loadNewContent()
                    }
                }, label: {
                    Text("More!")
                })
                    .buttonStyle(.bordered)
                
                Text("Favourites")
                    .bold()
                
                Spacer()
                
            
                List(favourites, id: \.self) { currentFavourit in
                    Text(currentFavourit.file)
                }
                
                Spacer()
                
            }
           
            .task {
                
                await loadNewContent()
            
                loadFavourites()
                
                
            }
            
            .onChange(of: scenePhase) {newPhase in
                
                if newPhase == .inactive {
                    print("Inactive")
                } else if newPhase == .active {
                    print("Active")
                } else if newPhase == .background{
                    print("Background")
                }
                
                persistFavourites()
            }
            .navigationTitle("🐾Dogs and Cats🐈")
            .padding()
            
            
        }
        
      
        func loadNewContent() async {
            
            
            let url = URL(string:"https://dog.ceo/api/breeds/image/random")!
            
           
            var request = URLRequest(url: url)
            
            
            request.setValue("application/json",
                             forHTTPHeaderField: "Accept")
            
            
            let urlSession = URLSession.shared
            
           
            do {
                
                
                let (data, _) = try await urlSession.data(for: request)
                
                
                currentContent = try JSONDecoder().decode(Content.self, from: data)
                
               print("ready")
                currentContentAddedToFavourites = false
                
            } catch {
                print("Could not retrieve or decode the JSON from endpoint.")
                
                print(error)
            }
        }
        
       
        func persistFavourites() {
            
            
            let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
            print(filename)
            
           
            do {
                
                let encoder = JSONEncoder()
                
            
                encoder.outputFormatting = .prettyPrinted
                
              
                let data = try encoder.encode(favourites)
                
               
                try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
                
              
                print("saved data to the documents directory successfully.")
                print ("=========")
                print(String(data: data, encoding: .utf8)!)
                
            } catch {
                print("Unable to write list of favourites to docuents directofy")
                print("========")
                print(error.localizedDescription)
            }
            
        }
        
        func loadFavourites() {
            
           
            let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
            print(filename)
            
        
            do {
                
               
                let data = try Data(contentsOf: filename)
                
               
                print("read data from the documents directory successfully.")
                print ("=========")
                print(String(data: data, encoding: .utf8)!)
                
               
                favourites = try JSONDecoder().decode([Content].self, from: data)
                
            } catch {
                
                print("could not load the data from the stored JSON file")
                print ("======")
                print(error.localizedDescription)
            }
        }
    }
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}

