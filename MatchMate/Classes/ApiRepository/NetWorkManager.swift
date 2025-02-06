//
//  NetWorkManager.swift
//  MatchMate
//
//  Created by Kamlesh Kumar Sharma on 26/01/25.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}

    private let baseURL = "https://randomuser.me/api/"

    // Fetch profiles with pagination
    func fetchProfiles(page: Int, pageSize: Int, completion: @escaping (Result<[UserProfileResponse], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)?results=\(pageSize)&page=\(page)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                completion(.success(decodedResponse.results ?? []))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
