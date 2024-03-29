//
//  ApiEngine.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.04.2022.
//

import PromiseKit
import UIKit

enum ApiEngineError: Error {
   case unknown
   case statusCode(Int)
   case error(Error)
}

struct ApiEngineResult {
   let data: Data?
   let response: URLResponse?
}

@available(*, deprecated, message: "Use ApiWorksProtocol instead")
final class ApiEngine: ApiEngineProtocol {
   func process(endpoint: EndpointProtocol) -> Promise<ApiEngineResult> {
      Promise { seal in
         guard let url = URL(string: endpoint.endPoint) else {
            seal.reject(ApiEngineError.unknown)
            return
         }

         let method = endpoint.method
         let params = endpoint.body
         let headers = endpoint.headers

         var request = URLRequest(url: url)

         request.httpMethod = method.rawValue

         for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
         }

         if let jsonData = endpoint.jsonData {
            request.httpBody = jsonData
         } else {
            request.httpBody = params
               .map { (key: String, value: Any) in
                  key + "=\(value)"
               }
               .joined(separator: "&")
               .data(using: .utf8)
         }

         if Config.isDebugApiRequestLog { log(request, "REQUEST") }

         start(request: request, seal: seal)
      }
   }

   func processWithImage(endpoint: EndpointProtocol, image: UIImage) -> Promise<ApiEngineResult> {
      Promise { seal in
         guard let url = URL(string: endpoint.endPoint) else {
            seal.reject(ApiEngineError.unknown)
            return
         }

         guard let mediaImage = Media(withImage: image, forKey: "photo") else { return }

         let boundary = UUID().uuidString

         let method = endpoint.method
         let params = endpoint.body
         let headers = endpoint.headers

         var request = URLRequest(url: url)

         request.httpMethod = method.rawValue

         for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
         }
         request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

         let dataBody = createDataBody(withParameters: params, media: [mediaImage], boundary: boundary)
         request.httpBody = dataBody

         if Config.isDebugApiRequestLog { log(request, "REQUEST MULTIPART") }

         start(request: request, seal: seal)
      }
   }

   func processWithImages(endpoint: EndpointProtocol, images: [UIImage], names: [String]) -> Promise<ApiEngineResult> {
      Promise { seal in
         guard let url = URL(string: endpoint.endPoint) else {
            seal.reject(ApiEngineError.unknown)
            return
         }
         var mediaImages: [Media] = []
         for i in 0 ..< images.count {
            let image = images[i]
            let key = names[i]

            guard let mediaImage = Media(withImage: image, forKey: key) else { return }
            mediaImages.append(mediaImage)
         }

         let boundary = UUID().uuidString

         let method = endpoint.method
         let params = endpoint.body
         let headers = endpoint.headers

         var request = URLRequest(url: url)

         request.httpMethod = method.rawValue

         for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
         }
         request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

         let dataBody = createDataBody(withParameters: params, media: mediaImages, boundary: boundary)
         request.httpBody = dataBody

         if Config.isDebugApiRequestLog { log(request, "REQUEST MULTIPART") }

         start(request: request, seal: seal)
      }
   }

   func processPUT(endpoint: EndpointProtocol) -> Promise<ApiEngineResult> {
      Promise { seal in
         guard let url = URL(string: endpoint.endPoint) else {
            seal.reject(ApiEngineError.unknown)
            return
         }

         let boundary = UUID().uuidString

         let method = endpoint.method
         let params = endpoint.body
         let headers = endpoint.headers

         var request = URLRequest(url: url)

         request.httpMethod = method.rawValue

         for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
         }
         request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

         let dataBody = createDataBody(withParameters: params, media: [], boundary: boundary)
         request.httpBody = dataBody

         if Config.isDebugApiRequestLog { log(request, "REQUEST MULTIPART") }

         start(request: request, seal: seal)
      }
   }

   private func start(request: URLRequest, seal: Resolver<ApiEngineResult>) {
      let sessionConfig = URLSessionConfiguration.default
      sessionConfig.timeoutIntervalForRequest = Config.httpTimeout
      sessionConfig.timeoutIntervalForResource = Config.httpTimeout
      let session = URLSession(configuration: sessionConfig)

      if
         Config.isDebugApiRequestBodyLog,
         let body = request.httpBody
      {
         let bodyString = String(decoding: body, as: UTF8.self)
         let dict = bodyString.components(separatedBy: "&").reduce(into: [String: String]()) { result, pair in
            let components = pair.components(separatedBy: "=")
            if components.count == 2 {
               result[components[0]] = components[1]
            }
         }

         do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
               log("\(jsonString)", "Request Body")
            }
         } catch {
            print("Error: \(error.localizedDescription)")
         }
      }

      let task = session.dataTask(with: request) { data, response, error in

         guard let data = data else {
            guard let error = error else {
               seal.reject(ApiEngineError.unknown)
               print("\nResponse:\n\(String(describing: response))\n\nData:\n\(String(describing: data))\n\nError:\n\(String(describing: error)))")
               return
            }

            print("\nResponse:\n\(String(describing: response))\n\nData:\n\(String(describing: data))\n\nError:\n\(String(describing: error)))")
            print(error)
            seal.reject(ApiEngineError.error(error))
            return
         }

         let apiResult = ApiEngineResult(data: data, response: response)

         if Config.isDebugApiResponseStatusCodeLog {
            guard let httpResp = apiResult.response as? HTTPURLResponse,
                  let url = httpResp.url else { return }
            log(
               "\(String(describing: url)): \(String(describing: httpResp.statusCode))",
               "Response Status Code"
            )
         }

         if Config.isDebugApiResponseLog {
            log("\(String(describing: apiResult.response as? HTTPURLResponse))", " Response Status")
         }

         if Config.isDebugApiResponseBodyLog {
            let str = String(decoding: data, as: UTF8.self)
            log("\(str)", "Result Body")
         }

         guard
            let httpResponse = apiResult.response as? HTTPURLResponse,
            case 200 ... 299 = httpResponse.statusCode
         else {
            if let httpResponse = apiResult.response as? HTTPURLResponse,
               httpResponse.statusCode == 404 {
               seal.reject(ApiEngineError.statusCode(404))
               return
            }
            seal.reject(ApiEngineError.unknown)
            return
         }

         seal.fulfill(apiResult)
      }

      task.resume()
   }

   private func createDataBody(withParameters params: [String: Any]?, media: [Media]?, boundary: String) -> Data {
      let lineBreak = "\r\n"
      var body = Data()

      if let params {
         for (key, value) in params {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
            // body.append("\(value) + lineBreak)")
            let s = String(describing: value)
            body.append(s)
            body.append(lineBreak)
         }
      }

      if let media {
         for photo in media {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.fileName)\"\(lineBreak)")
            body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
            body.append(photo.data)
            body.append(lineBreak)
         }
      }

      body.append("--\(boundary)--\(lineBreak)")

      return body
   }
}

extension Data {
   mutating func append(_ string: String) {
      if let data = string.data(using: .utf8) {
         append(data)
      }
   }
}

struct Media {
   let key: String
   let fileName: String
   let data: Data
   let mimeType: String

   init?(withImage image: UIImage, forKey key: String, fileName: String? = nil) {
      self.key = key
      mimeType = "image/jpg"
      self.fileName = fileName == nil ? "\(arc4random()).jpeg" : fileName.string

      guard let data = image.jpegData(compressionQuality: 0.1) else { return nil }
      self.data = data
   }
}
