import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudFoundryConfig
import SwiftMetrics
import SwiftMetricsDash
import SwiftMetricsBluemix

public let router = Router()
public let manager = ConfigurationManager()
public var port: Int = 8080

public func initialize() throws {

    manager.load(file: "config.json", relativeFrom: .project)
           .load(.environmentVariables)

    port = manager.port

    let sm = try SwiftMetrics()
    let _ = try SwiftMetricsDash(swiftMetricsInstance : sm, endpoint: router)

    let _ = SwiftMetricsBluemix(swiftMetricsInstance: sm)

    router.all("/*", middleware: BodyParser())
    router.all("/", middleware: StaticFileServer())


    initializeSwaggerRoute(path: ConfigurationManager.BasePath.project.path + "/definitions/swiftCloudant.yaml")
    router.get("/health") { request, response, _ in
        try response.send(json: ["status": "UP"]).end()
    }
}

public func run() throws {
    Kitura.addHTTPServer(onPort: port, with: router)
    Kitura.run()
}
