//
//  ContentView.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/12/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: JobListViewModel

    init(viewModel: JobListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        JobListView(viewModel: viewModel)
    }
}

private struct ContentViewPreview: PreviewProvider {
    static var previews: some View {
        ContentView(
            viewModel: JobListViewModel(
                repository: PreviewJobRepository()
            )
        )
    }
}
