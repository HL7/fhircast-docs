### Event-name: ImagingStudy-close

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

User closed an imaging study.

User closed patient's medical record. A previously open and in context study is no longer open nor in context. When the ImagingStudy refers to a Patient and this patient is the current patient in context, this patient SHALL be indicated in the event

### Context

Key | Optionality | FHIR operation to generate context | Description
----- | -------- | ---- | ----
`patient` | RECOMMENDED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient associated with the study currently in context.
`study` | REQUIRED | `ImagingStudy/{id}?_elements=identifier,subject` | FHIR ImagingStudy resource previously in context. In FHIR DSTU2, STU3 `accession` SHALL also be provided if present.

### Examples

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "imagingstudy-close",
    "context": [
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "status": "available",
          "id": "ewUbXT9RWEbSj5wPEdgRaBw3",
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

Version | Description
---- | ----
1.0 | Initial Release
