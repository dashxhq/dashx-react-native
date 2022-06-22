# iOS Native Module

## Development

### Obtaining Graphql schema and generating Graphql operation

- Make sure to install Apollo CLI via npm:

```sh
$ npm i -g apollo
```

- In order to generate code, Apollo requires local copy of Graphql schema, to download that:

```sh
$ apollo schema:download --endpoint="https://api.dashx.com/graphql" schema.json
```

This will save a `schama.json` file in your ios directory.

- Add Graphql request in `graphql` dir.

- Regenerate `API.swift` using:

```sh
$ apollo client:codegen --target=swift --namespace=DashXGql --localSchemaFile=schema.json --includes="graphql/*.graphql" --passthroughCustomScalars API.swift
```

For example, if you want to generate code for `FetchContent`.

- Download schema

```sh
$ apollo schema:download --endpoint="https://api.dashx.com/graphql" schema.json
```

- Add request in `graphql` dir with following contents:

```graphql
query FetchContent($input: FetchContentInput!) {
  fetchContent(input: $input)
}
```

- Re-generate API.swift so it includes the `FetchContent` operation

```sh
$ apollo client:codegen --target=swift --namespace=DashXGql --localSchemaFile=schema.json --includes="graphql/*.graphql" --passthroughCustomScalars API.swift
```

- Now you can use FetchContent operation like so:

```swift
let fetchContentInput  = DashXGql.FetchContentInput( // Note the DashXGql namespace
    contentType: contentType,
    content: content,
    preview: preview,
    language: language,
    fields: fields,
    include: include,
    exclude: exclude
)

DashXLog.d(tag: #function, "Calling fetchContent with \(fetchContentInput)")

let fetchContentQuery = DashXGql.FetchContentQuery(input: fetchContentInput)

Network.shared.apollo.fetch(query: fetchContentQuery, cachePolicy: .returnCacheDataElseFetch) { result in
  switch result {
  case .success(let graphQLResult):
    DashXLog.d(tag: #function, "Sent fetchContent with \(String(describing: graphQLResult))")
    let content = graphQLResult.data?.fetchContent
    resolve(content)
  case .failure(let error):
    DashXLog.d(tag: #function, "Encountered an error during fetchContent(): \(error)")
    reject("", error.localizedDescription, error)
  }

```

