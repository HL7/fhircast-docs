# ImagingStudy-open

eventMaturity | [2 - Tested](../../specification/STU1/#event-maturity-model)

## Workflow

User opened record of imaging study. The newly open study may have been associated with a specific patient, or not. 

## Context

Key | Optionality | Fhir operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient associated with the study currently in context.
`study` | REQUIRED | `ImagingStudy/{id}?_elements=identifier,accession` | FHIR ImagingStudy resource in context. Note that in addition to the request identifier and accession elements, the DICOM uid and FHIR patient reference are included because they're required by the FHIR specification.


### Examples

<mark>
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
          "uid": "urn:oid:2.16.124.113543.6003.1154777499.30246.19789.3503430045",
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
</mark>

## Change Log

Version | Description
---- | ----
1.0 | Initial Release
