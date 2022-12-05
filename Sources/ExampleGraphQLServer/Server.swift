import ServerKit
import Graphiti
import Vapor

@main
struct Server {
    static func main() async throws {
        var environment = try Environment.detect()
        try LoggingSystem.bootstrap(from: &environment)
        let application = Application(environment)
        do {
            try configure(application: application)
        } catch {
            application.logger.warning("Application failed to configure: \(error)")
            application.shutdown()
        }

        defer { application.shutdown() }
        try application.run()
    }

    static func configure(application: Application) throws {
        try application.graphql.configuration.schema {
            Query {
                Field("add", at: GraphQLResolver.add) {
                    Argument("a", at: \.a)
                    Argument("b", at: \.b)
                }
            }
        }

        application.graphql.configureHTTPServer()
        application.graphql.server.configuration.address = .hostname("0.0.0.0", port: 9001)
    }
}

struct AddInput: Codable {
    let a: Int
    let b: Int
}

extension GraphQLResolver {
    func add(context: GraphQLContext, input: AddInput) -> Int {
        return input.a + input.b
    }
}
