### Event-name: ImagingStudy-open

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

User opened an imaging study. The newly opened image study is now the current imaging study in context.  When the image study's subject is a patient, this patient SHALL be provided in the event.

### Context

{:.grid}
Key | Cardinality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`study` | 1..1 | `ImagingStudy/{id}?_elements=identifier,subject` | FHIR ImagingStudy resource describing the image study now in context.
`encounter` | 0..1 | `Encounter/{id}?_elements=identifier,subject` | A FHIR Encounter resource may be associated with the image study.
`patient` | 0..1 | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose image study is currently in context.  A Patient SHALL be present if there is a patient associated with the image study.  Note there are rare cases in which the ImagingStudy.subject references a resource which is not a patient; for example a calibration study would reference the device being calibrated.

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in an ImagingStudy open request:

* [ImagingStudy for Open Events](StructureDefinition-fhircast-imaging-study-open.html)
* [Encounter for Open Events](StructureDefinition-fhircast-encounter-open.html)
* [Patient for Open Events](StructureDefinition-fhircast-patient-open.html)

Other attributes of the ImagingStudy, Encounter, and Patient resources (or resource extensions) may be present in the provided resources; however, attributes not called out in the profiles are not required by the FHIRcast standard.

### Examples
  
```json
{% include ImagingStudy-open-example.liquid.json %}
```

<!---
This is an example for FHIR R5 using the basedOn array for the accession
```json
{
  "timestamp": "2023-04-01T011:03:04.08",
  "id": "bfbe806f-7f94-47bc-b6b8-4c0cf4d4ef7d",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "ImagingStudy-open",
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
--->

### Change Log

{:.grid}
| Version | Description
| ------- | ----
| 1.0 | Initial Release
| 2.0 | Reference context resource profiles and update example to be compliant with the profiles