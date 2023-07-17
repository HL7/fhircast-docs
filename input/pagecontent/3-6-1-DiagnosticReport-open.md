### Event-name: DiagnosticReport-open

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

A `DiagnosticReport-open` request is posted to the Hub when a new or existing DiagnosticReport is opened by a Subscriber and established as the anchor context of a topic. The `context` field MUST contain at least one `Patient` resource and the anchor context resource.

#### Content Sharing Support

If a Hub supports content sharing, when it distributes a `DiagnosticReport-open` event the Hub associates a `context.versionId` with the anchor context.  Subscribers MUST submit this `context.versionId` in subsequent [`DiagnosticReport-update`](3-6-3-DiagnosticReport-update.html) requests.  If a Subscriber will neither make a [`DiagnosticReport-update`](3-6-3-DiagnosticReport-update.html) request or respond to [`DiagnosticReport-update`](3-6-3-DiagnosticReport-update.html) events, the `context.versionId` can be safely ignored.

### Context

{:.grid}
Key | Optionality | FHIR operation to generate context | Description
--- | --- | --- | ---
`report`| REQUIRED | `DiagnosticReport/{id}?_elements=identifier` | Diagnostic report being opened
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient associated with the diagnostic report
`study` | OPTIONAL | `ImagingStudy/{id}?_elements=identifier,accession` | Information about the imaging study referenced by the report (if an imaging study is referenced) may be provided

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in DiagnosticReport close request:

FHIR version | Profiles
------------ | --------
R4  | [DiagnosticReport for Open Events](StructureDefinition-fhircast-r4-diagnostic-report-open.html), [ImagingStudy for Open Events](StructureDefinition-fhircast-r4-imaging-study-open.html), [Patient for Open Events](StructureDefinition-fhircast-r4-patient-open.html)
R4b | [DiagnosticReport for Open Events](StructureDefinition-fhircast-r4b-diagnostic-report-open.html), [ImagingStudy for Open Events](StructureDefinition-fhircast-r4b-imaging-study-open.html), [Patient for Open Events](StructureDefinition-fhircast-r4b-patient-open.html)
R5  | [DiagnosticReport for Open Events](StructureDefinition-fhircast-r5-diagnostic-report-open.html), [ImagingStudy for Open Events](StructureDefinition-fhircast-r5-imaging-study-open.html), [Patient for Open Events](StructureDefinition-fhircast-r5-patient-open.html)

### Examples

#### DiagnosticReport-open Example Request

The following example shows a report being opened that contains a single primary study.  Note that the diagnostic report's `imagingStudy` and `subject` attributes have references to the imaging study and patient which are also in the open request.

```json
{
  "timestamp": "2020-09-07T14:58:45.988Z",
  "id": "0d4c9998",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-open",
    "context": [
      {
        "key": "report",
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

#### DiagnosticReport-open Event Example

The event distributed by the Hub includes a context version in the `context.versionId` event attribute which will be used by Subscribers to make subsequent [`DiagnosticReport-update`](3-6-3-DiagnosticReport-update.html) requests.

```json
{
  "timestamp": "2020-09-07T14:58:45.988Z",
  "id": "0d4c9998",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-open",
    "context.versionId": "b9574cb0-e9e5-4be1-8957-5fcb51ef33c1",
    "context": [
      {
        "key": "report",
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

### Change Log

{:.grid}
| Version | Description
| ------- | ----
| 0.1 | Initial draft
