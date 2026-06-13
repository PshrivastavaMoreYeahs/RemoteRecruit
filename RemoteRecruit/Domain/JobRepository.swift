//
//  JobRepository.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/12/26.
//

import Foundation

protocol JobListRepository: Sendable {
    func fetchJobs() async throws -> [Job]
}

protocol JobDetailsRepository: Sendable {
    func fetchJobDetails(id: Job.ID) async throws -> JobDetails?
}

typealias JobRepository = JobListRepository & JobDetailsRepository
