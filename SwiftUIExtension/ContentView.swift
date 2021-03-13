//
//  ContentView.swift
//  SwiftUIExtension
//
//  Created by Andy Kim on 12/3/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            VStack {
                Image("icon-main")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 120)
                    .cornerRadius(18)
                    .padding()
                
                Text("Simple Embed Helper for SwiftUI")
                    .padding()
                
                versionView
            }
        }
        .frame(width: 320, height: 240, alignment: .center)
    }
    
    private var versionView: some View {
        Text(Bundle.main.releaseVersionNumberPretty)
            .foregroundColor(.gray)
            .frame(height: 20)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
