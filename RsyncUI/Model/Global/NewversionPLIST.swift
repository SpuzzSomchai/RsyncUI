//
//  Newversion.swift
//  RsyncUI
//
//  Created by Thomas Evensen on 12/04/2021.
//

import Combine
import Foundation

enum APIError: Error, LocalizedError {
    case unknown, apiError(reason: String)

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case let .apiError(reason):
            return reason
        }
    }
}

final class NewversionPLIST: ObservableObject {
    @Published var notifynewversion: Bool = false

    private var runningversion: String?
    private var urlstring: String = ""
    private var url: URL?
    private var subscriber: AnyCancellable?

    func fetch(url: URL) -> AnyPublisher<Data, APIError> {
        let request = URLRequest(url: url)

        return URLSession.DataTaskPublisher(request: request, session: .shared)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, 200 ..< 300 ~= httpResponse.statusCode else {
                    throw APIError.unknown
                }
                return data
            }
            .mapError { error in
                if let error = error as? APIError {
                    return error
                } else {
                    return APIError.apiError(reason: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }

    func setnewverion(_: String) {
        globalMainQueue.async {
            // self.notifynewversion = false
        }
        // print(respons)
        subscriber?.cancel()
    }

    init() {
        runningversion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        urlstring = Resources().getResource(resource: .urlPLIST)
        if let url = URL(string: urlstring) {
            subscriber = fetch(url: url)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                }, receiveValue: { [unowned self] data in
                    guard let response = String(data: data, encoding: .utf8) else { return }
                    setnewverion(response)
                })
        }
    }
}
