//
//  PostView.swift
//  Anti-Sexiste
//
//  Created by user165109 on 02/03/2020.
//  Copyright © 2020 user165109. All rights reserved.
//

import SwiftUI
import Combine

struct PostView: View {
    @EnvironmentObject var userSession : UserSession
    @State var showingAddResponseView = false
    @ObservedObject var post : Post
    @ObservedObject var listPost : ListPost
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State private var showingAlert = false


    var failureMark: Alert {
        Alert(title: Text("Echec"), message: Text("Vous avez déjà voté pour ce post."), dismissButton: .default(Text("Ok")))
    }
    var listTypeResponse : ListTypeResponse = ListTypeResponse()
    
    
    @State var filteredListTypeResponse: [Response]
    
    @State var currentTypeResponse : String = "Tout"
    var body: some View {
        
        VStack{
            ZStack{
                VStack{
                    Text(self.post.message)
                        .multilineTextAlignment(.center)
                        .lineLimit(100)
                        .padding(.all)
                    VStack{
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(self.listTypeResponse.types) { type in
                                    Button(action: {
                                        if (type.typeResponse != "Tout"){
                                            self.filteredListTypeResponse = self.post.listResponse.filter { $0.typeResponse == type.typeResponse }
                                        }
                                        else{
                                            self.filteredListTypeResponse = self.post.listResponse
                                        }
                                    }) {
                                        VStack{
                                            Text(type.typeResponse)
                                                .font(.caption)
                                        }
                                        .padding(.leading)
                                    }
                                    
                                }
                            }
                        }
                        List{
                            ForEach(self.filteredListTypeResponse){ response in
                                ListRowResponseView(response:response)
                            }
                        }
                    }
                }
                VStack{
                    Spacer()
                    HStack {
                        if (self.userSession.isConnected && self.post.user != nil){
                            if (self.post.user! === self.userSession.user!){
                                HStack {
                                    Button(action: {
                                        self.listPost.deletePost(post: self.post)
                                        self.mode.wrappedValue.dismiss()
                                    }, label: {
                                        Image(systemName: "trash").resizable()
                                            .font(.system(.caption))
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(Color.white)
                                            .padding()
                                        
                                        })
                                        .background(Color.red)
                                        .cornerRadius(38.5)
                                        .padding()
                                        .shadow(color: Color.black.opacity(0.3),
                                                radius: 3,
                                                x: 3,
                                                y: 3)
                                    
                                }
                            }
                        }
                            
                        
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    self.showingAddResponseView.toggle()
                                }, label: {
                                    Image(systemName: "pencil.tip")
                                        .font(.system(.largeTitle))
                                        .frame(width: 57, height: 50)
                                        .foregroundColor(Color.white)
                                        .padding(.bottom, 7)
                                })
                                    .background(Color.blue)
                                    .cornerRadius(38.5)
                                    .padding()
                                    .shadow(color: Color.black.opacity(0.3),
                                            radius: 3,
                                            x: 3,
                                            y: 3).sheet(isPresented: $showingAddResponseView) {
                                                AddResponseView(showingAddResponseView : self.$showingAddResponseView, post : self.post, listTypeResponse: self.listTypeResponse).environmentObject(self.userSession)
                                }
                            }
                        }
                        
                    }
                }
                
        }.navigationBarTitle(post.title).navigationBarItems(trailing:
            HStack{
                if (userSession.isConnected){
                    Button(action: {
                        if (!self.post.increment(user: self.userSession.user!)){
                            self.showingAlert = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }.alert(isPresented: $showingAlert, content: {self.failureMark})
                }
                VStack{
                    Image(systemName: "flame").foregroundColor(.red)
                    Text(String(self.post.mark))
                }
                
                
            }
        )
        
    }
}

struct PostView_Previews: PreviewProvider {
    static let p = Post()
    static var previews: some View {
        PostView(post: self.p, listPost: ListPost(), filteredListTypeResponse : self.p.listResponse)
    }
}


///COM
