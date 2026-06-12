//
//  Job.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/11/26.
//

import Foundation

struct Job: Identifiable, Equatable, Sendable {
    let id: UUID
    let title: String
    let companyName: String
    let location: String
    let salaryRange: String
    let isFeatured: Bool

    init(
        id: UUID = UUID(),
        title: String,
        companyName: String,
        location: String,
        salaryRange: String,
        isFeatured: Bool = false
    ) {
        self.id = id
        self.title = title
        self.companyName = companyName
        self.location = location
        self.salaryRange = salaryRange
        self.isFeatured = isFeatured
    }
}
