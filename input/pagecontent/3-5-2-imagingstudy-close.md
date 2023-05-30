### Event-name: ImagingStudy-close

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

User closed an imaging study.

A previously open and in context image study is no longer open nor in context. When the ImagingStudy refers to a Patient this patient SHALL be indicated in the event.

### Context

{:.grid}
Key | Cardinality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`study` | 1..1 | `ImagingStudy/{id}?_elements=identifier,subject` | FHIR ImagingStudy resource describing the image study previously in context that is being closed.
`patient` | 0..1 | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient associated with the image study being closed.

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in an ImagingStudy close request:

* [ImagingStudy for Close Events](StructureDefinition-fhircast-imaging-study-close.html)
* [Patient for Close Events](StructureDefinition-fhircast-patient-close.html)

Other attributes of the ImagingStudy and Patient resources (or resource extensions) may be present in the provided resources; however, attributes not called out in the profile are not required by the FHIRcast standard.


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
| 1.0  | Initial Release
