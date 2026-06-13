//
//  ContentView.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/12/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: JobListViewModel
    private let makeJobDetailsViewModel: (Job) -> JobDetailsViewModel

    init(
        viewModel: JobListViewModel,
        makeJobDetailsViewModel: @escaping (Job) -> JobDetailsViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeJobDetailsViewModel = makeJobDetailsViewModel
    }

    var body: some View {
        JobListView(
            viewModel: viewModel,
            makeJobDetailsViewModel: makeJobDetailsViewModel
        )
    }
}

private struct ContentViewPreview: PreviewProvider {
    static var previews: some View {
        let repository = PreviewJobRepository()

        ContentView(
            viewModel: JobListViewModel(
                repository: repository
            ),
            makeJobDetailsViewModel: {
                JobDetailsViewModel(job: $0, repository: repository)
            }
        )
    }
}
