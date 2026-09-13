import SwiftUI
import SwiftData

enum SidebarItem: String, CaseIterable, Identifiable {
    case classes = "Classes"
    case tasks = "Tasks"
    case exams = "Exams"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .classes:
            return "book"
        case .tasks:
            return "checklist"
        case .exams:
            return "function"
        }
    }
}

struct ContentView: View {
    @State private var selectedItem: SidebarItem? = .classes
    @State private var showWeekends = true
    @State private var selectedView = "Week"
    @State private var showingAddClass = false
    @State private var referenceDate = Date()
    @State private var searchText = ""

    private let calendar = Calendar.current

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(
                    min: 220,
                    ideal: 240,
                    max: 280
                )
        } detail: {
            mainContent
        }
        .frame(minWidth: 1100, minHeight: 700)
        .sheet(isPresented: $showingAddClass) {
            AddClassView()
        }
    }

    private var sidebar: some View {
        List(selection: $selectedItem) {
            Section {
                Button {
                    print("Add Timetable")
                } label: {
                    Label("Add Timetable", systemImage: "plus")
                }
                .buttonStyle(.plain)

                Label("Rate on App Store", systemImage: "star")

                Label(
                    "Share App",
                    systemImage: "square.and.arrow.up"
                )

                Label(
                    "Feature Request",
                    systemImage: "bubble.left"
                )

                Toggle(
                    "Show Weekends",
                    isOn: $showWeekends
                )
            }

            Section("📚 My Timetable") {
                ForEach(SidebarItem.allCases) { item in
                    Label(
                        item.rawValue,
                        systemImage: item.icon
                    )
                    .tag(item)
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Divider()

                Label(
                    "Notifications Disabled",
                    systemImage: "bell.slash"
                )
                .foregroundStyle(.red)
                .padding()

                Divider()

                Button {
                    print("Settings")
                } label: {
                    Label(
                        "Settings",
                        systemImage: "gearshape"
                    )
                }
                .buttonStyle(.plain)
                .padding()
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(.regularMaterial)
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()

            switch selectedItem ?? .classes {
            case .classes:
                switch selectedView {

                case "Day":
                    DayTimetableView(
                        referenceDate: referenceDate
                    )

                case "Month":
                    MonthTimetableView(
                        referenceDate: referenceDate,
                        showWeekends: showWeekends
                    )

                default:
                    WeekTimetableView(
                        referenceDate: referenceDate,
                        showWeekends: showWeekends
                    )
                }

            case .tasks:
                TasksView()

            case .exams:
                EmptySectionView(
                    title: "Exams",
                    message: "Your upcoming exams will appear here.",
                    icon: "function"
                )
            }
        }
    }

    private var toolbar: some View {
        HStack {
            Button {
                moveDate(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }
            .help("Previous Week")

            Button("Today") {
                referenceDate = Date()
            }

            Button {
                moveDate(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .help("Next Week")

            Spacer()

            Picker("View", selection: $selectedView) {
                Text("Day").tag("Day")
                Text("Week").tag("Week")
                Text("Month").tag("Month")
            }
            .pickerStyle(.segmented)
            .frame(width: 240)

            Spacer()

            TextField("Search classes", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 180)
                .disabled(selectedItem != .classes)

            Button {
                if selectedItem == .classes {
                    showingAddClass = true
                }
            } label: {
                Image(systemName: "plus")
            }
            .help("Add Class")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func moveDate(by amount: Int) {

        let component: Calendar.Component

        switch selectedView {

        case "Day":
            component = .day

        case "Month":
            component = .month

        default:
            component = .weekOfYear
        }

        if let newDate = calendar.date(
            byAdding: component,
            value: amount,
            to: referenceDate
        ) {
            referenceDate = newDate
        }
    }
}


