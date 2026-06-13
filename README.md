# RemoteRecruit

RemoteRecruit is a SwiftUI job browser for discovering remote opportunities. The
project is being built as a clean, testable iOS application using MVVM,
dependency injection, protocol-based abstractions, and Swift concurrency.

This version focuses on the job listing and details experiences. It
loads local sample data from a bundled JSON resource while the networking layer

## Features

- Browse remote jobs with title, company, location, and salary information
- Search by job title, company name, or location
- Open a job to view its description, company information, salary, and location
- Featured-job labels and accessible job cards
- Loading, empty, no-results, and error states across listing and details flows
- Pull to refresh and retry support
- Dependency-injected data source
- Unit-tested loading, error, and search behavior

## Screens and Data

The first screen displays a searchable list of remote roles. Jobs are decoded
from `Resources/jobs.json` by `JSONJobRepository`. The repository conforms to
`JobRepository`, so a network-backed implementation can replace it without
changing the presentation layer.

## Architecture

RemoteRecruit follows MVVM with responsibilities separated into small layers:

```
flowchart LR
    A["SwiftUI View"] --> B["JobListViewModel"]
    B --> C["JobRepository protocol"]
    C --> D["JSONJobRepository"]
    D --> F["jobs.json"]
    E["AppContainer"] --> B
    E --> D
```

- **Domain**: Business models and repository contracts
- **Data**: Concrete data-source implementations
- **Presentation**: SwiftUI views and observable view models
- **App**: Dependency composition and application startup

The view model is isolated to the main actor, asynchronous work uses
`async/await`, and dependencies are supplied through initializers.

## Project Structure

```text
RemoteRecruit/
|-- App/
|   `-- AppContainer.swift
|-- Data/
|   `-- JSONJobRepository.swift
|-- Domain/
|   |-- Job.swift
|   `-- JobRepository.swift
|-- Presentation/
|   |-- JobDetails/
|   |   |-- JobDetailsView.swift
|   |   `-- JobDetailsViewModel.swift
|   `-- JobList/
|       |-- JobListView.swift
|       |-- JobListViewModel.swift
|       `-- JobRowView.swift
|-- ContentView.swift
|-- Resources/
|   `-- jobs.json
`-- RemoteRecruitApp.swift

RemoteRecruitTests/
`-- RemoteRecruitTests.swift
```

## Requirements

- macOS with Xcode capable of building an iOS 17.5 target
- Swift 5
- iOS 17.5 or later

No third-party dependencies are required.

## Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/PshrivastavaMoreYeahs/RemoteRecruit.git
   cd RemoteRecruitApp
   ```

2. Open `RemoteRecruit.xcodeproj` in Xcode.
3. Select the `RemoteRecruitApp` scheme and an iOS simulator.
4. Build and run with `Command-R`.

## Testing

Run the unit tests in Xcode with `Command-U`, or from the command line:

```bash
xcodebuild test \
  -project RemoteRecruit.xcodeproj \
  -scheme RemoteRecruit \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

The test suite covers successful job loading, friendly error presentation,
search filtering, JSON decoding, resource errors, and job-detail lookup.

## Roadmap

- Connect to a remote jobs API
- Add application links
- Add filters and sorting
- Add saved jobs
- Add pagination and offline caching
- Expand UI and integration test coverage

## Contributing

Issues and pull requests are welcome. Keep changes focused, follow the existing
layer boundaries, and add tests for new view-model or repository behavior.
