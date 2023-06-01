### Event-name: DiagnosticReport-open

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

A `DiagnosticReport-open` request is posted to the Hub when a new or existing DiagnosticReport is opened by a Subscriber and established as the anchor context of a topic. The `context` field MUST contain at least one `Patient` resource and the anchor context resource.

### Context

{:.grid}
Key | Cardinality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`report` | 1..1 | `DiagnosticReport/{id}?_elements=identifier,subject` | FHIR DiagnosticReport resource describing the report now in context.
`study` | 0..* | `ImagingStudy/{id}?_elements=identifier,subject` | FHIR ImagingStudy resource(s) describing the image study (or image studies) which are the subject of the report now in context.  For non-imaging related uses of FHIRcast, there may be no image study related to the report.  In radiology or other image related uses of FHIRcast, at least one imaging study would be the subject of a report and included in the event's context.  
`patient` | 1..1 | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose report is currently in context. This Patient SHALL be the subject referenced by the DiagnosticReport and an ImagingStudy present in the context. 

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in an ImagingStudy open request:

* [DiagnosticReport for Open Events](StructureDefinition-fhircast-diagnostic-report-open.html)
* [ImagingStudy for Open Events](StructureDefinition-fhircast-imaging-study-open.html)
* [Patient for Open Events](StructureDefinition-fhircast-patient-open.html)

Other attributes of the ImagingStudy and Patient resources (or resource extensions) may be present in the provided resources; however, attributes not called out in the profiles are not required by the FHIRcast standard.

#### Content Sharing Support

If a Hub supports content sharing, when it distributes a `DiagnosticReport-open` event the Hub associates a `context.versionId` with the anchor context.  Subscribers MUST submit this `context.versionId` in subsequent [`DiagnosticReport-update`](3-6-3-diagnosticreport-update.html) requests.  If a Subscriber will neither make a [`DiagnosticReport-update`](3-6-3-diagnosticreport-update.html) request or respond to [`DiagnosticReport-update`](3-6-3-diagnosticreport-update.html) events, the `context.versionId` can be safely ignored.


### Examples

#### DiagnosticReport-open Example Request

The following example shows a report being opened that contains a single primary study.  Note that the diagnostic report's `imagingStudy` and `subject` attributes have references to the imaging study and patient which are also in the open request.

```json
{
  "timestamp": "2020-09-07T14:58:45.988Z",
  "id": "0d4c9998",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "DiagnosticReport-open",
    "context": [
      {
        "key": "report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "40012366",
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
                "code" : "19005-8"
              }
            ]
          },
          "subject": {
            "reference": "Patient/9adc8698-33a4-4f50-897b-4873b64a38c1"
          },
          "study": [
            {
              "reference": "ImagingStudy/28940c5b-925b-47f7-b89a-1fc3da6055c7"
            }
          ]
        }
      },
      {
        "key": "study",
        "resource": {
          "resourceType": "ImagingStudy",
          "id": "28940c5b-925b-47f7-b89a-1fc3da6055c7",
          "identifier": [
            {
              "system": "urn:dicom:uid",
              "value": "urn:oid:2.16.124.113543.6003.1154777499.38476.11982.4847614254"
            }
          ],
          "status": "unknown",
          "subject": {
            "reference": "Patient/9adc8698-33a4-4f50-897b-4873b64a38c1"
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
          "id": "9adc8698-33a4-4f50-897b-4873b64a38c1",
          "identifier" : [
            {
              "use" : "usual",
              "type" : {
                "coding" : [
                  {
                    "system" : "http://terminology.hl7.org/CodeSystem/v2-0203",
                    "code" : "MR"
                  }
                ]
              },
              "system" : "urn:oid:1.2.36.146.595.217.0.1",
              "value" : "12345",
              "assigner" : {
                "display" : "Acme Healthcare"
              }
            }
          ],
          "name" : [
            {
              "use": "official",
              "family": "Umbrage",
              "given": "Lola"
            }
          ],
          "gender" : "female",
          "birthDate" : "1945-11-14"
        }
      }
    ]
  }
}
```

#### DiagnosticReport-open Event Example

The event distributed by the Hub includes a context version in the `context.versionId` event attribute which will be used by Subscribers to make subsequent [`DiagnosticReport-update`](3-6-3-diagnosticreport-update.html) requests.

```json
{
  "timestamp": "2020-09-07T14:58:45.988Z",
  "id": "0d4c9998",
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
