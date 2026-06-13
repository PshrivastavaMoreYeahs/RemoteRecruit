//
//  InMemoryJobRepository.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/12/26.
//

import Foundation

struct InMemoryJobRepository: JobRepository {
    private let details = SampleJobs.details

    func fetchJobs() async throws -> [Job] {
        try await Task.sleep(for: .milliseconds(450))
        return details.map(\.job)
    }

    func fetchJobDetails(id: Job.ID) async throws -> JobDetails? {
        try await Task.sleep(for: .milliseconds(350))
        return details.first { $0.job.id == id }
    }
}

struct PreviewJobRepository: JobRepository {
    func fetchJobs() async throws -> [Job] {
        Array(SampleJobs.details.prefix(2).map(\.job))
    }

    func fetchJobDetails(id: Job.ID) async throws -> JobDetails? {
        SampleJobs.details.first { $0.job.id == id }
    }
}

private enum SampleJobs {
    static let details = [
        JobDetails(
            job: Job(
                id: UUID(uuidString: "D60FEC10-E255-43FB-93CF-681C6286F25A")!,
                title: "Senior iOS Engineer",
                companyName: "Northstar Labs",
                location: "Remote · Americas",
                salaryRange: "$145k – $180k",
                isFeatured: true
            ),
            description: """
            Build polished, reliable iOS experiences used by distributed teams around the world. You will own features from discovery through release, collaborate closely with product and design, and help evolve our SwiftUI architecture.

            We are looking for strong Swift fundamentals, experience with asynchronous systems, and a thoughtful approach to testing and maintainability.
            """,
            companyInformation: """
            Northstar Labs builds collaboration software for modern remote teams. The company is fully distributed across the Americas and values focused work, clear communication, and sustainable engineering practices.
            """
        ),
        JobDetails(
            job: Job(
                id: UUID(uuidString: "F9F21646-BDD5-45F4-8238-8C8BFF853391")!,
                title: "Product Designer",
                companyName: "Juniper Health",
                location: "Remote · US",
                salaryRange: "$120k – $155k"
            ),
            description: """
            Lead product design for patient and provider workflows across our digital health platform. You will turn complex healthcare problems into clear, accessible experiences and partner with research, product, and engineering throughout delivery.
            """,
            companyInformation: """
            Juniper Health helps care teams coordinate treatment through secure, patient-centered software. Its remote-first team combines healthcare expertise with pragmatic product development.
            """
        ),
        JobDetails(
            job: Job(
                id: UUID(uuidString: "30A7A46D-6E71-4343-BC03-6BC76808E99F")!,
                title: "Staff Backend Engineer",
                companyName: "Relay Commerce",
                location: "Remote · Worldwide",
                salaryRange: "$160k – $205k",
                isFeatured: true
            ),
            description: """
            Design and operate the services that power high-volume international commerce. You will guide technical direction, improve platform reliability, and mentor engineers working across payments, fulfillment, and merchant tooling.
            """,
            companyInformation: """
            Relay Commerce provides infrastructure that helps independent brands sell and fulfill products globally. The engineering organization works asynchronously across multiple time zones.
            """
        ),
        JobDetails(
            job: Job(
                id: UUID(uuidString: "580C9A36-E3DE-4654-A40C-83A26D961E08")!,
                title: "Senior Product Manager",
                companyName: "Ember Finance",
                location: "Remote · US & Canada",
                salaryRange: "$135k – $170k"
            ),
            description: """
            Define the roadmap for financial tools that help small businesses understand cash flow and make confident decisions. You will combine customer insight, product analytics, and close engineering partnership to deliver measurable outcomes.
            """,
            companyInformation: """
            Ember Finance creates approachable financial software for small business owners. Its remote team operates across the United States and Canada.
            """
        ),
        JobDetails(
            job: Job(
                id: UUID(uuidString: "18D2BC42-CC5A-4650-8C86-EA33D3E6A72C")!,
                title: "Developer Advocate",
                companyName: "Canvas Cloud",
                location: "Remote · Europe",
                salaryRange: "€90k – €120k"
            ),
            description: """
            Help developers succeed through technical content, sample applications, community programs, and direct product feedback. You will represent real developer needs while making cloud tooling easier to learn and adopt.
            """,
            companyInformation: """
            Canvas Cloud builds deployment and observability tools for software teams. The company has a distributed European team and an active open-source community.
            """
        ),
        JobDetails(
            job: Job(
                id: UUID(uuidString: "B0974B70-0B25-4B73-AEED-E75DD8146A2F")!,
                title: "Data Analyst",
                companyName: "Bright Metrics",
                location: "Remote · Americas",
                salaryRange: "$95k – $125k"
            ),
            description: """
            Develop trusted reporting, investigate product trends, and help teams make better decisions with data. You will work with stakeholders to define useful metrics and communicate findings clearly.
            """,
            companyInformation: """
            Bright Metrics provides analytics software for subscription businesses. Its remote-first team is distributed across North and South America.
            """
        )
    ]
}

