//
//  AnalyticsView.swift
//  HapticSpeech
//
//  Created by Suryanshu on 31/07/25.
//

import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var viewModel: AnalyticsViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.sessions.isEmpty {
                    ContentUnavailableView(
                        "No Sessions Yet",
                        systemImage: "waveform",
                        description: Text("Start recording to collect session data")
                    )
                } else {
                    List {
                        Section(header: Text("Usage Statistics")) {
                            HStack {
                                Text("Total Sessions")
                                Spacer()
                                Text("\(viewModel.sessions.count)")
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Total Recording Time")
                                Spacer()
                                Text(viewModel.formattedTotalRecordingTime)
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Average Session Length")
                                Spacer()
                                Text(viewModel.formattedAverageSessionLength)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Section(header: Text("Recent Sessions")) {
                            ForEach(viewModel.sessions.prefix(10), id: \.id) { session in
                                NavigationLink(destination: SessionDetailView(session: session)) {
                                    VStack(alignment: .leading) {
                                        Text(session.formattedTimestamp)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Text(session.recognizedText.prefix(50) + (session.recognizedText.count > 50 ? "..." : ""))
                                            .lineLimit(1)
                                        
                                        HStack {
                                            Text("\(session.phonemes.count) phonemes")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                            
                                            Text("\(session.hapticPatternsCount) patterns")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        
                        Section(header: Text("Most Common Phonemes")) {
                            ForEach(viewModel.topPhonemes, id: \.phoneme) { item in
                                HStack {
                                    Text(item.phoneme)
                                        .font(.system(.body, design: .monospaced))
                                    
                                    Spacer()
                                    
                                    Text("\(item.count) occurrences")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Analytics")
            .toolbar {
                Button(action: {
                    viewModel.refreshData()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            viewModel.refreshData()
        }
    }
}

struct SessionDetailView: View {
    let session: SessionLog
    
    var body: some View {
        List {
            Section(header: Text("Session Info")) {
                HStack {
                    Text("Date")
                    Spacer()
                    Text(session.formattedTimestamp)
                }
                
                HStack {
                    Text("Duration")
                    Spacer()
                    Text(session.formattedDuration)
                }
            }
            
            Section(header: Text("Recognized Text")) {
                Text(session.recognizedText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Section(header: Text("Phonemes (\(session.phonemes.count))")) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(session.phonemes, id: \.self) { phoneme in
                            Text(phoneme)
                                .padding(8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Section(header: Text("Haptic Patterns")) {
                HStack {
                    Text("Total Patterns")
                    Spacer()
                    Text("\(session.hapticPatternsCount)")
                }
            }
        }
        .navigationTitle("Session Details")
    }
}