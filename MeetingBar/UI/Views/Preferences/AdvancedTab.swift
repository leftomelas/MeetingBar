//
//  AdvancedTab.swift
//  MeetingBar
//
//  Created by Andrii Leitsius on 13.01.2021.
//  Copyright © 2021 Andrii Leitsius. All rights reserved.
//

import SwiftUI

import Defaults

struct AdvancedTab: View {
    var body: some View {
        VStack {
            GroupBox(label: Label("Event Notifications", systemImage: "bell")) {
                VStack(spacing: 10) {
                    AutomaticEventJoinPicker()
                    EndEventNotificationPicker()
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            GroupBox(label: Label("AppleScript Hooks", systemImage: "applescript")) {
                VStack(spacing: 10) {
                    ScriptSection()
                }
            }
            GroupBox(label: Label("Regex Filters", systemImage: "line.horizontal.3.decrease.circle")) {
                VStack(spacing: 10) {
                    FilterEventRegexesSection()
                    MeetingRegexesSection()
                }
            }
            Spacer()
            HStack {
                Spacer()
                Text("preferences_advanced_setting_warning".loco())
                Spacer()
            }
        }
    }
}

struct ScriptSection: View {
    @Default(.runEventStartScript) var runEventStartScript
    @Default(.eventStartScriptLocation) var eventStartScriptLocation
    @Default(.eventStartScript) var eventStartScript
    @Default(.eventStartScriptTime) var eventStartScriptTime

    @State private var showingRunEventStartScriptModal = false

    @Default(.runJoinEventScript) var runJoinEventScript
    @Default(.joinEventScriptLocation) var joinEventScriptLocation
    @Default(.joinEventScript) var joinEventScript

    @State private var showingJoinEventScriptModal = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Toggle("preferences_advanced_run_script_on_event_start".loco(), isOn: $runEventStartScript)
                Picker("", selection: $eventStartScriptTime) {
                    Text("general_when_event_starts".loco()).tag(TimeBeforeEvent.atStart)
                    Text("general_one_minute_before".loco()).tag(TimeBeforeEvent.minuteBefore)
                    Text("general_three_minute_before".loco()).tag(TimeBeforeEvent.threeMinuteBefore)
                    Text("general_five_minute_before".loco()).tag(TimeBeforeEvent.fiveMinuteBefore)
                }.frame(width: 150, alignment: .leading).labelsHidden().disabled(!runEventStartScript)
                Spacer()
                if runEventStartScript {
                    Button(action: runSampleScript) {
                        Text("preferences_advanced_test_script_on_next_event".loco())
                    }
                    Button("preferences_advanced_edit_script".loco()) { showingRunEventStartScriptModal = true }
                }
            }.sheet(isPresented: $showingRunEventStartScriptModal) {
                EditScriptModal(script: $eventStartScript, scriptLocation: $eventStartScriptLocation, scriptName: "eventStartScript.scpt")
            }

            HStack {
                Toggle("preferences_advanced_apple_script_checkmark".loco(), isOn: $runJoinEventScript)
                Spacer()
                if runJoinEventScript {
                    Button("preferences_advanced_edit_script".loco()) { showingJoinEventScriptModal = true }
                }
            }.sheet(isPresented: $showingJoinEventScriptModal) {
                EditScriptModal(script: $joinEventScript, scriptLocation: $joinEventScriptLocation, scriptName: "joinEventScript.scpt")
            }
        }
    }

    func runSampleScript() {
        if let app = NSApplication.shared.delegate as! AppDelegate? {
            runAppleScriptForNextEvent(events: app.statusBarItem.events)
        }
    }
}

struct EditScriptModal: View {
    @Environment(\.presentationMode) var presentationMode

    @Binding var script: String
    @Binding var scriptLocation: URL?
    var scriptName: String

    @State var editedScript: String = ""

    @State private var showingAlert = false

    var body: some View {
        VStack {
            Spacer()
            Text("preferences_advanced_edit_script".loco())
            Spacer()
            NSScrollableTextViewWrapper(text: $editedScript).padding(.leading, 19)
            Spacer()
            HStack {
                Button(action: cancel) {
                    Text("general_cancel".loco())
                }
                Spacer()
                Button(action: saveScript) {
                    Text("general_save".loco())
                }.disabled(self.editedScript == self.script)
            }
            Spacer()
        }.padding()
            .frame(width: 500, height: 500)
            .onAppear { self.editedScript = self.script }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("preferences_advanced_wrong_location_title".loco()),
                      message: Text("preferences_advanced_wrong_location_message".loco()),
                      dismissButton: .default(Text("preferences_advanced_wrong_location_button".loco())))
            }
    }

    func saveScript() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowedContentTypes = [.appleScript]
        openPanel.allowsOtherFileTypes = false
        openPanel.prompt = "preferences_advanced_save_script_button".loco()
        openPanel.message = "preferences_advanced_wrong_location_message".loco()
        let scriptPath = try! FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        openPanel.directoryURL = scriptPath
        openPanel.begin { response in
            if response == .OK {
                if openPanel.url != scriptPath {
                    showingAlert = true
                    return
                }
                scriptLocation = openPanel.url
                if let filepath = openPanel.url?.appendingPathComponent(scriptName) {
                    do {
                        try editedScript.write(to: filepath, atomically: true, encoding: String.Encoding.utf8)
                        script = editedScript
                        presentationMode.wrappedValue.dismiss()
                    } catch {}
                }
            }
            openPanel.close()
        }
    }

    func cancel() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct NSScrollableTextViewWrapper: NSViewRepresentable {
    typealias NSViewType = NSScrollView
    var isEditable = true
    var textSize: CGFloat = 12

    @Binding var text: String

    var didEndEditing: (() -> Void)?

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as? NSTextView
        textView?.font = NSFont.systemFont(ofSize: textSize)
        textView?.isEditable = isEditable
        textView?.isSelectable = true
        textView?.isAutomaticQuoteSubstitutionEnabled = false
        textView?.delegate = context.coordinator

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context _: Context) {
        let textView = nsView.documentView as? NSTextView
        guard textView?.string != text else {
            return
        }

        textView?.string = text
        textView?.display() // force update UI to re-draw the string
        textView?.scrollRangeToVisible(NSRange(location: text.count, length: 0))
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, NSTextViewDelegate {
        var view: NSScrollableTextViewWrapper

        init(_ view: NSScrollableTextViewWrapper) {
            self.view = view
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            view.text = textView.string
        }

        func textDidEndEditing(_: Notification) {
            view.didEndEditing?()
        }
    }
}

struct FilterEventRegexesSection: View {
    @Default(.filterEventRegexes) var filterEventRegexes

    @State private var showingEditRegexModal = false
    @State private var selectedRegex = ""

    var body: some View {
        DisclosureGroup("preferences_advanced_event_regex_title".loco()) {
            List {
                Button("preferences_advanced_regex_add_button".loco()) { openEditRegexModal("") }.buttonStyle(.borderedProminent)
                ForEach(filterEventRegexes, id: \.self) { regex in
                    HStack {
                        Text(regex)
                        Spacer()
                        Button("preferences_advanced_regex_edit_button".loco()) { openEditRegexModal(regex) }
                        Button("x") { removeRegex(regex) }
                    }
                }
            }.frame(height: 100)
                .listStyle(.inset(alternatesRowBackgrounds: true))
                .sheet(isPresented: $showingEditRegexModal) {
                    EditRegexModal(regex: selectedRegex, function: addRegex)
                }
        }.padding(.leading, 19)
    }

    func openEditRegexModal(_ regex: String) {
        selectedRegex = regex
        removeRegex(regex)
        showingEditRegexModal.toggle()
    }

    func addRegex(_ regex: String) {
        if !filterEventRegexes.contains(regex) {
            filterEventRegexes.append(regex)
        }
    }

    func removeRegex(_ regex: String) {
        if let index = filterEventRegexes.firstIndex(of: regex) {
            filterEventRegexes.remove(at: index)
        }
    }
}

struct MeetingRegexesSection: View {
    @Default(.customRegexes) var customRegexes

    @State private var showingEditRegexModal = false
    @State private var selectedRegex = ""

    var body: some View {
        DisclosureGroup("preferences_advanced_regex_title".loco()) {
            List {
                Button("preferences_advanced_regex_add_button".loco()) { openEditRegexModal("") }.buttonStyle(.borderedProminent)
                ForEach(customRegexes, id: \.self) { regex in
                    HStack {
                        Text(regex)
                        Spacer()
                        Button("preferences_advanced_regex_edit_button".loco()) { openEditRegexModal(regex) }
                        Button("x") { removeRegex(regex) }
                    }
                }
            }.frame(height: 100)
                .listStyle(.inset(alternatesRowBackgrounds: true))
                .sheet(isPresented: $showingEditRegexModal) {
                    EditRegexModal(regex: selectedRegex, function: addRegex)
                }
        }.padding(.leading, 19)
    }

    func openEditRegexModal(_ regex: String) {
        selectedRegex = regex
        removeRegex(regex)
        showingEditRegexModal.toggle()
    }

    func addRegex(_ regex: String) {
        if !customRegexes.contains(regex) {
            customRegexes.append(regex)
        }
    }

    func removeRegex(_ regex: String) {
        if let index = customRegexes.firstIndex(of: regex) {
            customRegexes.remove(at: index)
        }
    }
}

struct EditRegexModal: View {
    @Environment(\.presentationMode) var presentationMode
    @State var new_regex: String = ""
    var regex: String
    var function: (_ regex: String) -> Void

    @State private var showingAlert = false
    @State private var error_msg = ""

    var body: some View {
        VStack {
            Spacer()
            TextField("preferences_advanced_regex_new_title".loco(), text: $new_regex)
            Spacer()
            HStack {
                Button(action: cancel) {
                    Text("general_cancel".loco())
                }
                Spacer()
                Button(action: save) {
                    Text("general_save".loco())
                }.disabled(new_regex.isEmpty)
            }
        }.padding()
            .frame(width: 500, height: 150)
            .onAppear { self.new_regex = self.regex }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("preferences_advanced_regex_new_cant_save_title".loco()), message: Text(error_msg), dismissButton: .default(Text("general_ok".loco())))
            }
    }

    func cancel() {
        if !regex.isEmpty {
            function(regex)
        }
        presentationMode.wrappedValue.dismiss()
    }

    func save() {
        do {
            _ = try NSRegularExpression(pattern: new_regex)
            function(new_regex)
            presentationMode.wrappedValue.dismiss()
        } catch let error as NSError {
            error_msg = error.localizedDescription
            showingAlert = true
        }
    }
}

#Preview {
    AdvancedTab().padding().frame(width: 700, height: 620)
}
