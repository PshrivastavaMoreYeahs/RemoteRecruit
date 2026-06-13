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

    func testLoadJobsReturnsToIdleWhenRequestIsCancelled() async {
        let viewModel = JobListViewModel(
            repository: JobRepositoryStub(
                result: .failure(CancellationError())
            )
        )

        await viewModel.loadJobs()

        XCTAssertEqual(viewModel.state, .idle)
    }

    func testLoadJobsOnlyFetchesOnceAfterSuccessfulLoad() async {
        let repository = JobListRepositorySpy(result: .success([makeJob()]))
        let viewModel = JobListViewModel(repository: repository)

        await viewModel.loadJobs()
        await viewModel.loadJobs()

        XCTAssertEqual(repository.fetchCount, 1)
    }

    func testRetryFetchesJobsAgain() async {
        let repository = JobListRepositorySpy(result: .success([makeJob()]))
        let viewModel = JobListViewModel(repository: repository)

        await viewModel.loadJobs()
        await viewModel.retry()

        XCTAssertEqual(repository.fetchCount, 2)
    }

    func testFilteredJobsIsEmptyBeforeJobsLoad() {
        let viewModel = JobListViewModel(
            repository: JobRepositoryStub(result: .success([]))
        )

        XCTAssertEqual(viewModel.filteredJobs, [])
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

    func testLoadJobDetailsPublishesRepositoryResult() async {
        let job = makeJob()
        let details = JobDetails(
            job: job,
            description: "Build excellent iOS experiences.",
            companyInformation: "Acme is a remote software company."
        )
        let viewModel = JobDetailsViewModel(
            job: job,
            repository: JobRepositoryStub(
                result: .success([]),
                detailsResult: .success(details)
            )
        )

        await viewModel.loadDetails()

        XCTAssertEqual(viewModel.state, .loaded(details))
    }

    func testLoadJobDetailsPublishesEmptyStateWhenDetailsAreMissing() async {
        let job = makeJob()
        let viewModel = JobDetailsViewModel(
            job: job,
            repository: JobRepositoryStub(
                result: .success([]),
                detailsResult: .success(nil)
            )
        )

        await viewModel.loadDetails()

        XCTAssertEqual(viewModel.state, .empty)
    }

    func testLoadJobDetailsPublishesFriendlyError() async {
        let job = makeJob()
        let viewModel = JobDetailsViewModel(
            job: job,
            repository: JobRepositoryStub(
                result: .success([]),
                detailsResult: .failure(TestError.failed)
            )
        )

        await viewModel.loadDetails()

        XCTAssertEqual(
            viewModel.state,
            .failed("We couldn't load this job right now. Please try again.")
        )
    }

    func testLoadJobDetailsReturnsToIdleWhenRequestIsCancelled() async {
        let job = makeJob()
        let viewModel = JobDetailsViewModel(
            job: job,
            repository: JobRepositoryStub(
                result: .success([]),
                detailsResult: .failure(CancellationError())
            )
        )

        await viewModel.loadDetails()

        XCTAssertEqual(viewModel.state, .idle)
    }

    func testLoadJobDetailsOnlyFetchesOnceAfterSuccessfulLoad() async {
        let job = makeJob()
        let details = makeJobDetails(for: job)
        let repository = JobDetailsRepositorySpy(result: .success(details))
        let viewModel = JobDetailsViewModel(job: job, repository: repository)

        await viewModel.loadDetails()
        await viewModel.loadDetails()

        XCTAssertEqual(repository.fetchCount, 1)
    }

    func testRetryFetchesJobDetailsAgain() async {
        let job = makeJob()
        let repository = JobDetailsRepositorySpy(
            result: .success(makeJobDetails(for: job))
        )
        let viewModel = JobDetailsViewModel(job: job, repository: repository)

        await viewModel.loadDetails()
        await viewModel.retry()

        XCTAssertEqual(repository.fetchCount, 2)
    }

    func testInMemoryRepositoryReturnsJobsAndMatchingDetails() async throws {
        let repository = InMemoryJobRepository()

        let jobs = try await repository.fetchJobs()
        let details = try await repository.fetchJobDetails(id: jobs[0].id)

        XCTAssertEqual(jobs.count, 6)
        XCTAssertEqual(details?.job, jobs[0])
        XCTAssertFalse(details?.description.isEmpty ?? true)
        XCTAssertFalse(details?.companyInformation.isEmpty ?? true)
    }

    func testInMemoryRepositoryReturnsNilForUnknownJob() async throws {
        let repository = InMemoryJobRepository()

        let details = try await repository.fetchJobDetails(id: UUID())

        XCTAssertNil(details)
    }

    func testPreviewRepositoryReturnsTwoJobsAndMatchingDetails() async throws {
        let repository = PreviewJobRepository()

        let jobs = try await repository.fetchJobs()
        let details = try await repository.fetchJobDetails(id: jobs[0].id)

        XCTAssertEqual(jobs.count, 2)
        XCTAssertEqual(details?.job, jobs[0])
    }

    private func makeJob() -> Job {
        Job(
            title: "iOS Engineer",
            companyName: "Acme",
            location: "Remote",
            salaryRange: "$100k – $130k"
        )
    }

    private func makeJobDetails(for job: Job) -> JobDetails {
        JobDetails(
            job: job,
            description: "Build excellent iOS experiences.",
            companyInformation: "Acme is a remote software company."
        )
    }
}

private struct JobRepositoryStub: JobRepository {
    let result: Result<[Job], Error>
    let detailsResult: Result<JobDetails?, Error>

    init(
        result: Result<[Job], Error>,
        detailsResult: Result<JobDetails?, Error> = .success(nil)
    ) {
        self.result = result
        self.detailsResult = detailsResult
    }

    func fetchJobs() async throws -> [Job] {
        try result.get()
    }

    func fetchJobDetails(id: Job.ID) async throws -> JobDetails? {
        try detailsResult.get()
    }
}

private enum TestError: Error {
    case failed
}

private final class JobListRepositorySpy: JobListRepository, @unchecked Sendable {
    private(set) var fetchCount = 0
    let result: Result<[Job], Error>

    init(result: Result<[Job], Error>) {
        self.result = result
    }

    func fetchJobs() async throws -> [Job] {
        fetchCount += 1
        return try result.get()
    }
}

private final class JobDetailsRepositorySpy: JobDetailsRepository, @unchecked Sendable {
    private(set) var fetchCount = 0
    let result: Result<JobDetails?, Error>

    init(result: Result<JobDetails?, Error>) {
        self.result = result
    }

    func fetchJobDetails(id: Job.ID) async throws -> JobDetails? {
        fetchCount += 1
        return try result.get()
    }
}
