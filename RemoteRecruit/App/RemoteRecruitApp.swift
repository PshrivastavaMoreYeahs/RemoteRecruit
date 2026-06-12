//
//  RemoteRecruitApp.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/12/26.
//

import SwiftUI

@main
struct RemoteRecruitAppApp: App {
    private let container = AppContainer.live

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: container.makeJobListViewModel())
        }
    }
}
