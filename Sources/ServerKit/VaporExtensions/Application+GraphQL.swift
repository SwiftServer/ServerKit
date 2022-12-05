import GraphQL
import Graphiti
import Vapor

extension Application {
    public struct GraphQL {
        let application: Application
    }

    public var graphql: GraphQL { GraphQL(application: self) }
}

extension Application.GraphQL {
    public struct Server {
        let application: Application
    }

    public var server: Server { Server(application: application) }

    public struct Configuration {
        public var path: PathComponent = "graphql"
        public var playgroundPath: PathComponent = ""
        var graphqlSchema: GraphQLSchema? = nil

        public mutating func schema(@ComponentBuilder<GraphQLResolver, GraphQLContext> _ components: () -> [Component<GraphQLResolver, GraphQLContext>]) throws {
            try self.graphqlSchema = Schema(components).schema
        }
    }

    struct ConfigurationKey: StorageKey {
        typealias Value = Configuration
    }

    public var configuration: Configuration {
        get { application.storage[ConfigurationKey.self] ?? Configuration() }
        nonmutating set { application.storage[ConfigurationKey.self] = newValue }
    }

    public func configureApplication() {
        application.on(.POST, configuration.path, use: runGraphQLOperation)
        application.on(.GET, configuration.playgroundPath) { request in
            Response(status: .ok,
                     headers: HTTPHeaders([(HTTPHeaders.Name.contentType.description, "text/html")]),
                     body: Response.Body(string: playground(path: configuration.path.description)))
        }
    }

    func runGraphQLOperation(request: Request) async throws -> GraphQLResult {
        guard let schema = configuration.graphqlSchema else {
            throw Abort(.notFound, reason: "GraphQL: No schema found")
        }

        let resolver = GraphQLResolver(application: application)
        let context = GraphQLContext(request: request)
        let graphRequest = try request.graphql

        return try await graphql(
            schema: schema,
            request: graphRequest.query,
            rootValue: resolver,
            context: context,
            eventLoopGroup: application.eventLoopGroup,
            variableValues: graphRequest.variables,
            operationName: graphRequest.operationName)
    }
}

extension Application.GraphQL.Server {
    public var configuration: HTTPServer.Configuration {
        get { application.http.server.configuration }
        nonmutating set { application.http.server.configuration = newValue }
    }
}

fileprivate func playground(path: String) -> String {
    """
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset=utf-8/>
        <meta name="viewport"
              content="user-scalable=no, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, minimal-ui">
        <title>GraphQL Playground</title>
        <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/graphql-playground-react/build/static/css/index.css"/>
        <link rel="shortcut icon" href="//cdn.jsdelivr.net/npm/graphql-playground-react/build/favicon.png"/>
        <script src="//cdn.jsdelivr.net/npm/graphql-playground-react/build/static/js/middleware.js"></script>
    </head>

    <body>
    <div id="root">
        <style>
            body {
                background-color: rgb(23, 42, 58);
                font-family: Open Sans, sans-serif;
                height: 90vh;
            }

            #root {
                height: 100%;
                width: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .loading {
                font-size: 32px;
                font-weight: 200;
                color: rgba(255, 255, 255, .6);
                margin-left: 20px;
            }

            img {
                width: 78px;
                height: 78px;
            }

            .title {
                font-weight: 400;
            }
        </style>
        <img src='//cdn.jsdelivr.net/npm/graphql-playground-react/build/logo.png' alt=''>
        <div class="loading"> Loading
            <span class="title">GraphQL Playground</span>
        </div>
    </div>
    <script>
        const subscriptionEndpoint = window.location.href.replace("playground", "\(path)/websocket").replace("http", "ws");
        window.addEventListener('load', function (event) {
            GraphQLPlayground.init(document.getElementById('root'), {
                endpoint: "./\(path)",
                subscriptionEndpoint
            })
        })
    </script>
    </body>

    </html>
    """
}
