//
//  ContentView.swift
//  Frontend
//
//  Created by Stanisław Szast on 01/07/2025.
//
import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    
    var body: some View {
        NavigationStack{
            if auth.isLoggedIn{
                MainView()
            } else {
                LoginView()
            }
        }
    }
}

