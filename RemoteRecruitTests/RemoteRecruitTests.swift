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

        XCTAssertEqual(viewModel.filteredJobs, [])

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

    func testJSONRepositoryDecodesJobsAndMatchingDetails() async throws {
        let repository = JSONJobRepository(
            loader: DataJobJSONLoader(data: makeJobsJSON())
        )

        let jobs = try await repository.fetchJobs()
        let details = try await repository.fetchJobDetails(id: jobs[0].id)

        XCTAssertEqual(jobs.count, 1)
        XCTAssertEqual(jobs[0].title, "iOS Engineer")
        XCTAssertEqual(jobs[0].companyName, "Acme")
        XCTAssertEqual(jobs[0].location, "Remote")
        XCTAssertEqual(jobs[0].salaryRange, "$100k – $130k")
        XCTAssertTrue(jobs[0].isFeatured)
        XCTAssertEqual(details?.job, jobs[0])
        XCTAssertEqual(details?.description, "Build excellent iOS experiences.")
        XCTAssertEqual(
            details?.companyInformation,
            "Acme is a remote software company."
        )
    }

    func testJSONRepositoryReturnsNilForUnknownJob() async throws {
        let repository = JSONJobRepository(
            loader: DataJobJSONLoader(data: makeJobsJSON())
        )

        let details = try await repository.fetchJobDetails(id: UUID())

        XCTAssertNil(details)
    }

    func testJSONRepositoryThrowsForMalformedJSON() async {
        let repository = JSONJobRepository(
            loader: DataJobJSONLoader(data: Data("not-json".utf8))
        )

        do {
            _ = try await repository.fetchJobs()
            XCTFail("Expected malformed JSON to throw")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }

    func testBundleLoaderThrowsWhenResourceIsMissing() {
        let loader = BundleJobJSONLoader(
            bundle: .main,
            resourceName: "missing-jobs-fixture"
        )

        XCTAssertThrowsError(try loader.load()) { error in
            XCTAssertEqual(
                error as? JobJSONLoaderError,
                .resourceNotFound("missing-jobs-fixture")
            )
        }
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

    private func makeJobsJSON() -> Data {
        Data(
            """
            [
              {
                "id": "D60FEC10-E255-43FB-93CF-681C6286F25A",
                "title": "iOS Engineer",
                "companyName": "Acme",
                "location": "Remote",
                "salaryRange": "$100k – $130k",
                "isFeatured": true,
                "description": "Build excellent iOS experiences.",
                "companyInformation": "Acme is a remote software company."
              }
            ]
            """.utf8
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

