//
//  JSONJobRepository.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/13/26.
//

import Foundation

protocol JobJSONLoading: Sendable {
    func load() throws -> Data
}

struct BundleJobJSONLoader: JobJSONLoading {
    private let bundle: Bundle
    private let resourceName: String

    init(bundle: Bundle = .main, resourceName: String = "jobs") {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    func load() throws -> Data {
        guard let url = bundle.url(
            forResource: resourceName,
            withExtension: "json"
        ) else {
            throw JobJSONLoaderError.resourceNotFound(resourceName)
        }

        return try Data(contentsOf: url)
    }
}

enum JobJSONLoaderError: Error, Equatable {
    case resourceNotFound(String)
}

struct JSONJobRepository: JobRepository {
    private let loader: any JobJSONLoading
    private let decoder: JSONDecoder

    init(
        loader: any JobJSONLoading = BundleJobJSONLoader(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.loader = loader
        self.decoder = decoder
    }

    func fetchJobs() async throws -> [Job] {
        try loadDetails().map(\.job)
    }

    func fetchJobDetails(id: Job.ID) async throws -> JobDetails? {
        try loadDetails().first { $0.job.id == id }
    }

    private func loadDetails() throws -> [JobDetails] {
        try decoder.decode([JobDTO].self, from: loader.load())
            .map(\.domainModel)
    }
}

struct PreviewJobRepository: JobRepository {
    private let repository = JSONJobRepository()

    func fetchJobs() async throws -> [Job] {
        Array(try await repository.fetchJobs().prefix(2))
    }

    func fetchJobDetails(id: Job.ID) async throws -> JobDetails? {
        try await repository.fetchJobDetails(id: id)
    }
}

struct DataJobJSONLoader: JobJSONLoading {
    let data: Data

    func load() throws -> Data {
        data
    }
}

private struct JobDTO: Decodable {
    let id: UUID
    let title: String
    let companyName: String
    let location: String
    let salaryRange: String
    let isFeatured: Bool
    let description: String
    let companyInformation: String

    var domainModel: JobDetails {
        JobDetails(
            job: Job(
                id: id,
                title: title,
                companyName: companyName,
                location: location,
                salaryRange: salaryRange,
                isFeatured: isFeatured
            ),
            description: description,
            companyInformation: companyInformation
        )
    }
}
