# Patient-close

eventMaturity | [2 - Tested](../../specification/STU1/#event-maturity-model)

## Workflow

User closed patient's medical record. A previously open and in context patient chart is no longer open nor in context. The previously open patient may have been within the context of a specific encounter, or not. 

## Context

Key | Optionality | Fhir operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose chart was previously in context.
`encounter` | REQUIRED, if exists | `Encounter/{id}?_elements=identifier	` | FHIR Encounter resource previously in context in the now closed patient's chart.


### Examples

<mark>
```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "patient-close",
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
                    "display": "Medication Record Number"
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
</mark>

## Change Log

Version | Description
---- | ----
1.0 | Initial Release
