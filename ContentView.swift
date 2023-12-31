//
//  ContentView.swift
//  Boss5207418
//
//  Created by Rachelle Ford on 6/13/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore

    func listen() {
        session.listen()
    }

    var body: some View {
        Group {
            if session.session != nil {
                HomeView()
            } else {
                HomeView()
            }
        }
        .onAppear(perform: listen)
    }
}
