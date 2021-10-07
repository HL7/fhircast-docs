# DiagnosticReport-open
eventMaturity | [1 - Submitted](../../specification/STU3/#event-maturity-model)

## Workflow
A `DiagnosticReport-open` request is posted to the Hub when a new or existing DiagnosticReport is opened by an application and established as the anchor context of a topic. The `context` field MUST contain at least one `Patient` resource and the anchor context resource.

When a `DiagnosticReport-open` event is received by an application, the application should respond as is appropriate for its clinical use.  For example, an image reading application may respond to a `DiagnosticReport-open` event posted by a reporting application by opening any imaging study(ies) specified in the context. A reporting application may want to respond to an event posted by an image reading application by creating and opening a new or existing report.

### Content Sharing Support
If a Hub supports content sharing, when it distributes a `DiagnosticReport-open` event the Hub associates a `versionId` with the anchor context.  Subscribed applications MUST submit this `versionId` in subsequent [`DiagnosticReport-update`](../diagnosticReport-update) requests.  If a client will neither make a [`DiagnosticReport-update`](../diagnosticReport-update) request or respond to [`DiagnosticReport-update`](../diagnosticReport-update) events, the versionId can be safely ignored.

## Context

#### Context
Key | Optionality | FHIR operation to generate context | Description
--- | --- | --- | ---
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient associated with the diagnostic report
`report`| REQUIRED | `DiagnosticReport/{id}?_elements=identifier` | Type of the [FHIR resource] being opened
`study` | OPTIONAL | ImagingStudy/{id}?_elements=identifier,accession | Information about the imaging study referenced by the report (if an imaging study is referenced) may be provided 
`version`| REQUIRED if content sharing is supported | not applicable | Current content version

### Examples

#### [FHIR resource]-open Example Request
The following example shows a report being opened that contains a single primary study.  Note that the diagnostic report's `imagingStudy` and `subject` attributes have references to the imaging study and patient which are also in the open request.

<mark>
```
{
  "timestamp": "2020-09-07T14:58:45.988Z",
  "id": "0d4c9998",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-open",
    "context": [
      {
        "key": "Report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "40012366",
          "status": "unknown",
          "subject": {
            "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
          },
          "imagingStudy": [
            {
              "reference": "ImagingStudy/8i7tbu6fby5ftfbku6fniuf"
            }
          ]
        }
      },
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "ewUbXT9RWEbSj5wPEdgRaBw3",
          "identifier": [
            {
              "system": "urn:oid:1.2.840.114350",
              "value": "185444"
            }
          ]
        }
      },
      {
        "key": "study",
        "resource": {
          "resourceType": "ImagingStudy",
          "description": "CHEST XRAY",
          "started": "2010-01-30T23:00:00.000Z",
          "status": "available",
          "id": "8i7tbu6fby5ftfbku6fniuf",
          "identifier": [
            {
              "type": {
                "coding": [
                  {
                    "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                    "code": "ACSN"
                  }
                ]
              },
              "value": "342123458"
            },
            {
              "system": "urn:dicom:uid",
              "value": "urn:oid:2.16.124.113543.6003.1154777499.38476.11982.4847614254"
            }
          ],
          "subject": {
            "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
          }
        }
      }
    ]
  }
}
```
</mark>

#### DiagnosticReport-open Event Example
The event distributed by the Hub includes a version context with a `versionId` which will be used by subscribers to make subsequent [`DiagnosticReport-update`](../diagnosticReport-update) requests.

<mark>
```
{
  "timestamp": "2020-09-07T14:58:45.988Z",
  "id": "0d4c9998",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-open",
    "context": [
      {
        "key": "Report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "40012366",
          "meta": {
            "versionId": "0"
          },
          "status": "unknown",
          "subject": {
            "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
          },
          "imagingStudy": [
            {
              "reference": "ImagingStudy/8i7tbu6fby5ftfbku6fniuf"
            }
          ]
        }
      },
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "ewUbXT9RWEbSj5wPEdgRaBw3",
          "identifier": [
            {
              "system": "urn:oid:1.2.840.114350",
              "value": "185444"
            }
          ]
        }
      },
      {
        "key": "study",
        "resource": {
          "resourceType": "ImagingStudy",
          "description": "CHEST XRAY",
          "started": "2010-01-30T23:00:00.000Z",
          "status": "available",
          "id": "8i7tbu6fby5ftfbku6fniuf",
          "identifier": [
            {
              "type": {
                "coding": [
                  {
                    "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                    "code": "ACSN"
                  }
                ]
              },
              "value": "342123458"
            },
            {
              "system": "urn:dicom:uid",
              "value": "urn:oid:2.16.124.113543.6003.1154777499.38476.11982.4847614254"
            }
          ],
          "subject": {
            "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
          }
        }
      },
      {
        "key": "version",
        "versionId": "1"
      }
    ]
  }
}
```
</mark>

## Change Log
Version | Description
---- | ----
0.1 | Initial draft

