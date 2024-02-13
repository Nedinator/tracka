//
//  ContentView.swift
//  tracka
//
//  Created by Neal Carico on 2/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var tracker = AppUsageTracker.shared
    @State private var showingTagEditor: [UUID: Bool] = [:]
    @State private var newTagText: [UUID: String] = [:]

    var body: some View {
        List(tracker.activities) { activity in
            VStack(alignment: .leading) {
                HStack {
                    Text(activity.name)
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        // Toggle showing tag editor for this particular app
                        self.showingTagEditor[activity.id] = !(self.showingTagEditor[activity.id] ?? false)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                // Display the duration here
                Text("Duration: \(formatDuration(seconds: activity.usageDuration))")
                    .font(.subheadline) // Optional: Adjust the font as you like

                if showingTagEditor[activity.id, default: false] {
                    HStack {
                        TextField("New Tag", text: Binding(
                            get: { self.newTagText[activity.id] ?? "" },
                            set: { self.newTagText[activity.id] = $0 }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button(action: {
                            let newTag = self.newTagText[activity.id, default: ""].trimmingCharacters(in: .whitespacesAndNewlines)
                            if !newTag.isEmpty {
                                activity.tags.insert(newTag)
                                // Reset the text field and hide the editor
                                self.newTagText[activity.id] = nil
                                self.showingTagEditor[activity.id] = false
                            }
                        }) {
                            Text("Add")
                        }
                    }
                }
                // Display existing tags
                ForEach(activity.tags.sorted(), id: \.self) { tag in
                    Text(tag)
                        .padding(4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func formatDuration(seconds: TimeInterval) -> String {
    let totalSeconds = Int(seconds)
    let days = totalSeconds / 86400
    let hours = (totalSeconds % 86400) / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    
    if days > 0 {
        return String(format: "%02dd %02dh %02dm %02ds", days, hours, minutes, seconds)
    } else {
        return String(format: "%02dh %02dm %02ds", hours, minutes, seconds)
    }
}
