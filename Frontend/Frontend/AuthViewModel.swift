//
//  AuthViewModel.swift
//  Frontend
//
//  Created by Stanisław Szast on 01/07/2025.
//
import Foundation

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var token: String? {
        didSet {
            if let token = token {
                UserDefaults.standard.set(token, forKey: "authToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "authToken")
            }
        }
    }

    private let baseURL = "http://localhost:3000"

    init() {
        self.token = UserDefaults.standard.string(forKey: "authToken")
        self.isLoggedIn = token != nil
    }

    func register(email: String, password: String) {
        guard let url = URL(string: "\(baseURL)/register") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { _, response, _ in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self.login(email: email, password: password)
                }
            }
        }.resume()
    }

    func login(email: String, password: String) {
        guard let url = URL(string: "\(baseURL)/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let result = try? JSONDecoder().decode([String: String].self, from: data),
               let token = result["token"] {
                DispatchQueue.main.async {
                    self.token = token
                    self.isLoggedIn = true
                }
            }
        }.resume()
    }

    func changePassword(newPassword: String) {
        guard let url = URL(string: "\(baseURL)/change-password"),
              let token = token else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["token": token, "newPassword": newPassword]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request).resume()
    }

    func deleteAccount() {
        guard let url = URL(string: "\(baseURL)/delete-account"),
              let token = token else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["token": token]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                self.token = nil
                self.isLoggedIn = false
            }
        }.resume()
    }

    func logout() {
        self.token = nil
        self.isLoggedIn = false
    }
}
