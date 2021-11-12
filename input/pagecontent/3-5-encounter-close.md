<!-- ## Encounter-close -->

eventMaturity | [0 - Draft](../../specification/STU1/#event-maturity-model)

### Workflow

User closed patient's medical record encounter context. A previously open and in context patient encounter is no longer open nor in context. 

### Context

Key | Optionality | Fhir operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose encounter was previously in context.
`encounter` | REQUIRED | `Encounter/{id}?_elements=identifier	` | FHIR Encounter resource previously in context.


### Examples

<mark>

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "encounter-close",
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
            },
            {
              "key": "encounter",
              "resource": {
                "resourceType": "Encounter",
                "id": "90235y2347t7nwer7gw7rnhgf",
                "identifier": [
                  {
                    "system": "28255",
                    "value": "344384384"
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
    ]
  }
}
```

</mark>

### Change Log

Version | Description
---- | ----
1.0 | Initial Release
