//  Copyright (c) 2013-2023 Snowplow Analytics Ltd. All rights reserved.
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

struct SchemaList: View {
    @State var schemas: [SchemaUrl] = []
    @State private var searchText = ""
    
    var filteredSchemas: [SchemaUrl] {
        if searchText.isEmpty { return schemas }
        return schemas.filter { schema in
            return schema.url.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        List(filteredSchemas, id: \.url) { schema in
            NavigationLink {
                SchemaDetail(url: schema)
            } label: {
                VStack(alignment: .leading) {
                    Text("Name").font(.caption)
                    Text(schema.name).fontWeight(.heavy)
                    Spacer()
                    Text("Vendor").font(.caption)
                    Text(schema.vendor).fontWeight(.light)
                    Text("Version").font(.caption)
                    Text(schema.version).fontWeight(.light)
                }
            }
            .padding(.top)
        }
        .navigationTitle("Schemas")
        .onAppear(perform: {
            IgluCentralAPI.schemas { schemas = $0 }
        })
        .searchable(text: $searchText)
        .snowplowScreen(name: "SchemaList")
    }
}

struct SchemaList_Previews: PreviewProvider {
    static var previews: some View {
        SchemaList()
    }
}