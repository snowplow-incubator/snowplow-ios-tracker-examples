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

import SwiftUI
import SnowplowTracker

struct SchemaDetail: View {
    var url: SchemaUrl
    @SwiftUI.State var schema: Schema?
    @SwiftUI.State var json: String?
    
    var body: some View {
        List {
            Section("General Information") {
                VStack(alignment: .leading) {
                    Text("URL").font(.caption)
                    Text(url.url).fontWeight(.light)
                }
                VStack(alignment: .leading) {
                    Text("Name").font(.caption)
                    Text(url.name).fontWeight(.light)
                }
                VStack(alignment: .leading) {
                    Text("Vendor").font(.caption)
                    Text(url.vendor).fontWeight(.light)
                }
                VStack(alignment: .leading) {
                    Text("Version").font(.caption)
                    Text(url.version).fontWeight(.light)
                }
                if let schema = schema {
                    VStack(alignment: .leading) {
                        Text("Description").font(.caption)
                        Text(schema.description)
                    }
                }
            }
            if let json = json {
                Section("JSON schema") {
                    Text(json)
                        .font(Font.footnote.monospaced())
                }
            }
        }
        .onAppear(perform: {
            IgluCentralAPI.schema(url: url) { schema, json in
                self.schema = schema
                self.json = json
            }
        })
        .navigationTitle(url.name)
        .snowplowScreen(
            name: "SchemaDetail",
            entities: [
                (
                    schema: "iglu:com.snowplowanalytics.iglu/anything-a/jsonschema/1-0-0",
                    data: [
                        "name": url.name,
                        "vendor": url.vendor,
                    ]
                )
            ]
        )
    }
}

struct SchemaDetail_Previews: PreviewProvider {
    static var previews: some View {
        SchemaDetail(
            url: SchemaUrl.fromUrl("iglu:com.snowplowanalytics.snowplow/anon_ip/jsonschema/1-0-0")!
        )
    }
}
