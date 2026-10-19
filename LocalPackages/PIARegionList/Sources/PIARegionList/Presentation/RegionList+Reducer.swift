//
//  RegionList+Reducer.swift
//  PIARegionList
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import CoreArchitecture
import Foundation
import PIARegionListDomain

extension RegionList {

    public struct Reducer: Sendable {
        fileprivate enum EffectID: Hashable {
            case vpnState
            case ping
            case progress
        }

        public let dependencies: Dependencies

        public init(dependencies: Dependencies) {
            self.dependencies = dependencies
        }

        public func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .onAppear:
                return observeVPNState()
            case .vpnStateChanged(let vpnState):
                state.vpnState = vpnState
                return nil
            case .loaded(let content):
                state.content = content
                return nil
            case .sortSelected(let sort):
                return select(sort, in: &state)
            case .searchChanged(let text):
                state.searchText = text
                return nil
            case .favoriteTapped(let id):
                return toggleFavorite(id, in: &state)
            case .regionTapped(let id):
                return tap(id, in: state)
            case .refreshTriggered:
                return refresh(in: &state)
            case .pingFinished(let completed):
                return finishPing(completed: completed, in: &state)
            case .progressReset:
                state.pingPhase = .idle
                return nil
            }
        }

        private func observeVPNState() -> Effect<Action> {
            .stream(id: EffectID.vpnState) { [dependencies] send in
                for await vpnState in dependencies.vpnStateUpdates() {
                    send(.vpnStateChanged(vpnState))
                }
            }
        }

        private func select(_ sort: RegionFilter, in state: inout State) -> Effect<Action> {
            state.content.sort = sort
            return .task { [dependencies] in
                dependencies.setSort(sort)
                return .loaded(dependencies.load())
            }
        }

        private func toggleFavorite(_ id: ID, in state: inout State) -> Effect<Action>? {
            guard id != .automatic, var region = state.region(for: id), !region.isOffline else { return nil }
            region.isFavorite.toggle()
            let isFavorite = region.isFavorite
            state.updateRegion(id) { $0.isFavorite = isFavorite }
            return .fireAndForget { [dependencies, region] in
                dependencies.setFavorite(region, isFavorite)
            }
        }

        private func tap(_ id: ID, in state: State) -> Effect<Action>? {
            guard let region = state.region(for: id), !region.isOffline else { return nil }
            // While disconnected, tapping the current selection still has to connect.
            if state.vpnState == .connected && id == state.content.selectedID {
                return emit(.dismiss)
            }
            return emit(.selected(id))
        }

        private func refresh(in state: inout State) -> Effect<Action>? {
            guard state.vpnState == .disconnected else {
                return emit(.refreshUnavailableWhileConnected)
            }
            guard state.pingPhase != .pinging else { return nil }
            state.pingPhase = .pinging
            return .task(id: EffectID.ping) { [dependencies] in
                .pingFinished(completed: await dependencies.ping())
            }
        }

        private func finishPing(completed: Bool, in state: inout State) -> Effect<Action>? {
            guard completed else {
                state.pingPhase = .idle
                return nil
            }
            state.pingPhase = .finished
            return .merge(
                .task { [dependencies] in .loaded(dependencies.load()) },
                .task(id: EffectID.progress) { [dependencies] in
                    try? await Task.sleep(nanoseconds: UInt64(dependencies.progressResetDelay * 1_000_000_000))
                    return .progressReset
                }
            )
        }

        private func emit(_ output: Output) -> Effect<Action> {
            .fireAndForget { [dependencies] in dependencies.emit(output) }
        }
    }
}
