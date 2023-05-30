### Event-name: ImagingStudy-open

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

User opened record of imaging study. The newly open study is the current imaging study in context. When the ImagingStudy refers to a Patient and this patient is the current patient in context, this patient SHALL be indicated in the event

### Context

{:.grid}
Key | Cardinality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`study` | 1..1 | `ImagingStudy/{id}?_elements=identifier	` | FHIR ImagingStudy resource describing the imaging study currently in context.  Note that in addition to the request identifier and accession elements, the DICOM UID and FHIR patient reference are included because they are required by the FHIR specification. The accession number SHALL be included as an identifier if present.
`patient` | 0..1 | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose imaging study is currently in context.  A patient SHALL be present if there is a patient associated with the study.  Note there are rare cases in which the ImagingStudy.subject references a resource which is not a patient; for example a calibration study.

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in an Encounter open request:

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
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "9adc8698-33a4-4f50-897b-4873b64a38c1",
          "identifier" : [{
            "use" : "usual",
            "type" : {
              "coding" : [{
                "system" : "http://terminology.hl7.org/CodeSystem/v2-0203",
                "code" : "MR"
              }]
            },
            "system" : "urn:oid:1.2.36.146.595.217.0.1",
            "value" : "12345",
            "assigner" : {
              "display" : "Acme Healthcare"
              }
          }],
          "name" : [{
            "use": "official",
            "family": "Umbrage",
            "given": "Lola"
            }],
          "gender" : "female",
          "birthDate" : "1945-11-14"
        }
      },
      {
        "key": "study",
        "resource": {
          "resourceType": "ImagingStudy",
          "id": "28940c5b-925b-47f7-b89a-1fc3da6055c7",
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
            "reference": "Patient/9adc8698-33a4-4f50-897b-4873b64a38c1"
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
| 1.0 | Initial Release
