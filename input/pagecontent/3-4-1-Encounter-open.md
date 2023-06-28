### Event-name: `Encounter-open`

eventMaturity | [1 - Submitted](3-1-2-eventmaturitymodel.html)

### Workflow

User opened patient's medical record in the context of a single encounter. Only a single patient and encounter is currently in context.

### Context

{:.grid}
Key | Optionality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`encounter` | REQUIRED | `Encounter/{id}?_elements=identifier	` | FHIR Encounter resource in context.
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose encounter is currently in context.

### Examples


```json
{
  "timestamp": "2018-01-08T01:35:25.33",
  "id": "q9v3jubd43i4ufhff",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "Encounter-open",
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
              },
              "system" : "urn:oid:1.2.36.146.595.217.0.1",
              "value" : "12345"
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
| ---- | ----
| 1.0 | Initial Release
