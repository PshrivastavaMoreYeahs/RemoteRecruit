//
//  JobDetails.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/13/26.
//

import Foundation

struct JobDetails: Equatable, Sendable {
    let job: Job
    let description: String
    let companyInformation: String
}
