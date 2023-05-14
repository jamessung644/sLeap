//
//  ContentView.swift
//  sLeap iOS App
//
//  Created by 성수한 on 2023/05/12.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("안녕")
                .font(.title)
                .fontWeight(.light)
                .foregroundColor(Color.blue)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
