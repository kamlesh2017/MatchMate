//
//  Models.swift
//  MatchMate
//
//  Created by Kamlesh Kumar Sharma on 27/01/25.
//

struct APIResponse: Decodable {
    let results: [UserProfileResponse]?
}

struct UserProfileResponse: Decodable {
    let name: NameResponse?
    let email: String?
    let location: LocationResponse?
    let picture: PictureResponse?
    let registered: RegisteredResponse?
}

struct NameResponse: Decodable {
    let title: String?
    let first: String?
    let last: String?
}

struct LocationResponse: Decodable {
    let city: String?
    let state: String?
}

struct PictureResponse: Decodable {
    let large: String?
}

struct RegisteredResponse: Decodable {
    let age: Float?
}
