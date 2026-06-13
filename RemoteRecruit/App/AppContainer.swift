//
//  AppContainer.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/12/26.
//

import Foundation

struct AppContainer {
    private let jobRepository: any JobRepository

    init(jobRepository: any JobRepository) {
        self.jobRepository = jobRepository
    }

    @MainActor
    func makeJobListViewModel() -> JobListViewModel {
        JobListViewModel(repository: jobRepository)
    }

    @MainActor
    func makeJobDetailsViewModel(for job: Job) -> JobDetailsViewModel {
        JobDetailsViewModel(job: job, repository: jobRepository)
    }
}

extension AppContainer {
    static let live = AppContainer(
        jobRepository: JSONJobRepository()
    )
}
