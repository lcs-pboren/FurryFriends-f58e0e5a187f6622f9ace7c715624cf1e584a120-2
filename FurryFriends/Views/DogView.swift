//
//  DogView.swift
//  FurryFriends
//
//  Created by Patrick Boren on 2022-02-28.
//

import SwiftUI

struct DogView: View {
    
  
    
    @Environment(\.scenePhase) var scenePhase
    
    @State var currentDog: Dog = Dog(
                                            message: "https://dog.ceo/api/breeds/image/random",
                                              status:"")
   
    @State var favourites: [Dog] = []
    
  
    @State var currentDogAddedToFavourites: Bool = false
    
    // MARK: Computed Properties
    
    var body: some View {
        VStack {
            RemoteImageView(fromURL: URL(string: currentDog.message)!)
            
                .padding(10)
            Image(systemName: "heart.circle")
                .resizable()
                .frame(width: 40,
                       height: 40)
            
                .foregroundColor(currentDogAddedToFavourites == true ? .red : .secondary)
                .onTapGesture {
                    
                 
                    if currentDogAddedToFavourites == false {
                        
                        
                        favourites.append(currentDog)
                        
                       
                        currentDogAddedToFavourites = true
                    }
                    
                }
            
            Button(action: {
               
                Task {
                 
                    await loadNewDog()
                }
            }, label: {
                Text("More Dogs!")
            })
                .buttonStyle(.bordered)
            
            Text("Favourites")
                .bold()
            
            Spacer()
            
        
            List(favourites, id: \.self) { currentFavourit in
                AsyncImage(url: URL(string: currentFavourit.message),
                           content: { downloadedImage in
                    downloadedImage
                        .resizable()
                        .scaledToFit()
                },
                           placeholder: {
                    ProgressView()
                })
            }
        
            Spacer()
            
        }
       
        .task {
            
            await loadNewDog()
        
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
        .navigationTitle("🐾Dogs🐾")
        .padding()
        
        
    }
    
  
    func loadNewDog() async {
        
        
        let url = URL(string:"https://dog.ceo/api/breeds/image/random")!
        
       
        var request = URLRequest(url: url)
        
        
        request.setValue("application/json",
                         forHTTPHeaderField: "Accept")
        
        
        let urlSession = URLSession.shared
        
       
        do {
            
            
            let (data, _) = try await urlSession.data(for: request)
            
            
            currentDog = try JSONDecoder().decode(Dog.self, from: data)
            
           print("ready")
            currentDogAddedToFavourites = false
            
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
            
           
            favourites = try JSONDecoder().decode([Dog].self, from: data)
            
        } catch {
            
            print("could not load the data from the stored JSON file")
            print ("======")
            print(error.localizedDescription)
        }
    }
}

struct DogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DogView()
        }
    }
}
