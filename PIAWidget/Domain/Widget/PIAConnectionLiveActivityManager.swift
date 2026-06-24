#if !targetEnvironment(macCatalyst)
    import ActivityKit
    import Foundation
    import PIALibrary

    public protocol PIAConnectionLiveActivityManagerType: Sendable {
        func startLiveActivity(with state: PIAConnectionAttributes.ContentState) async
        func endLiveActivities() async
    }

    @available(iOS 16.2, *)
    private let log = PIALogger.logger(for: PIAConnectionLiveActivityManager.self)

    @available(iOS 16.2, *)
    public final actor PIAConnectionLiveActivityManager: PIAConnectionLiveActivityManagerType {
        private typealias Activity = ActivityKit.Activity<PIAConnectionAttributes>
        public typealias State = PIAConnectionAttributes.ContentState

        static let shared = PIAConnectionLiveActivityManager()
        private init() {}

        public func startLiveActivity(with state: State) async {
            if let activity = Activity.activities.first(where: { $0.activityState == .active }) {
                await updateLiveActivity(activity: activity, with: state)
            } else {
                await createNewLiveActivity(with: state)
            }
        }

        public func endLiveActivities() async {
            let currentActivities = Activity.activities
            guard !currentActivities.isEmpty else { return }
            await withTaskGroup(of: Void.self) { group in
                for act in currentActivities {
                    group.addTask {
                        await act.end(dismissalPolicy: .immediate)
                    }
                }
            }
        }

        private func createNewLiveActivity(with state: PIAConnectionAttributes.ContentState) async {
            // Clear all the Live Activities before starting a new one
            await endLiveActivities()

            let attributes = PIAConnectionAttributes()
            do {
                _ = try Activity.request(attributes: attributes, contentState: state, pushType: nil)
            } catch {
                log.error("Unable to create live activity: \(error.localizedDescription)")
            }
        }

        private func updateLiveActivity(activity: Activity, with state: PIAConnectionAttributes.ContentState) async {
            guard activity.activityState == .active else {
                await createNewLiveActivity(with: state)
                return
            }

            // Only update the live activity if there is new content
            guard state != activity.content.state else { return }
            await activity.update(using: state)
        }
    }
#endif
