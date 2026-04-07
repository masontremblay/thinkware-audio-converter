import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    // MARK: - UI State

    /// The video files selected by the user for conversion.
    @State private var selectedFiles: [URL] = []

    /// The path to the ffmpeg executable chosen by the user.
    @State private var ffmpegURL: URL?

    /// Indicates whether a conversion is currently running.
    @State private var isProcessing = false
    
    /// Indicates whether the selected ffmpeg executable is currently being validated.
    ///
    /// This state is used to:
    /// Disable the ffmpeg selection button during validation
    /// Display a progress indicator while validation is running
    /// Prevent premature interaction before validation completes
    @State private var isValidatingFFmpeg = false

    /// Log output shown in the app's log panel.
    @State private var logMessages: [String] = [
        "Ready to convert Thinkware MP4 files."
    ]
    
    private let stepGridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    /// Returns the app version and build number from the app bundle.
    private var appVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }
    
    /// Validates that the selected executable looks like a usable ffmpeg binary.
    /// This reduces the chance of accidentally running the wrong executable.
    private func validateFFmpegExecutable(at url: URL) throws {
        // Confirm the selected path exists.
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw NSError(
                domain: "ThinkwareAudioConverter",
                code: 10,
                userInfo: [NSLocalizedDescriptionKey: "The selected ffmpeg executable could not be found at \(url.path)."]
            )
        }

        // Confirm the selected path is executable.
        guard FileManager.default.isExecutableFile(atPath: url.path) else {
            throw NSError(
                domain: "ThinkwareAudioConverter",
                code: 11,
                userInfo: [NSLocalizedDescriptionKey: "The selected file is not executable. Please choose a valid ffmpeg binary."]
            )
        }

        // Run `ffmpeg -version` and confirm the output looks like ffmpeg.
        let process = Process()
        process.executableURL = url
        process.arguments = ["-version"]

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
        } catch {
            throw NSError(
                domain: "ThinkwareAudioConverter",
                code: 12,
                userInfo: [NSLocalizedDescriptionKey: "Failed to run the selected executable as ffmpeg: \(error.localizedDescription)"]
            )
        }

        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let outputText = String(data: outputData, encoding: .utf8) ?? ""
        let errorText = String(data: errorData, encoding: .utf8) ?? ""
        let combinedText = outputText + "\n" + errorText

        guard process.terminationStatus == 0 || combinedText.localizedCaseInsensitiveContains("ffmpeg version") else {
            throw NSError(
                domain: "ThinkwareAudioConverter",
                code: 13,
                userInfo: [NSLocalizedDescriptionKey: "The selected executable does not appear to be a valid ffmpeg binary."]
            )
        }

        guard combinedText.localizedCaseInsensitiveContains("ffmpeg version") else {
            throw NSError(
                domain: "ThinkwareAudioConverter",
                code: 14,
                userInfo: [NSLocalizedDescriptionKey: "The selected executable ran successfully, but it did not identify itself as ffmpeg."]
            )
        }
    }

    var body: some View {
        // Wrap the full interface in a vertical ScrollView so the app remains usable
        // when the window is smaller than the total content height.
        
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 16) {
                header
                
                LazyVGrid(columns: stepGridColumns, alignment: .leading, spacing: 16) {
                    
                    // MARK: - Step 1: Download ffmpeg
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("1")
                                .font(.headline.weight(.semibold))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .glassEffect(.regular.tint(.gray.opacity(0.18)).interactive(), in: .capsule)
                            
                            Text("Download ffmpeg")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("If you do not already have the ffmpeg executible, download it first using the official ffmpeg website.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Button {
                                if let url = URL(string: "https://evermeet.cx/ffmpeg/") {
                                    NSWorkspace.shared.open(url)
                                }
                            } label: {
                                Text("Download ffmpeg")
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .frame(minHeight: 36)
                            .buttonStyle(.glass)
                            .help("Open ffmpeg download page")
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .glassEffect(.regular.tint(.white.opacity(0.06)), in: .rect(cornerRadius: 14))
                    
                    // MARK: - Step 2: Select video files
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("2")
                                .font(.headline.weight(.semibold))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .glassEffect(.regular.tint(.gray.opacity(0.18)).interactive(), in: .capsule)
                            
                            Text("Select video files")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Button {
                                    pickVideoFiles()
                                } label: {
                                    Text("Choose MP4 Files")
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                .disabled(isProcessing)
                                .frame(minHeight: 36)
                                .buttonStyle(.glass)
                                
                                Text("\(selectedFiles.count) selected")
                                    .foregroundStyle(.secondary)
                            }
                            
                            if selectedFiles.isEmpty {
                                Text("No files selected yet.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                List(selectedFiles, id: \.self) { url in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(url.lastPathComponent)
                                            .font(.body)
                                        
                                        Text(url.path)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                    .help(url.path)
                                }
                                .frame(minHeight: 140)
                            }
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .glassEffect(.regular.tint(.white.opacity(0.06)), in: .rect(cornerRadius: 14))
                    
                    // MARK: - Step 3: Select ffmpeg
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("3")
                                .font(.headline.weight(.semibold))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .glassEffect(.regular.tint(.gray.opacity(0.18)).interactive(), in: .capsule)
                            
                            Text("Select ffmpeg")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Button {
                                    pickFFmpeg()
                                } label: {
                                    Text("Choose ffmpeg Executable")
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                .disabled(isProcessing || isValidatingFFmpeg)
                                .frame(minHeight: 36)
                                .buttonStyle(.glass)
                                
                                if isValidatingFFmpeg {
                                    ProgressView()
                                        .controlSize(.small)
                                }
                                
                                if let ffmpegURL {
                                    Text(ffmpegURL.path)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                } else {
                                    Text("No ffmpeg executable selected yet.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Text("The correct file usually has the name 'ffmpeg' and macOS shows it as a Unix executable file.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .glassEffect(.regular.tint(.white.opacity(0.06)), in: .rect(cornerRadius: 14))
                    
                    // MARK: - Step 4: Convert files
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text("4")
                                .font(.headline.weight(.semibold))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .glassEffect(.regular.tint(.gray.opacity(0.18)).interactive(), in: .capsule)
                            
                            Text("Convert")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Button {
                                    Task {
                                        await convertAllFiles()
                                    }
                                } label: {
                                    Text(isProcessing ? "Converting..." : "Convert Files")
                                        .fontWeight(.regular)
                                        .foregroundStyle(
                                            (selectedFiles.isEmpty || ffmpegURL == nil || isProcessing)
                                            ? Color.white.opacity(0.4)   // Dim when disabled
                                            : Color.white               // Full white when enabled
                                        )
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                .disabled(isProcessing || selectedFiles.isEmpty || ffmpegURL == nil)
                                .frame(minHeight: 36)
                                .buttonStyle(.glassProminent)
                                
                                if isProcessing {
                                    ProgressView()
                                        .controlSize(.small)
                                }
                            }
                            
                            Text("This creates new files beside the originals with '_converted' added to the filename.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .glassEffect(.regular.tint(.white.opacity(0.06)), in: .rect(cornerRadius: 14))
                }
                
                // MARK: - Log output
                
                GroupBox {
                    ScrollViewReader { proxy in
                        ScrollView {
                            Text(logMessages.joined(separator: "\n\n"))
                                .font(.system(.caption, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                                .padding(8)
                            
                            Color.clear
                                .frame(height: 1)
                                .id("logBottom")
                        }
                        .frame(minHeight: 140)
                        .onChange(of: logMessages.count) {
                            withAnimation {
                                proxy.scrollTo("logBottom", anchor: .bottom)
                            }
                        }
                    }
                } label: {
                    Text("Log")
                        .font(.headline)
                }
                
                // MARK: - Legal and Attributions
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recording conversations or voices may be restricted or illegal in some regions without consent. You are responsible for understanding and complying with local laws before recording or using audio from your device. Use this application at your own risk. The developer is not responsible for any legal issues, damages, or losses resulting from use or misuse of this application. This application is provided free of charge and may be used and shared freely. No commercial warranty is provided. Always keep backups of your original videos before using this application. The application is provided “as is“ without warranties of any kind, express or implied, including but not limited to fitness for a particular purpose and noninfringement. This application is not affiliated with, endorsed by, or approved for use by Thinkware or any of its affiliates. “Thinkware“ or “THINKWARE“ is a trademark of its respective owner and is used for identification purposes only. Such use does not imply endorsement. This application uses **FFmpeg**, © the FFmpeg developers. FFmpeg is licensed under the LGPL or GPL depending on configuration. For more information, licensing details, and source code, visit: https://ffmpeg.org/")
                    
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(8)
                
                Text(appVersionText)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 4)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: 480, minHeight: 520)
    }
    
    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image("Header")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .accessibilityHidden(true)

                Text("Thinkware Audio Converter")
                    .font(.title2.bold())
            }

            HStack(spacing: 0) {
                Text("Convert MP4 clips recorded with Thinkware dash cameras that lose audio in QuickTime or other macOS applications by copying the video stream and converting the audio track to AAC using FFmpeg. This issue occurs because some Thinkware dash cameras record audio in a technically valid format that is not fully supported by certain macOS applications, causing the audio track to appear present but fail during playback or editing. Thinkware Audio Converter outputs a widely compatible MP4 file that retains audio when opened or edited.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - File selection

    private func pickVideoFiles() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.mpeg4Movie]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        if panel.runModal() == .OK {
            selectedFiles = panel.urls
            appendLog("Selected \(selectedFiles.count) file(s).")
        }
    }

    private func pickFFmpeg() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = []
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.prompt = "Choose"
        
        if panel.runModal() == .OK, let url = panel.url {
            
            // Normalize the selected ffmpeg path so symbolic links and odd path forms
            // are resolved before storing the executable location.
            let resolvedURL = url.standardizedFileURL.resolvingSymlinksInPath()
            appendLog("User selected ffmpeg candidate: \(resolvedURL.path)")

            // Warn if the selected file name does not appear to be ffmpeg.
            // This helps prevent users from accidentally selecting the wrong executable.
            if !resolvedURL.lastPathComponent.lowercased().contains("ffmpeg") {
                appendLog("Warning: The selected file name does not appear to be 'ffmpeg'.")
            }

            // Show validation activity in UI
            isValidatingFFmpeg = true
            appendLog("Validating ffmpeg executable...")

            do {
                try validateFFmpegExecutable(at: resolvedURL)
                ffmpegURL = resolvedURL
                appendLog("Selected ffmpeg executable: \(resolvedURL.path)")
                appendLog("ffmpeg validation passed.")
            } catch {
                ffmpegURL = nil
                appendLog("ffmpeg validation failed.")
                appendLog("Error: \(error.localizedDescription)")
            }

            // Validation finished
            isValidatingFFmpeg = false
        }
    }

    // MARK: - Conversion

    @MainActor
    private func convertAllFiles() async {
        guard let ffmpegURL else {
            appendLog("Error: ffmpeg not selected.")
            return
        }

        // Ensure the selected ffmpeg path still exists before starting conversion.
        guard FileManager.default.fileExists(atPath: ffmpegURL.path) else {
            appendLog("Error: ffmpeg path not found at \(ffmpegURL.path)")
            return
        }

        // Start security-scoped access for the selected ffmpeg binary when available.
        let hasFFmpegAccess = ffmpegURL.startAccessingSecurityScopedResource()
        defer {
            if hasFFmpegAccess {
                ffmpegURL.stopAccessingSecurityScopedResource()
            }
        }

        isProcessing = true
        appendLog("Starting conversion...")

        for inputURL in selectedFiles {
            do {
                // Confirm the input file still exists before processing it.
                guard FileManager.default.fileExists(atPath: inputURL.path) else {
                    appendLog("Failed: \(inputURL.lastPathComponent)")
                    appendLog("Error: Input file not found at \(inputURL.path)")
                    continue
                }

                // Start security-scoped access for the selected input file when needed.
                let hasInputAccess = inputURL.startAccessingSecurityScopedResource()
                defer {
                    if hasInputAccess {
                        inputURL.stopAccessingSecurityScopedResource()
                    }
                }

                let outputURL = makeOutputURL(for: inputURL)

                appendLog("Processing: \(inputURL.lastPathComponent)")
                try runFFmpeg(ffmpegURL: ffmpegURL, inputURL: inputURL, outputURL: outputURL)
                appendLog("Created: \(outputURL.lastPathComponent)")
            } catch {
                appendLog("Failed: \(inputURL.lastPathComponent)")
                appendLog("Error: \(error.localizedDescription)")
            }
        }

        appendLog("Done.")
        
        isProcessing = false
    }

    // MARK: - Path building

    /// Builds a unique output file path beside the original input file.
    /// If "<name>_converted.mp4" already exists, the application will try
    /// "<name>_converted_2.mp4", then "_3", and so on.
    private func makeOutputURL(for inputURL: URL) -> URL {
        let directory = inputURL.deletingLastPathComponent()
        let baseName = inputURL.deletingPathExtension().lastPathComponent

        let firstChoice = directory.appendingPathComponent(baseName + "_converted.mp4")
        if !FileManager.default.fileExists(atPath: firstChoice.path) {
            return firstChoice
        }

        var counter = 2
        while true {
            let candidate = directory.appendingPathComponent(baseName + "_converted_\(counter).mp4")
            if !FileManager.default.fileExists(atPath: candidate.path) {
                return candidate
            }
            counter += 1
        }
    }

    // MARK: - ffmpeg execution

    private func runFFmpeg(ffmpegURL: URL, inputURL: URL, outputURL: URL) throws {
        guard ffmpegURL.isFileURL else {
            throw NSError(
                domain: "ThinkwareAudioConverter",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "ffmpeg URL is not a file URL: \(ffmpegURL)"]
            )
        }

        guard inputURL.isFileURL else {
            throw NSError(
                domain: "ThinkwareAudioConverter",
                code: 5,
                userInfo: [NSLocalizedDescriptionKey: "Input URL is not a file URL: \(inputURL)"]
            )
        }

        // Verify that both the ffmpeg binary and the input file still exist.
        guard FileManager.default.fileExists(atPath: ffmpegURL.path) else {
            throw NSError(
                domain: "ThinkwareAudioConverter",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "ffmpeg path not found at \(ffmpegURL.path)"]
            )
        }

        guard FileManager.default.fileExists(atPath: inputURL.path) else {
            throw NSError(
                domain: "ThinkwareAudioConverter",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Input file not found at \(inputURL.path)"]
            )
        }

        let process = Process()
        process.executableURL = ffmpegURL
        process.arguments = [
            "-i", inputURL.path,
            "-c:v", "copy",
            "-c:a", "aac",
            outputURL.path
        ]

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
        } catch {
            // Provide a more actionable error message for common macOS execution issues.
            let hint = "\nHint: Ensure the ffmpeg binary is executable (chmod +x) and not quarantined (xattr -d com.apple.quarantine)."

            throw NSError(
                domain: "ThinkwareAudioConverter",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "Failed to start ffmpeg at \(ffmpegURL.path): \(error.localizedDescription)\(hint)"]
            )
        }

        process.waitUntilExit()

        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorText = String(data: errorData, encoding: .utf8) ?? "Unknown ffmpeg error."

        if process.terminationStatus != 0 {
            throw NSError(
                domain: "ThinkwareAudioConverter",
                code: Int(process.terminationStatus),
                userInfo: [NSLocalizedDescriptionKey: errorText]
            )
        }
    }

    // MARK: - Logging

    private func appendLog(_ message: String) {
        let timestamp = Self.timestampFormatter.string(from: Date())
        logMessages.append("[\(timestamp)] \(message)")
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }()
}

#Preview {
    ContentView()
}
