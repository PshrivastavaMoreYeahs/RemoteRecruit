//
//  JobRepository.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/12/26.
//

import Foundation

protocol JobRepository: Sendable {
    func fetchJobs() async throws -> [Job]
}
