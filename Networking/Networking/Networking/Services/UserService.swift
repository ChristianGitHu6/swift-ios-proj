//
//  UserService.swift
//  Networking
//
//  Created by Anna on 8/1/21.
//

import Foundation


protocol PostsServiceProtocol {
    func getUser(completition: @escaping((APIResult<User, CustomError>) -> Void))
    func getUsersPage(completition: @escaping((APIResult<UsersPage, CustomError>) -> Void))
}

class UserService {
    public static let shared: UserService = UserService()
    private let apiClient = APIClient.sharedInstace
    
    private enum PostsServiceEndPoint : String {
        case getUser = "/users"
    }
    
    private class UserRequestModel: RequestModel {
        var userId: Int
        
        init(userId:Int) {
            self.userId = userId
        }
        
        override var path: String {
            return "\(PostsServiceEndPoint.getUser.rawValue)/\(userId)"
        }
        
        override var method: Method {
            return Method.GET
        }
    }
    
    private class UsersPageRequestModel: RequestModel {
        var pageNumber: Int
        
        init(pageNumber:Int) {
            self.pageNumber = pageNumber
        }
        
        override var path: String {
            return "\(PostsServiceEndPoint.getUser.rawValue)?page=\(pageNumber)"
        }
        
        override var method: Method {
            return Method.GET
        }
    }
}

extension UserService : PostsServiceProtocol {
    func getUser(completition: @escaping ((APIResult<User, CustomError>) -> Void)) {
        apiClient.request(request: UserRequestModel(userId: 2), completition: completition)
    }
    
    func getUsersPage(completition: @escaping ((APIResult<UsersPage, CustomError>) -> Void)) {
        apiClient.request(request: UsersPageRequestModel(pageNumber: 2), completition: completition)
    }
}
