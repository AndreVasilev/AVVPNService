//
//  Credentials.swift
//  AVVPNService
//
//  Created by Andrey Vasilev on 21.04.2020.
//  Copyright © 2020 Andrey Vasilev. All rights reserved.
//

import Foundation

public enum VPNType: String, CaseIterable {
    case ike2 = "IKEv2"
    case ipsec = "IPSec"
}

public class Credentials {

    let type: VPNType
    let title: String
    let server: String
    let username: String
    let password: String

    private init(_ type: VPNType, title: String, server: String, username: String, password: String) {
        self.type = type
        self.title = title
        self.server = server
        self.username = username
        self.password = password
    }

    public class IPSec: Credentials {
        let shared: String

        public init(title: String = "AVVPNService", server: String, username: String, password: String, shared: String) {
            self.shared = shared
            super.init(.ipsec, title: title, server: server, username: username, password: password)
        }
    }

    public class IKEv2: Credentials {
        let remoteId: String
        let localId: String

        public init(title: String = "AVVPNService", server: String, username: String, password: String, remoteId: String, localId: String) {
            self.remoteId = remoteId
            self.localId = localId
            super.init(.ike2, title: title, server: server, username: username, password: password)
        }
    }
}
