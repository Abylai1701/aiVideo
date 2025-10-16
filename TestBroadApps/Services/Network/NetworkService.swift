//
//  NetworkService.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 10.10.2025.
//

import Alamofire
import UniformTypeIdentifiers

final class NetworkService {

    // MARK: - Private Properties
    private lazy var retryPolicy = makeRetryPolicy()

    // MARK: - Public Methods

    func get<T: Decodable>(
        url: URL,
        headers: HTTPHeaders = []
    ) async throws -> T {
        try await AF.request(
            url,
            method: .get,
            headers: headers,
            interceptor: retryPolicy
        )
        .validate()
        .serializingDecodable(T.self)
        .value
    }

    func post<T: Decodable>(
        url: URL,
        headers: HTTPHeaders = [],
        formData: @escaping (MultipartFormData) -> Void
    ) async throws -> T {
        try await AF.upload(
            multipartFormData: formData,
            to: url,
            method: .post,
            headers: headers,
            interceptor: retryPolicy
        )
        .validate()
        .serializingDecodable(T.self)
        .value
    }

    func postJSON<T: Decodable, Body: Encodable>(
        url: URL,
        headers: HTTPHeaders = [.contentType("application/json")],
        body: Body
    ) async throws -> T {
        try await AF.request(
            url,
            method: .post,
            parameters: body,
            encoder: JSONParameterEncoder.default,
            headers: headers,
            interceptor: retryPolicy
        )
        .validate()
        .serializingDecodable(T.self)
        .value
    }

    func download(
        url: URL,
        headers: HTTPHeaders = [],
        to destinationURL: URL
    ) async throws -> URL {
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            return destinationURL
        }

        return try await AF.download(
            url,
            method: .get,
            headers: headers,
            interceptor: retryPolicy,
            requestModifier: Modifier.timeout(600),
            to: { _, _ in
                (destinationURL, [.removePreviousFile, .createIntermediateDirectories])
            }
        )
        .validate()
        .serializingDownloadedFileURL()
        .value
    }

    func patch<T: Decodable, U: Encodable>(
        url: URL,
        body: U,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(
                url,
                method: .patch,
                parameters: body,
                encoder: JSONParameterEncoder.default,
                headers: headers
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func delete(
        url: URL,
        headers: HTTPHeaders = []
    ) async throws {
        try await AF.request(
            url,
            method: .delete,
            headers: headers,
            interceptor: retryPolicy
        )
        .validate()
        .serializingData()
        .value
    }
    // MARK: - Private Helpers

    private func makeRetryPolicy() -> RetryPolicy {
        var retryableMethods = RetryPolicy.defaultRetryableHTTPMethods
        retryableMethods.insert(.get)
        retryableMethods.insert(.post)
        retryableMethods.insert(.delete)
        return RetryPolicy(retryLimit: 3, retryableHTTPMethods: retryableMethods)
    }
}

// MARK: - Timeout Modifier

private extension NetworkService {
    enum Modifier {
        static func timeout(_ interval: TimeInterval) -> Alamofire.Session.RequestModifier {
            { $0.timeoutInterval = interval }
        }
    }
}
