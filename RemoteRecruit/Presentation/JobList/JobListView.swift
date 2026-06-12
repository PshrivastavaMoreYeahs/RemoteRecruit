//
//  JobListView.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/12/26.
//

import SwiftUI

struct JobListView: View {
    @ObservedObject var viewModel: JobListViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("Find your next role")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Job title, company, or location"
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel("Filter jobs")
                }
            }
        }
        .tint(.indigo)
        .task {
            await viewModel.loadJobs()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Finding great remote roles…")
                .foregroundStyle(.secondary)
        case .loaded(let jobs) where jobs.isEmpty:
            ContentUnavailableView(
                "No jobs found",
                systemImage: "briefcase",
                description: Text("Check back soon for new remote opportunities.")
            )
        case .loaded where viewModel.filteredJobs.isEmpty:
            ContentUnavailableView.search(text: viewModel.searchText)
        case .loaded:
            ScrollView {
                LazyVStack(spacing: 14) {
                    resultHeader(count: viewModel.filteredJobs.count)

                    ForEach(viewModel.filteredJobs) { job in
                        JobRowView(job: job)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .refreshable {
                await viewModel.retry()
            }
        case .failed(let message):
            ContentUnavailableView {
                Label("Unable to load jobs", systemImage: "wifi.exclamationmark")
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

    private func resultHeader(count: Int) -> some View {
        HStack {
            Text("\(count) remote opportunities")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Spacer()

            Text("Newest")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.indigo)
        }
        .padding(.top, 8)
    }
}

private struct JobListViewPreview: PreviewProvider {
    static var previews: some View {
        JobListView(
            viewModel: JobListViewModel(
                repository: PreviewJobRepository()
            )
        )
    }
}

