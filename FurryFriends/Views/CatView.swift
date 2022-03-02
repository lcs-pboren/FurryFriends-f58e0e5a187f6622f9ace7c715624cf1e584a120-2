//
//  CatView.swift
//  FurryFriends
//
//  Created by Patrick Boren on 2022-02-28.
//

import SwiftUI

struct CatView: View {
    
  
    
    @Environment(\.scenePhase) var scenePhase
    
    @State var currentCat: Cat = Cat(
                                            file: "https://aws.random.cat/meow")
   
    @State var favourites: [Cat] = []
    
  
    @State var currentCatAddedToFavourites: Bool = false
    
    // MARK: Computed Properties
    
    var body: some View {
        VStack {
            RemoteImageView(fromURL: URL(string: currentCat.file)!)
           
                .padding(10)
            Image(systemName: "heart.circle")
                .resizable()
                .frame(width: 40,
                       height: 40)
            
                .foregroundColor(currentCatAddedToFavourites == true ? .red : .secondary)
                .onTapGesture {
                    
                 
                    if currentCatAddedToFavourites == false {
                        
                        
                        favourites.append(currentCat)
                        
                       
                        currentCatAddedToFavourites = true
                    }
                    
                }
            
            Button(action: {
               
                Task {
                 
                    await loadNewCat()
                }
            }, label: {
                Text("More Cats!")
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
            
            await loadNewCat()
        
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
        .navigationTitle("🐱Cats🐱")
        .padding()
        
        
    }
    
  
    func loadNewCat() async {
        
        
        let url = URL(string:"https://aws.random.cat/meow")!
        
       
        var request = URLRequest(url: url)
        
        
        request.setValue("application/json",
                         forHTTPHeaderField: "Accept")
        
        
        let urlSession = URLSession.shared
        
       
        do {
            
            
            let (data, _) = try await urlSession.data(for: request)
            
            
            currentCat = try JSONDecoder().decode(Cat.self, from: data)
            
           print("ready")
            currentCatAddedToFavourites = false
            
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
            
           
            favourites = try JSONDecoder().decode([Cat].self, from: data)
            
        } catch {
            
            print("could not load the data from the stored JSON file")
            print ("======")
            print(error.localizedDescription)
        }
    }
}

struct CatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CatView()
        }
    }
}

