import ServerKit
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
        application.servers.use(.grpc)
        application.grpc.server.configuration.target = .hostAndPort("0.0.0.0", 9001)
        application.grpc.server.configuration.serviceProviders = [
            // Add providers here
        ]
    }
}
