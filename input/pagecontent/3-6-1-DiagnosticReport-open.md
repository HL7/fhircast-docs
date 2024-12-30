### Event-name: DiagnosticReport-open

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

User opened a report.  The newly opened report is now the current report in context.  If a Hub supports content sharing, the report is also in the role of an [`anchor context`](5_glossary.html)

### Context

{:.grid}
Key       | Cardinality | Type      | Description
--------- | ----------- | --------- | --------------
`report`  | 1..1        | resource  | FHIR DiagnosticReport resource describing the report now in context.
`encounter` | 0..1      | resource  |  A FHIR Encounter resource may be associated with the report
`study`   | 0..*        | resource  |  FHIR ImagingStudy resource(s) describing the image study (or image studies) which are the subject of the report now in context.  For non-imaging related uses of FHIRcast there may be no image study related to the report.  In radiology or other image related uses of FHIRcast, at least one imaging study would be the subject of a report and SHALL be included in the event's context.  
`patient` | 1..1        | resource  |  FHIR Patient resource describing the patient whose report is currently in context. This Patient SHALL be the subject referenced by the DiagnosticReport and any ImagingStudy resources present in the context. 

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in a DiagnosticReport open request:

* [DiagnosticReport for Open Events](StructureDefinition-fhircast-diagnostic-report-open.html)
* [ImagingStudy for Open Events](StructureDefinition-fhircast-imaging-study-open.html)
* [Encounter for Open Events](StructureDefinition-fhircast-encounter-open.html)
* [Patient for Open Events](StructureDefinition-fhircast-patient-open.html)

Other attributes of the DiagnosticReport, ImagingStudy, Encounter, and Patient resources (or resource extensions) may be present in the provided resources; however, attributes not called out in the profiles are not required by the FHIRcast standard.

#### Content Sharing Support

If a Hub supports content sharing, when it distributes a `DiagnosticReport-open` event the Hub associates a `context.versionId` with the [`anchor context`](5_glossary.html).  Subscribers SHALL submit this `context.versionId` in subsequent [`DiagnosticReport-update`](3-6-3-DiagnosticReport-update.html) requests.  If a Subscriber is not subscribed to the [`DiagnosticReport-update`](3-6-3-DiagnosticReport-update.html) event the `context.versionId` can be safely ignored.


### Examples

#### DiagnosticReport-open Example Request

The following example shows a report being opened that contains a single primary study.

```json
{
  "timestamp": "2023-04-01T011:14:24.31",
  "id": "6930b943-39fc-447f-8099-92d17650a375",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "DiagnosticReport-open",
    "context": [
      {
        "key": "report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "2402d3bd-e988-414b-b7f2-4322e86c9327",
          "status": "unknown",
          "basedOn" : [
            {
              "type" : "ServiceRequest",
              "identifier" : {
                "type" : {
                  "coding" : [
                    {
                      "system" : "http://terminology.hl7.org/CodeSystem/v2-0203",
                      "code" : "ACSN"
                    }
                  ]
                },
                "system" : "urn:oid:2.16.840.1.113883.19.5",
                "value" : "GH339884",
                "assigner" : {
                  "reference" : "Organization/a92ac1be-fb34-49c1-be58-10928bd271cc",
                  "display" : "My Healthcare Provider"
                }
              }
            }
          ],
          "code" : {
            "coding" : [
              {
                "system" : "http://loinc.org",
                "code" : "19005-8",
                "display": "Radiology Imaging study [Impression] (narrative)"
              }
            ]
          },
          "subject": {
            "reference": "Patient/503824b8-fe8c-4227-b061-7181ba6c3926"
          },
          "study": [
            {
              "reference": "ImagingStudy/e25c1d31-20a2-41f8-8d85-fe2fdeac74fd"
            }
          ]
        }
      },
      {
        "key": "study",
        "resource": {
          "resourceType": "ImagingStudy",
          "id": "e25c1d31-20a2-41f8-8d85-fe2fdeac74fd",
          "identifier": [
            {
              "system" : "urn:dicom:uid",
              "value" : "urn:oid:1.2.840.83474.8.231.875.3.15.661594731"
            }
          ],
          "status": "unknown",
          "subject": {
            "reference": "Patient/503824b8-fe8c-4227-b061-7181ba6c3926"
          },
          "basedOn" : [
            {
              "type" : "ServiceRequest",
              "identifier" : {
                "type" : {
                  "coding" : [
                    {
                      "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                      "code" : "ACSN"
                    }
                  ]
                },
                "system" : "urn:oid:2.16.840.1.113883.19.5",
                "value" : "GH339884",
                "assigner" : {
                  "reference" : "Organization/a92ac1be-fb34-49c1-be58-10928bd271cc",
                  "display" : "My Healthcare Provider"
                }
              }
            }
          ]
        }
      },
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "503824b8-fe8c-4227-b061-7181ba6c3926",
          "identifier" : [
            {
              "use" : "official",
              "type" : {
                "coding" : [
                  {
                    "system" : "http://terminology.hl7.org/CodeSystem/v2-0203",
                    "code" : "MR"
                  }
                ]
              },
              "system": "urn:oid:2.16.840.1.113883.19.5",
              "value": "4438001",
              "assigner": {
                "reference": "Organization/a92ac1be-fb34-49c1-be58-10928bd271cc",
                "display": "My Healthcare Provider"
              }
            }
          ],
          "name" : [
            {
              "use" : "official",
              "family" : "Smith",
              "given" : [
                "John"
              ],
              "prefix" : [
                "Dr."
              ],
              "suffix" : [
                "Jr.",
                "M.D."
              ]
            }
          ],
          "gender" : "male",
          "birthDate" : "1978-11-03"
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
  "timestamp": "2023-04-01T011:14:24.31",
  "id": "6930b943-39fc-447f-8099-92d17650a375",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "DiagnosticReport-open",
    "context.versionId": "b9574cb0-e9e5-4be1-8957-5fcb51ef33c1",
    "context": [
      ... as above ...
    ]
  }
}
```

### Change Log

{:.grid}
| Version | Description
| ------- | ----
| 0.1 | Initial draft
| 0.5 | Connectathon trials and initial fielded solutions based on draft STU3
| 1.0 | Reference context resource profiles and update example to be compliant with the profiles
