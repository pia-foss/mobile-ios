import CoreArchitecture

typealias DebugMenuStore = Store<DebugMenu.State, DebugMenu.Action>

extension DebugMenuStore {
    convenience init(initialState: DebugMenu.State, dependencies: DebugMenu.Dependencies) {
        self.init(
            initial: initialState,
            reduce: DebugMenu.Reducer(dependencies: dependencies).reduce
        )
    }
}
