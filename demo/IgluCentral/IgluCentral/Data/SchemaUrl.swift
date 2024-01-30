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

struct SchemaUrl {
    let url: String
    let name: String
    let version: String
    let vendor: String
}

extension SchemaUrl {
    static func fromUrl(_ url: String) -> SchemaUrl? {
        let slashParts = url.split(separator: "/")
        guard slashParts.count == 4 else { return nil }
        
        let vendorParts = slashParts[0].split(separator: ":")
        guard vendorParts.count == 2 else { return nil }
        
        let vendor = String(vendorParts[1])
        let name = String(slashParts[1])
        let version = String(slashParts[3])
        
        return SchemaUrl(url: url, name: name, version: version, vendor: vendor)
    }
}
