# PIACSI

Internal Swift package for submitting debug reports to the PIA Customer Support Integration (CSI) service. Targets iOS 15 and tvOS 17. Has no external dependencies.

## What it does

PIACSI assembles a structured text report from one or more `CSIDataProvider` implementations and uploads it to `https://csi.supreme.tools/api/v2/report` using a three-step HTTP flow. Callers receive a report code they can pass to the support team.

## 3-step HTTP flow

`CSIClient` performs three sequential requests:

1. **POST `/create`** — opens a new report session and returns a `CreateResponse` containing the report `code`.
2. **POST `/{code}/add`** — uploads the assembled report body as a multipart form-data part.
3. **POST `/{code}/finish`** — commits the report.

The multipart boundary is a random UUID generated once per submission. Using a fresh UUID each time prevents the boundary string from accidentally appearing inside log content.

## Report format

`CSIReportBuilder` concatenates all provider sections into a single string. Each section uses the format:

```
/PIA_PART/section_name
content

```

Sections are separated by a blank line. The `section_name` comes from `CSIDataProvider.sectionName`. If a provider returns `nil` from `content` it is omitted.

## CSIDataProvider protocol

```swift
public protocol CSIDataProvider {
    var sectionName: String { get }
    var content: String? { get }
}
```

- `sectionName` — used as the section header in the report (e.g. `"device_information"`).
- `content` — return `nil` to omit the section entirely (e.g. when data is unavailable).

## Adding a new data provider

1. Create a new type conforming to `CSIDataProvider` in `LocalPackages/PIALibrary/`:

```swift
struct PIACSIMyInformationProvider: CSIDataProvider {
    var sectionName: String { "my_information" }
    var content: String? {
        // collect and return the data, or nil if unavailable
        "key: value"
    }
}
```

2. Add an instance to the providers array in `PIAWebServices+Ephemeral.swift`:

```swift
let providers: [any CSIDataProvider] = [
    PIACSIProtocolInformationProvider(),
    PIACSIDeviceInformationProvider(),
    PIACSILogInformationProvider(),
    PIACSISubscriptionInformationProvider(),
    PIACrashlabRegionInformationProvider(),
    PIACSIUserInformationProvider(),
    PIACSILastKnownExceptionProvider(),
    PIACSIMyInformationProvider(),   // add here
]
```

## Multipart boundary note

`CSIClient` generates `let boundary = UUID().uuidString` once at the start of each submission and uses it for the multipart body sent in the `/add` request. A new UUID is generated for every call, not reused across submissions. This guarantees the boundary never collides with content produced by any provider, including long log sections that could otherwise contain arbitrary strings.
