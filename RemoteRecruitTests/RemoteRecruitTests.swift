//
//  RemoteRecruitTests.swift
//  RemoteRecruitTests
//
//  Created by Prashant Shrivastava on 6/12/26.
//

import XCTest
@testable import RemoteRecruit

@MainActor
final class RemoteRecruitAppTests: XCTestCase {
    func testLoadJobsPublishesRepositoryResults() async {
        let expectedJobs = [
            Job(
                title: "iOS Engineer",
                companyName: "Acme",
                location: "Remote",
                salaryRange: "$100k – $130k"
            )
        ]
        let viewModel = JobListViewModel(
            repository: JobRepositoryStub(result: .success(expectedJobs))
        )

        await viewModel.loadJobs()

        XCTAssertEqual(viewModel.state, .loaded(expectedJobs))
    }

    func testLoadJobsPublishesFriendlyError() async {
        let viewModel = JobListViewModel(
            repository: JobRepositoryStub(result: .failure(TestError.failed))
        )

        await viewModel.loadJobs()

        XCTAssertEqual(
            viewModel.state,
            .failed("We couldn't load jobs right now. Please try again.")
        )
    }

    func testSearchFiltersJobsByTitleCompanyAndLocation() async {
        let jobs = [
            Job(
                title: "iOS Engineer",
                companyName: "Acme",
                location: "Remote · US",
                salaryRange: "$100k – $130k"
            ),
            Job(
                title: "Product Designer",
                companyName: "Northstar Labs",
                location: "Remote · Europe",
                salaryRange: "€90k – €120k"
            )
        ]
        let viewModel = JobListViewModel(
            repository: JobRepositoryStub(result: .success(jobs))
        )
        await viewModel.loadJobs()

        viewModel.searchText = "engineer"
        XCTAssertEqual(viewModel.filteredJobs, [jobs[0]])

        viewModel.searchText = "northstar"
        XCTAssertEqual(viewModel.filteredJobs, [jobs[1]])

        viewModel.searchText = "europe"
        XCTAssertEqual(viewModel.filteredJobs, [jobs[1]])
    }

    func testBlankSearchReturnsAllJobs() async {
        let jobs = [
            Job(
                title: "iOS Engineer",
                companyName: "Acme",
                location: "Remote",
                salaryRange: "$100k – $130k"
            )
        ]
        let viewModel = JobListViewModel(
            repository: JobRepositoryStub(result: .success(jobs))
        )
        await viewModel.loadJobs()

        viewModel.searchText = "   "

        XCTAssertEqual(viewModel.filteredJobs, jobs)
    }
}

private struct JobRepositoryStub: JobRepository {
    let result: Result<[Job], Error>

    func fetchJobs() async throws -> [Job] {
        try result.get()
    }
}

private enum TestError: Error {
    case failed
}
