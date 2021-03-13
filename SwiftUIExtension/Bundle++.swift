//
//  Bundle++.swift
//  SwiftUIExtension
//
//  Created by Andy Kim on 13/3/21.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var releaseVersionNumberPretty: String {
        return "v\(releaseVersionNumber ?? "Version not available") (\(buildVersionNumber ?? ""))"
    }
}
