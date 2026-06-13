//
//  JobDetailsView.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/13/26.
//

import SwiftUI

struct JobDetailsView: View {
    @StateObject private var viewModel: JobDetailsViewModel

    init(viewModel: JobDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            content
        }
        .navigationTitle("Job details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDetails()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading job details…")
                .foregroundStyle(.secondary)
        case .loaded(let details):
            detailsContent(details)
        case .empty:
            ContentUnavailableView(
                "Details unavailable",
                systemImage: "doc.text.magnifyingglass",
                description: Text("This job does not have any additional information yet.")
            )
        case .failed(let message):
            ContentUnavailableView {
                Label("Unable to load job", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try again") {
                    Task { await viewModel.retry() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func detailsContent(_ details: JobDetails) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header(details.job)

                HStack(spacing: 12) {
                    factCard(
                        title: "Salary",
                        value: details.job.salaryRange,
                        systemImage: "banknote"
                    )
                    factCard(
                        title: "Location",
                        value: details.job.location,
                        systemImage: "location"
                    )
                }

                informationSection(
                    title: "Job description",
                    systemImage: "doc.text",
                    text: details.description
                )

                informationSection(
                    title: "About \(details.job.companyName)",
                    systemImage: "building.2",
                    text: details.companyInformation
                )
            }
            .padding(16)
            .padding(.bottom, 24)
        }
    }

    private func header(_ job: Job) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if job.isFeatured {
                Text("FEATURED ROLE")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.indigo)
            }

            Text(job.title)
                .font(.largeTitle.bold())

            Text(job.companyName)
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
    }

    private func factCard(
        title: String,
        value: String,
        systemImage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .topLeading)
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }

    private func informationSection(
        title: String,
        systemImage: String,
        text: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.title3.bold())

            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    JobDetailsView(
        viewModel: JobDetailsViewModel(
            job: Job(
                id: UUID(uuidString: "D60FEC10-E255-43FB-93CF-681C6286F25A")!,
                title: "Senior iOS Engineer",
                companyName: "Northstar Labs",
                location: "Remote · Americas",
                salaryRange: "$145k – $180k",
                isFeatured: true
            ),
            repository: PreviewJobRepository()
        )
    )
}
