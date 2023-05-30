### Event-name: ImagingStudy-open

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

User opened an imaging study. The newly opened image study is now the current imaging study in context. When the image study's subject is a patient, this patient SHALL be provided in the event.

### Context

{:.grid}
Key | Cardinality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`study` | 1..1 | `ImagingStudy/{id}?_elements=identifier,subject` | FHIR ImagingStudy resource describing the imaging study currently in context.
`patient` | 0..1 | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose imaging study is currently in context.  A Patient SHALL be present if there is a patient associated with the study.  Note there are rare cases in which the ImagingStudy.subject references a resource which is not a patient; for example a calibration study would reference the device being calibrated.

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in an ImagingStudy open request:

* [ImagingStudy for Open Events](StructureDefinition-fhircast-imaging-study-open.html)
* [Patient for Open Events](StructureDefinition-fhircast-patient-open.html)

Other attributes of the ImagingStudy and Patient resources (or resource extensions) may be present in the provided resources; however, attributes not called out in the profiles are not required by the FHIRcast standard.

### Examples
  
```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "ImagingStudy-open",
    "context": [
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

### Change Log

{:.grid}
| Version | Description
| ------- | ----
| 1.0 | Initial Release
| 2.0 | Reference context resource profiles and update example to be compliant with the profiles
