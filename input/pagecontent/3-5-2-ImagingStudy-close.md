### Event-name: ImagingStudy-close

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

User closed an imaging study. A previously open and in context image study is no longer open nor in context. When the ImagingStudy refers to a Patient this patient SHALL be indicated in the event.

### Context

{:.grid}
Key       | Cardinality | Type      | Description
--------- | ----------- | --------- | --------------
`study`   | 1..1        | resource  | FHIR ImagingStudy resource describing the image study previously in context that is being closed.
`encounter` | 0..1      | resource  | A FHIR Encounter resource may be associated with the image study.
`patient` | 0..1        | resource  | FHIR Patient resource describing the patient associated with the image study being closed.  A Patient SHALL be present if there is a patient associated with the image study.

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in an ImagingStudy close request:

* [ImagingStudy for Close Events](StructureDefinition-fhircast-imaging-study-close.html)
* [Encounter for Close Events](StructureDefinition-fhircast-encounter-close.html)
* [Patient for Close Events](StructureDefinition-fhircast-patient-close.html)

Other attributes of the ImagingStudy, Encounter, and Patient resources (or resource extensions) may be present in the provided resources; however, attributes not called out in the profiles are not required by the FHIRcast standard.

### Examples

```json
{
  "timestamp": "2023-04-01T011:13:12.42",
  "id": "bccaeba4-494a-459b-adf3-be0cf29dd2a0",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "ImagingStudy-close",
    "context": [
      {
        "key": "study",
        "resource": {
          "resourceType": "ImagingStudy",
          "id": "e25c1d31-20a2-41f8-8d85-fe2fdeac74fd",
          "identifier": [
            {
              "system" : "urn:dicom:uid",
              "value" : "urn:oid:1.2.840.83474.8.231.875.3.15.661594731"
            },
            {
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
          ],
          "status": "unknown",
          "subject": {
            "reference": "Patient/503824b8-fe8c-4227-b061-7181ba6c3926"
          }
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

<!---
This is an example for FHIR R5 using the basedOn array for the accession
```json
{
  "timestamp": "2023-04-01T011:13:12.42",
  "id": "bccaeba4-494a-459b-adf3-be0cf29dd2a0",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "ImagingStudy-close",
    "context": [
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
--->

### Change Log

{:.grid}
| Version | Description
| ------- | ----
| 1.0 | Initial Release
| 1.1 | Reference context resource profiles and update example to be compliant with the profiles
