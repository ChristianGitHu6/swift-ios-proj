//
//  ApiClient.swift
//  Networking
//
//  Created by Anna on 8/1/21.
//

import Foundation

public enum APIResult<Success, Failure> where Failure : CustomError {
    /// A success, storing a `Success` value.
    case success(Success)

    /// A failure, storing a `Failure` value.
    case failure(CustomError)
}

public enum Method: String {
    case GET
    case POST
}

class RequestModel {
    
    // MARK: - Properties
    var path: String {
        return ""
    }
    var parameters: [String: Any?] {
        return [:]
    }
    var headers: [String: String] {
        return [:]
    }
    var method: Method {
        return .GET
    }
    var body: [String: Any?] {
        return [:]
    }
}


class APIClient {
    static var sharedInstace = APIClient()
//    private let baseUrl = "https://jsonplaceholder.typicode.com"
    private let baseUrl = "https://reqres.in/api"

    public func request<T: Codable>(request:RequestModel, completition: @escaping((APIResult<T, CustomError>) -> Void)) {
        
        if let request = self.createRequest(requestData: request){
            call(with: request, completition: completition)
        }
    }
    
    private func createRequest(requestData: RequestModel) -> URLRequest?{
        let path = "\(baseUrl)\(requestData.path)"
        guard let url = URL(string: path) else {  return nil}
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(testToken, forHTTPHeaderField: "imtoken")
        
        if !requestData.parameters.isEmpty,
           let httpBody = try? JSONSerialization.data(withJSONObject: requestData.parameters, options: []) {
            request.httpBody = httpBody
        }
        
        if !requestData.headers.isEmpty {
            for header in requestData.headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        return request
    }
    
    private func call<T: Codable>(with request: URLRequest,
                                  completition: @escaping(APIResult<T, CustomError>) -> Void){
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil || data == nil {
                print("Client error!")
                return
            }

            if let httpResponse = response as? HTTPURLResponse{
                let statusCode = httpResponse.statusCode
                guard let data = data  else { return }
                if (200...399).contains(statusCode) {
                    self.handleSuccessCode(completition: completition, data: data)
                }else{
                    self.handleFailureCode(completition: completition, data: data)
                }
            }
        }
        
        dataTask.resume()
    }
    
    private func handleSuccessCode<T: Codable>(completition: @escaping(APIResult<T, CustomError>) -> Void,
                                               data: Data){
        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            DispatchQueue.main.async {
                completition(.success(object))
            }
        } catch {
            print("Faile decoding of \(T.self)")
            DispatchQueue.main.async {
                completition(.failure(CustomError(code: -10, msg: "Faile decoding of \(T.self)")))
            }
        }
    }
    
    private func handleFailureCode<T: Codable>(completition: @escaping(APIResult<T, CustomError>) -> Void,
                                               data: Data){
        do {
            let object = try JSONDecoder().decode(CustomError.self, from: data)
            DispatchQueue.main.async {
                completition(.failure(object))
            }
        } catch {
            print("Faile decoding of ErrorModel")
            DispatchQueue.main.async {
                completition(.failure(CustomError(code: -10, msg: "bad error")))
            }
        }
    }
}

let testToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIiwianRpIjoiMTE2MDcifQ.eyJpc3MiOiJodHRwOlwvXC9hZG1pbi5tZWRuZXQuYW0iLCJhdWQiOiJodHRwOlwvXC9hZG1pbi5tZWRuZXQuYW0iLCJqdGkiOiIxMTYwNyIsImlhdCI6MTYxMDYxODQ2NiwibmJmIjoxNjEwNjE4NTI2LCJleHAiOjE2MTIwNTg0NjYsInVpZCI6MTA0NSwic2lkIjoxMTYwNywibGV2ZWwiOjQsIm9zIjoidW5rbm93biIsImlwIjoiMTAuMC4wLjEiLCJhcGlLZXlJZCI6NiwiaG9zdCI6IjEwLjAuMC4xIiwidXVpZCI6IjAuMCJ9."
