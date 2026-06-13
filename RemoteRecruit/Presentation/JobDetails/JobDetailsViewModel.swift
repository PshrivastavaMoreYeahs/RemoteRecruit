//
//  JobDetailsViewModel.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/13/26.
//

import Foundation
import Combine

@MainActor
final class JobDetailsViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded(JobDetails)
        case empty
        case failed(String)
    }

    @Published private(set) var state: State = .idle

    let job: Job
    private let repository: any JobDetailsRepository

    init(job: Job, repository: any JobDetailsRepository) {
        self.job = job
        self.repository = repository
    }

    func loadDetails() async {
        guard state == .idle else { return }
        await fetchDetails()
    }

    func retry() async {
        await fetchDetails()
    }

    private func fetchDetails() async {
        state = .loading

        do {
            guard let details = try await repository.fetchJobDetails(id: job.id) else {
                state = .empty
                return
            }
            state = .loaded(details)
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failed("We couldn't load this job right now. Please try again.")
        }
    }
}
