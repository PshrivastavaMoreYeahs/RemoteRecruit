//
//  JobRowView.swift
//  RemoteRecruit
//
//  Created by Prashant Shrivastava on 6/12/26.
//

import SwiftUI

struct JobRowView: View {
    let job: Job

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                companyMark

                VStack(alignment: .leading, spacing: 5) {
                    Text(job.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(job.companyName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
            }

            Divider()

            Label(job.location, systemImage: "location")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Label(job.salaryRange, systemImage: "banknote")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                if job.isFeatured {
                    Text("FEATURED")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.indigo)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(.indigo.opacity(0.1), in: Capsule())
                }
            }
        }
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.quaternary, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
        .accessibilityElement(children: .combine)
    }

    private var companyMark: some View {
        Text(job.companyName.prefix(1).uppercased())
            .font(.headline.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(markColor, in: RoundedRectangle(cornerRadius: 12))
    }

    private var markColor: Color {
        let colors: [Color] = [.indigo, .teal, .orange, .pink, .blue]
        let scalarSum = job.companyName.unicodeScalars.reduce(0) {
            $0 + Int($1.value)
        }
        return colors[scalarSum % colors.count]
    }
}
