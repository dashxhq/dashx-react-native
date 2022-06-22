import Foundation
import Apollo

class Network {
    static let shared = Network()
    private var baseUri: String = "https://api.dashx.com/graphql"

    func setBaseUri(to: String) {
      self.baseUri = to
    }

    private(set) lazy var apollo: ApolloClient = {
        let client = URLSessionClient()
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        let provider = NetworkInterceptorProvider(client: client, store: store)
        let url = URL(string: baseUri)!
        let transport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: url
        )
        return ApolloClient(networkTransport: transport, store: store)
    }()
}

class NetworkInterceptorProvider: LegacyInterceptorProvider {
    override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(ConfigInterceptor.shared, at: 0)
        return interceptors
    }
}

class ConfigInterceptor: ApolloInterceptor {
    static let shared = ConfigInterceptor()

    var publicKey: String?
    var targetInstallation: String?
    var targetEnvironment: String?
    var identityToken: String?

    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {

        if let publicKey = self.publicKey {
            request.addHeader(name: "X-PUBLIC-KEY", value: "\(publicKey)")
        }

        if let targetInstallation = self.targetInstallation {
            request.addHeader(name: "X-TARGET-INSTALLATION", value: "\(targetInstallation)")
        }

        if let targetEnvironment = self.targetEnvironment {
            request.addHeader(name: "X-TARGET-ENVIRONMENT", value: "\(targetEnvironment)")
        }

        if let identityToken = self.identityToken {
            request.addHeader(name: "X-IDENTITY-TOKEN", value: "\(identityToken)")
        }

        chain.proceedAsync(
            request: request,
            response: response,
            completion: completion
        )
    }
}
