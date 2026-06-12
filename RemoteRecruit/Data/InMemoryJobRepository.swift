//
//  InMemoryJobRepository.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/12/26.
//

import Foundation

struct InMemoryJobRepository: JobRepository {
    func fetchJobs() async throws -> [Job] {
        try await Task.sleep(for: .milliseconds(450))

        return [
            Job(
                title: "Senior iOS Engineer",
                companyName: "Northstar Labs",
                location: "Remote · Americas",
                salaryRange: "$145k – $180k",
                isFeatured: true
            ),
            Job(
                title: "Product Designer",
                companyName: "Juniper Health",
                location: "Remote · US",
                salaryRange: "$120k – $155k"
            ),
            Job(
                title: "Staff Backend Engineer",
                companyName: "Relay Commerce",
                location: "Remote · Worldwide",
                salaryRange: "$160k – $205k",
                isFeatured: true
            ),
            Job(
                title: "Senior Product Manager",
                companyName: "Ember Finance",
                location: "Remote · US & Canada",
                salaryRange: "$135k – $170k"
            ),
            Job(
                title: "Developer Advocate",
                companyName: "Canvas Cloud",
                location: "Remote · Europe",
                salaryRange: "€90k – €120k"
            ),
            Job(
                title: "Data Analyst",
                companyName: "Bright Metrics",
                location: "Remote · Americas",
                salaryRange: "$95k – $125k"
            )
        ]
    }
}

struct PreviewJobRepository: JobRepository {
    func fetchJobs() async throws -> [Job] {
        [
            Job(
                title: "Senior iOS Engineer",
                companyName: "Northstar Labs",
                location: "Remote · Americas",
                salaryRange: "$145k – $180k",
                isFeatured: true
            ),
            Job(
                title: "Product Designer",
                companyName: "Juniper Health",
                location: "Remote · US",
                salaryRange: "$120k – $155k"
            )
        ]
    }
}
