### Event name: `patient-open`

eventMaturity | [3 - Considered](3-1-2-eventmaturitymodel.html)

### Workflow

User opened patient's medical record. The indicated patient is the current patient in context. 

### Context

{:.grid}
Key | Optionality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose chart is currently in context.
~~`encounter`~~ | ~~REQUIRED, if exists~~ | ~~`Encounter/{id}?_elements=identifier`~~ | ~~FHIR Encounter resource in context in the newly opened patient's chart.~~ DEPRECATED in favor of a dedicated `encounter-open` event. 

### Examples

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "patient-open",
    "context": [
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "ewUbXT9RWEbSj5wPEdgRaBw3",
          "identifier": [
            {
              "type": {
                "coding": [
                  {
                    "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                    "value": "MR",
                    "display": "Medical Record Number"
                  }
                ]
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
| ---- | ----
| 1.0 | Initial Release
| 1.1 | Deprecate encounter element in favor of dedicated `encounter-open` event.

