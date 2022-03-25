### Event-name: `Encounter-open`

eventMaturity | [0 - Draft](3-1-EventMaturityModel.html)

### Workflow

An `Encounter-open` request is posted to the Hub when an encounter is opened by an application and established as the anchor context of a topic.

When an `Encounter-open` event is received by an application, the application should respond as is appropriate for its clinical use.

### Context

Key | Optionality | Fhir operation to generate context | Description
----- | -------- | ---- | ---- 
`encounter` | REQUIRED | `Encounter/{id}?_elements=identifier	` | Encounter being opened
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | Patient resource describing the patient associated with the encounter

### Examples

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "encounter-open",
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
              "system": "urn:oid:1.2.36.146.595.217.0.1",
              "value": "213434"
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
              "system": "http://healthcare.example.org/identifiers/encounter",
              "value": "1234213.52345873"
            }
          ],
          "status": "in-progress",
          "class": {
            "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
            "code": "IMP",
            "display": "inpatient encounter"
          },
          "subject": {
            "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
          }
        }
      }
    ]
  }
}
```

## Change Log

Version | Description
---- | ----
1.0 | Initial Release
