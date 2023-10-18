### Event-name: DiagnosticReport-close

{:.grid}
| Event-maturity | [2 - Tested](3-1-2-eventmaturitymodel.html)| 
| Version | [1.0](3-6-2-DiagnosticReport-close.html) |
| All versions | [1.0](3-6-2-DiagnosticReport-close.html) |

### Workflow

User closed a report. A previously open and in context report is no longer open nor in context.

### Context

{:.grid}
Key | Cardinality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`report` | 1..1 | `DiagnosticReport/{id}?_elements=identifier,subject` | FHIR DiagnosticReport resource describing the report previously in context that is being closed.
`encounter` | 0..1 | `Encounter/{id}?_elements=identifier,subject` | A FHIR Encounter resource may be associated with the report
`study` | 0..* | `ImagingStudy/{id}?_elements=identifier,subject` | FHIR ImagingStudy resource(s) describing any image study that was opened as part of the report context that is being closed.
`patient` | 1..1 | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient associated with the report being closed.

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in DiagnosticReport close request:

* [DiagnosticReport for Close Events](StructureDefinition-fhircast-diagnostic-report-close.html)
* [ImagingStudy for Close Events](StructureDefinition-fhircast-imaging-study-close.html)
* [Encounter for Close Events](StructureDefinition-fhircast-encounter-close.html)
* [Patient for Close Events](StructureDefinition-fhircast-patient-close.html)

Other attributes of the DiagnosticReport, ImagingStudy, Encounter, and Patient resources (or resource extensions) may be present in the provided resources; however, attributes not called out in the profiles are not required by the FHIRcast standard.

#### Content Sharing Support

If a Hub supports content sharing, after it distributes the `DiagnosticReport-close` event to all Subscribers, the Hub should remove any content associated with the anchor context from its working memory.


### Examples

#### DiagnosticReport-close Example

```json
{
  "timestamp": "2023-04-01T011:18:52.21",
  "id": "1d35d190-2fc9-45df-a9c4-fd0de885544c",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "DiagnosticReport-close",
    "context": [
      {
        "key": "report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "2402d3bd-e988-414b-b7f2-4322e86c9327",
          "identifier" : [
            {
              "use" : "official",
              "system" : "http://myhealthcare.com/reporting-system",
              "value" : "GH339884.RPT.0001"
            }
          ],
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
          "imagingStudy": [
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
          ]
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
| 0.5 | Connectathon trials and initial fielded solutions based on draft STU3
| 1.0 | Reference context resource profiles and update example to be compliant with the profiles