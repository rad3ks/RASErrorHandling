//
//  ViewController.swift
//  RASErrorHandling
//
//  Created by Radoslaw Szeja on 20/06/2017.
//  Copyright © 2017 Radek Szeja. All rights reserved.
//

import UIKit
import Result
import ReactiveSwift

internal enum MainViewError: Error, CustomStringConvertible {
    case failedGettingUserProfile(Error)
    case failedRegisterUser(Error)
    case failedUpdatingUser(Error)
    case serverError(HTTPError)
    
    var description: String {
        switch self {
        case .failedGettingUserProfile:
            return "failed getting user profile"
        case .failedRegisterUser:
            return "failed register user"
        case .failedUpdatingUser:
            return "failed updating user"
        case .serverError:
            return "server error"
        }
    }
}

internal final class ViewController: UIViewController {

    @IBOutlet weak var userProfileButton: UIButton!
    @IBOutlet weak var registerUserButton: UIButton!
    @IBOutlet weak var updateUserProfileButton: UIButton!
    @IBOutlet weak var internalServerErrorButton: UIButton!
    
    @IBOutlet weak var errorTextView: UITextView!
    @IBOutlet weak var requestTextView: UITextView!
    @IBOutlet weak var responseTextView: UITextView!
    
    fileprivate let (lifetime, token) = Lifetime.make()
    
}

// MARK: - Actions
internal extension ViewController {
    
    @IBAction func didTapUserProfile(button: UIButton) {
        request(atPath: "/status/400")
            .flatMap(.latest, transform: perform)
            .flatMapError { error in
                SignalProducer(error: MainViewError.failedGettingUserProfile(error))
            }
            .observe(on: UIScheduler())
            .startWithFailed(handleMainView(error:))
    }
    
    @IBAction func didTapRegisterUser(button: UIButton) {
        request(atPath: "/status/401")
            .flatMap(.latest, transform: perform)
            .flatMapError { error in
                SignalProducer(error: MainViewError.failedRegisterUser(error))
            }
            .observe(on: UIScheduler())
            .startWithFailed(handleMainView(error:))
    }
    
    @IBAction func didTapUpdateUserProfile(button: UIButton) {
        request(atPath: "/status/404")
            .flatMap(.latest, transform: perform)
            .flatMapError { error in
                SignalProducer(error: MainViewError.failedUpdatingUser(error))
            }
            .observe(on: UIScheduler())
            .startWithFailed(handleMainView(error:))
    }
    
    @IBAction func didTapInternalServerError(button: UIButton) {
        request(atPath: "/status/500")
            .flatMap(.latest, transform: perform)
            .flatMapError { error in
                SignalProducer(error: MainViewError.serverError(error))
            }
            .observe(on: UIScheduler())
            .startWithFailed(handleMainView(error:))
    }
    
    @IBAction func didTapBadResponse(button: UIButton) {
        request(atPath: "/status/300")
            .flatMap(.latest, transform: perform)
            .flatMapError { error in
                SignalProducer(error: MainViewError.serverError(error))
            }
            .observe(on: UIScheduler())
            .startWithFailed(handleMainView(error:))
    }
    
    @IBAction func didTapOtherError(button: UIButton) {
        request(atPath: "/status/501")
            .flatMap(.latest, transform: perform)
            .flatMapError { error in
                SignalProducer(error: MainViewError.serverError(error))
            }
            .observe(on: UIScheduler())
            .startWithFailed(handleMainView(error:))
    }
    
}

fileprivate extension ViewController {
    
    func handleMainView(error: MainViewError) {
        var errorDescription = error.description
        
        func handle(httpError: HTTPError) {
            
            errorDescription += "(\(httpError.description))"
            
            switch httpError {
            case .badRequest(let transaction),
                 .unauthorized(let transaction),
                 .notFound(let transaction),
                 .internalServerError(let transaction),
                 .unclassified(let transaction):
                self.requestTextView.text = transaction.request.debugDescription
                self.responseTextView.text = transaction.response.debugDescription
            default: return
            }
        }
        
        func handlePossible(httpError error: Error) {
            if let httpError = error as? HTTPError {
                handle(httpError: httpError)
            }
            
        }
        
        switch error {
        case .failedGettingUserProfile(let error), .failedRegisterUser(let error), .failedUpdatingUser(let error):
            handlePossible(httpError: error)
        case .serverError(let httpError):
            handle(httpError: httpError)
        }
        
        self.errorTextView.text = errorDescription
    }
    
}

// MARK: - Networking
fileprivate extension ViewController {
    
    /// Creates a `URLRequest` with `NoError`
    ///
    /// - Parameter path: path to the resource
    /// - Returns: signal producer, that will produce signal with URLRequest and will never fail
    func request(atPath path: String) -> SignalProducer<URLRequest, NoError> {
        let baseURLString = "https://httpbin.org"
        return SignalProducer(result:
            Result(value:
                URLRequest(url:
                    URL(string: baseURLString + path)!
                )
            )
        )
    }
    
    /// Performs request that result in `HTTPResponse` or `HTTPError`
    ///
    /// - Parameter request: request to be performed
    /// - Returns: signal producer, that will produce signal with `HTTPResponse` or will fail with `HTTPError`
    func perform(request: URLRequest) -> SignalProducer<HTTPResponse, HTTPError> {
        return URLSession.shared.reactive.data(with: request)
            .take(during: lifetime)
            .flatMap(.latest, transform: parseResponse)
            .flatMap(.latest) { response in
                return SignalProducer.attempt {
                    let transaction = HTTPTransaction(request: request, response: response)
                    
                    switch response.response.statusCode {
                    case 200..<300: return response
                    case 300..<400: throw HTTPError.badResponse(nil)
                    case 400: throw HTTPError.badRequest(transaction)
                    case 401: throw HTTPError.unauthorized(transaction)
                    case 404: throw HTTPError.notFound(transaction)
                    case 500: throw HTTPError.internalServerError(transaction)
                    default: throw HTTPError.unclassified(transaction)
                    }
                }
            }
            .flatMapError { error in
                SignalProducer(error: HTTPError(error: error))
            }
        }
    
    func parse(data: Data?) throws -> [String: AnyObject]? {
        guard let data = data else {
            throw JSONDecodingError.missingBody
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) else {
            return nil
        }
        
        guard let dictionary = json as? [String: AnyObject] else {
            throw JSONDecodingError.unexpectedFormat(.dictionary)
        }
        
        return dictionary
    }
    
    func parseResponse(data: Data, response: URLResponse) -> SignalProducer<HTTPResponse, AnyError> {
        return SignalProducer.attempt {
            let json = try self.parse(data: data)
            
            guard let response = response as? HTTPURLResponse else {
                throw HTTPError.badResponse(nil)
            }
            
            return HTTPResponse(response: response, json: json)
        }
    }
    
}
