//  Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
//
//  This program is licensed to you under the Apache License Version 2.0,
//  and you may not use this file except in compliance with the Apache License
//  Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
//  http://www.apache.org/licenses/LICENSE-2.0.
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Apache License Version 2.0 is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the Apache License Version 2.0 for the specific
//  language governing permissions and limitations there under.

import Foundation

class IgluCentralAPI {
    static var endpoint = "http://iglucentral.com"
    
    class func schemas(completion: @escaping (([SchemaUrl]) -> ())) {
        guard let url = URL(string: "\(endpoint)/schemas") else {
            print("API end point is invalid")
            return
        }
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
            }
            if let data = data {
                if let response = try? JSONDecoder().decode([String].self, from: data) {
                    let schemas = response
                        .map({ SchemaUrl.fromUrl($0) })
                        .filter({ $0 != nil })
                        .map({ $0! })
                        .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
                    
                    DispatchQueue.main.async {
                        completion(schemas)
                    }
                }
            }
        }
        task.resume()
    }

    class func schema(url: SchemaUrl, completion: @escaping ((Schema, String) -> ())) {
        guard let url = URL(string: "\(endpoint)/schemas/\(url.vendor)/\(url.name)/jsonschema/\(url.version)") else {
            print("API end point is invalid")
            return
        }
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
            }
            if let data = data {
                if let object = try? JSONSerialization.jsonObject(with: data),
                   let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
                   let prettyFormatted = String(data: prettyData, encoding: .utf8),
                   let schema = try? JSONDecoder().decode(Schema.self, from: data) {
                    DispatchQueue.main.async {
                        completion(schema, prettyFormatted)
                    }
                }
            }
        }
        task.resume()
    }
}
