//
//  CSIClient.swift
//  PIACSI
//
//  Created by Diego Trevisan on 02.04.26.
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

import Foundation

public enum CSIError: Error {
    case invalidURL
    case requestFailed(String)
    case unexpectedResponse
}

public struct CSIClient {
    private let baseURL = "https://csi.supreme.tools/api/v2/report"
    private let userAgent: String

    public init(userAgent: String) {
        self.userAgent = userAgent
    }

    /// Submits a debug report. Returns the report code on success.
    public func submit(data: String, team: String, appVersion: String) async throws -> String {
        let boundary = "----PIABoundary\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        let code = try await createReport(team: team, appVersion: appVersion, boundary: boundary)
        try await addData(data, to: code, boundary: boundary)
        finishReport(code: code)
        return code
    }

    // MARK: - Steps

    private func createReport(team: String, appVersion: String, boundary: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/create") else {
            throw CSIError.invalidURL
        }

        let meta = try metaJSON(appVersion: appVersion)
        let params = ["team": team, "meta": meta]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = multipartBody(params: params, boundary: boundary)
        request.setValue("multipart/form-data; boundary=\"\(boundary)\"", forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        if let http = httpResponse as? HTTPURLResponse, http.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? "<binary>"
            throw CSIError.requestFailed("HTTP \(http.statusCode): \(body.prefix(200))")
        }
        let response = try JSONDecoder().decode(CreateResponse.self, from: data)

        guard response.isSuccess, let code = response.code else {
            throw CSIError.requestFailed(response.message ?? "create failed")
        }
        return code
    }

    private func addData(_ uploadData: String, to code: String, boundary: String) async throws {
        guard let url = URL(string: "\(baseURL)/\(code)/add") else {
            throw CSIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = multipartBody(params: [:], reportFile: uploadData, boundary: boundary)
        request.setValue("multipart/form-data; boundary=\"\(boundary)\"", forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        if let http = httpResponse as? HTTPURLResponse, http.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? "<binary>"
            throw CSIError.requestFailed("HTTP \(http.statusCode): \(body.prefix(200))")
        }
        let response = try JSONDecoder().decode(BaseResponse.self, from: data)

        guard response.isSuccess else {
            throw CSIError.requestFailed(response.message ?? "add failed")
        }
    }

    private func finishReport(code: String) {
        guard let url = URL(string: "\(baseURL)/\(code)/finish") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request).resume()
    }

    // MARK: - Helpers

    private func metaJSON(appVersion: String) throws -> String {
        let platform: String
        #if os(tvOS)
            platform = "tvos"
        #else
            platform = "ios"
        #endif
        let meta = ["version": appVersion, "platform": platform]
        let data = try JSONSerialization.data(withJSONObject: meta)
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    private func multipartBody(params: [String: String], reportFile: String? = nil, boundary: String = "boundary") -> Data {
        var body = Data()
        let lineBreak = "\r\n"
        let boundaryLine = "--\(boundary)\(lineBreak)"
        let boundaryEnd = "--\(boundary)--\(lineBreak)"

        for (key, value) in params {
            body += boundaryLine.utf8Data
            body += "Content-Disposition: form-data; name=\"\(key)\"\(lineBreak)\(lineBreak)\(value)\(lineBreak)".utf8Data
        }

        if let file = reportFile, !file.isEmpty {
            body += boundaryLine.utf8Data
            body += "Content-Disposition: form-data; name=\"report\"; filename=\"report.txt\"\(lineBreak)\(lineBreak)\(file)\(lineBreak)".utf8Data
        }

        body += boundaryEnd.utf8Data
        return body
    }
}

private extension String {
    var utf8Data: Data { Data(utf8) }
}
