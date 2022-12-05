import GRPC
import Vapor

public final class GRPCServer {
    private let configuration: GRPC.Server.Configuration
    private let application: Vapor.Application
    private var server: GRPC.Server?
    private var didStart: Bool = false
    private var didShutdown: Bool = false

    init(configuration: GRPC.Server.Configuration, application: Vapor.Application) {
        self.configuration = configuration
        self.application = application
    }

    deinit {
        assert(!didStart || didShutdown, "GRPCServer did not shutdown before deinit")
    }
}

extension GRPCServer: Vapor.Server {
    public func start(address: BindAddress?) throws {
        GRPC.Server.start(configuration: configuration)
            .whenSuccess { server in
                if let address = server.channel.localAddress {
                    self.application.logger.notice("GRPCServer: Started on \(address)")
                } else {
                    self.application.logger.warning("GRPCServer: started on an unknown address")
                }

                self.server = server
            }
    }

    public var onShutdown: EventLoopFuture<Void> {
        guard let server = server else { fatalError() }
        return server.channel.closeFuture
    }

    public func shutdown() {
        guard let server = server else {
            application.logger.warning("GRPCServer: Trying to shutdown a server that doesn't exist")
            return
        }

        do {
            try server.close().wait()
            application.logger.notice("GRPCServer: Server shutdown")
            didShutdown = true
        } catch {
            application.logger.warning("GRPCServer: Shutdown failed: \n\(error)")
        }
    }
}
