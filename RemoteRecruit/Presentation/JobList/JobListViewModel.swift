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
    @Published var searchText = ""

    private let repository: any JobListRepository

    var filteredJobs: [Job] {
        guard case .loaded(let jobs) = state else { return [] }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return jobs }

        return jobs.filter { job in
            job.title.localizedStandardContains(query)
                || job.companyName.localizedStandardContains(query)
                || job.location.localizedStandardContains(query)
        }
    }

    init(repository: any JobListRepository) {
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
