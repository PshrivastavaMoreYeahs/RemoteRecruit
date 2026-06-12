//
//  JobListViewModel.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/12/26.
//

import Foundation
import Combine

@MainActor
final class JobListViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded([Job])
        case failed(String)
    }

    @Published private(set) var state: State = .idle

    private let repository: any JobRepository

    init(repository: any JobRepository) {
        self.repository = repository
    }

    func loadJobs() async {
        guard state == .idle else { return }
        await fetchJobs()
    }

    func retry() async {
        await fetchJobs()
    }

    private func fetchJobs() async {
        state = .loading

        do {
            state = .loaded(try await repository.fetchJobs())
        } catch is CancellationError {
            state = .idle
        } catch {
            state = .failed("We couldn't load jobs right now. Please try again.")
        }
    }
}
