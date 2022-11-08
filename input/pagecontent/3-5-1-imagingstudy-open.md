### Event-name: ImagingStudy-open

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

User opened record of imaging study. The newly open study is the current imaging study in context. When the ImagingStudy refers to a Patient and this patient is the current patient in context, this patient SHALL be indicated in the event

### Context

{:.grid}
Key | Optionality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | RECOMMENDED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient currently in context. (Note that there may be cases in which the imagingstudy.subject references a different patient, or even other resource, from the patient in context).
`study` | REQUIRED | `ImagingStudy/{id}?_elements=identifier,subject` | FHIR ImagingStudy resource in context. Note that in addition to the request identifier and accession elements, the DICOM uid and FHIR patient reference are included because they're required by the FHIR specification. Note, in DSTU2 and STU3, the top-level `accession` element SHALL be included if present. 

### Examples
  
```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "imagingstudy-open",
    "context": [
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "ewUbXT9RWEbSj5wPEdgRaBw3",
          "status": "available",
          "identifier": [
            {
              "system": "urn:oid:1.2.840.114350",
              "value": "185444"
            },
            {
              "system": "urn:oid:1.2.840.114350.1.13.861.1.7.5.737384.27000",
              "value": "2667"
            }
          ]
        }
      },
      {
        "key": "study",
        "resource": {
          "resourceType": "ImagingStudy",
          "id": "8i7tbu6fby5ftfbku6fniuf",
          "status": "available",
          "identifier": [
            {
              "system": "7678",
              "value": "185444"
            }
          ],
          "patient": {
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
| 1.0 | Initial Release
