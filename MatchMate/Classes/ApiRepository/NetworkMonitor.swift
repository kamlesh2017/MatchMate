//
//  NetworkMonitor.swift
//  MatchMate
//
//  Created by Kamlesh Kumar Sharma on 27/01/25.
//

import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private init() {}

    let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { status == .satisfied }

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    deinit {
        stopMonitoring()
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
