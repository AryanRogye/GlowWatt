//
//  Bundle+versionNumber.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 8/24/26.
//

import Foundation

extension Bundle {
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }
}
