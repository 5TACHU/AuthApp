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
    
    @Published var message: String = ""
    @Published var showAlert = false

    private let baseURL = "http://localhost:3000"

    init() {
        self.token = UserDefaults.standard.string(forKey: "authToken")
        self.isLoggedIn = token != nil
    }
    
    private func handleResponse(data: Data?, response: URLResponse?, error: Error?) -> String? {
        guard let httpResponse = response as? HTTPURLResponse else {
            return "Brak odpowiedzi serwera."
        }

        if httpResponse.statusCode != 200 {
            if let data = data,
               let json = try? JSONDecoder().decode([String: String].self, from: data),
               let errorMessage = json["error"] {
                return errorMessage
            } else {
                return "Wystąpił błąd: \(httpResponse.statusCode)"
            }
        }
            return nil
        }

    func register(email: String, password: String) {
        guard !email.isEmpty && !password.isEmpty else {
            showError("Email i hasło są wymagane.")
            return
        }

        guard isValidEmail(email) else {
            showError("Niepoprawny adres email.")
            return
        }

        guard isStrongPassword(password) else {
            showError("Hasło musi mieć min. 8 znaków, 1 wielką literę i 1 znak specjalny.")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/register") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let errorMsg = self.handleResponse(data: data, response: response, error: error) {
                DispatchQueue.main.async {
                    self.showError(errorMsg)
                }
                return
            }

            DispatchQueue.main.async {
                self.login(email: email, password: password)
                self.showSuccess("Konto utworzone.")
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

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let errorMsg = self.handleResponse(data: data, response: response, error: error) {
                DispatchQueue.main.async {
                    self.showError(errorMsg)
                }
                return
            }

            if let data = data,
               let result = try? JSONDecoder().decode([String: String].self, from: data),
               let token = result["token"] {
                DispatchQueue.main.async {
                    self.token = token
                    self.isLoggedIn = true
                    self.showSuccess("Zalogowano.")
                }
            }
        }.resume()
    }

    func changePassword(newPassword: String) {
        guard let url = URL(string: "\(baseURL)/change-password"),
              let token = token else { return }

        guard isStrongPassword(newPassword) else {
            showError("Hasło musi mieć min. 8 znaków, 1 wielką literę i 1 znak specjalny.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["token": token, "newPassword": newPassword]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let errorMsg = self.handleResponse(data: data, response: response, error: error) {
                DispatchQueue.main.async {
                    self.showError(errorMsg)
                }
                return
            }

            DispatchQueue.main.async {
                self.showSuccess("Hasło zostało zmienione.")
            }
        }.resume()
    }

    func deleteAccount() {
        guard let url = URL(string: "\(baseURL)/delete-account"),
              let token = token else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["token": token]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let errorMsg = self.handleResponse(data: data, response: response, error: error) {
                DispatchQueue.main.async {
                    self.showError(errorMsg)
                }
                return
            }

            DispatchQueue.main.async {
                self.logout()
                self.showSuccess("Konto zostało usunięte.")
            }
        }.resume()
    }

    
    func logout() {
        self.token = nil
        self.isLoggedIn = false
    }
    
    private func showError(_ message: String) {
        self.message = message
        self.showAlert = true
    }

    private func showSuccess(_ message: String) {
        self.message = message
        self.showAlert = true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }

    private func isStrongPassword(_ password: String) -> Bool {
        let regex = #"^(?=.*[A-Z])(?=.*[^a-zA-Z0-9]).{8,}$"#
        return password.range(of: regex, options: .regularExpression) != nil
    }
    
}
