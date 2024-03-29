//
//  Api.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.06.2023.
//

import ReactiveWorks
import UIKit

final class ApiWorks: ApiWorksProtocol, WorkBasket {
   let retainer = Retainer()

   func process(endpoint: EndpointProtocol) -> Out<ApiEngineResult> {
      Out { [weak self] seal in

         var urlComponents = URLComponents(string: endpoint.endPoint)
         let method = endpoint.method
         let params = endpoint.body
         let headers = endpoint.headers

         if method == .get, params.isEmpty == false {
            urlComponents?.queryItems = params.map {
               URLQueryItem(name: $0, value: "\($1)")
            }
         }

         guard let url = urlComponents?.url else {
            seal.fail(ApiEngineError.unknown)
            seal.fail()
            print("urlComponents?.url is Nil")
            return
         }

         var request = URLRequest(url: url)

         request.httpMethod = method.rawValue

         for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
         }

         if method != .get {
            if let jsonData = endpoint.jsonData {
               request.httpBody = jsonData
               request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            } else if let jsonData = try? JSONSerialization.data(withJSONObject: params, options: []) {
               request.httpBody = jsonData
               request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            }
         }

         if Config.isDebugApiRequestLog { log(request, "REQUEST") }

         self?.start(request: request, seal: seal)

      }.retainBy(retainer).doAsync()
   }

   func processWithImage(endpoint: EndpointProtocol, image: UIImage) -> Out<ApiEngineResult> {
      Out { [weak self] seal in
         guard let url = URL(string: endpoint.endPoint) else {
            seal.fail(ApiEngineError.unknown)
            seal.fail()
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

         let dataBody = self?.createDataBody(withParameters: params, media: [mediaImage], boundary: boundary)
         request.httpBody = dataBody

         if Config.isDebugApiRequestLog { log(request, "REQUEST MULTIPART") }

         self?.start(request: request, seal: seal)
      }.retainBy(retainer).doAsync()
   }

   func processWithImages(endpoint: EndpointProtocol, images: [UIImage], names: [String]) -> Out<ApiEngineResult> {
      Out { [weak self] seal in
         guard let url = URL(string: endpoint.endPoint) else {
            seal.fail(ApiEngineError.unknown)
            seal.fail()
            return
         }
         var mediaImages: [Media] = []
         for i in 0 ..< images.count {
            let image = images[i]
            let key = names[i]

            guard let mediaImage = Media(withImage: image, forKey: key, fileName: key) else { return }
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

         let dataBody = self?.createDataBody(withParameters: params, media: mediaImages, boundary: boundary)
         request.httpBody = dataBody

         if Config.isDebugApiRequestLog { log(request, "REQUEST MULTIPART") }

         self?.start(request: request, seal: seal)
      }.retainBy(retainer).doAsync()
   }

   func processPUT(endpoint: EndpointProtocol) -> Out<ApiEngineResult> {
      Out { [weak self] seal in
         guard let url = URL(string: endpoint.endPoint) else {
            seal.fail(ApiEngineError.unknown)
            seal.fail()
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

         let dataBody = self?.createDataBody(withParameters: params, media: [], boundary: boundary)
         request.httpBody = dataBody

         if Config.isDebugApiRequestLog { log(request, "REQUEST MULTIPART") }

         self?.start(request: request, seal: seal)
      }.retainBy(retainer).doAsync()
   }

   private func start(request: URLRequest, seal: Out<ApiEngineResult>) {
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
               seal.fail(ApiEngineError.unknown)
               seal.fail()
               print("\nResponse:\n\(String(describing: response))\n\nData:\n\(String(describing: data))\n\nError:\n\(String(describing: error)))")
               return
            }

            print("\nResponse:\n\(String(describing: response))\n\nData:\n\(String(describing: data))\n\nError:\n\(String(describing: error)))")
            print(error)

            let httpResponse = response as? HTTPURLResponse
            if let code = httpResponse?.statusCode {
               seal.fail(ApiEngineError.statusCode(code))
               seal.fail()
            } else {
               seal.fail(ApiEngineError.unknown)
               seal.fail()
            }

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

         let httpResponse = apiResult.response as? HTTPURLResponse

         guard
            let httpResponse,
            case 200 ... 299 = httpResponse.statusCode
         else {
            if let code = httpResponse?.statusCode {
               seal.fail(ApiEngineError.statusCode(code))
               seal.fail()
            } else {
               seal.fail(ApiEngineError.unknown)
               seal.fail()
            }
            return
         }

         seal.success(apiResult)
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
            if let res = value as? [[String: Any]] {
               if let data = try? JSONSerialization.data(
                  withJSONObject: res,
                  options: []
               ) {
                  let jsonString: String? = String(data: data, encoding: .utf8)
                  body.append(jsonString ?? s)
               }
            } else {
               body.append(s)
            }

            body.append(lineBreak)
         }
      }

      if let media {
         for photo in media {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"photos\"; filename=\"\(photo.fileName)\"\(lineBreak)")
            body.append("Content-Type: image/jpeg\(lineBreak + lineBreak)")
            body.append(photo.data)
            body.append(lineBreak)
         }
      }

      body.append("--\(boundary)--\(lineBreak)")

      return body
   }
}
