### Event name: `Patient-open`

eventMaturity | [2 - Tested](3-1-EventMaturityModel.html)

### Workflow

User opened patient's medical record. Only a single patient is currently in context.  
A `Patient-open` request is posted to the Hub when a patient is opened by an application and established as the anchor context of a topic.

When an `Patient-open` event is received by an application, the application should respond as is appropriate for its clinical use.

### Context

Key | Optionality | Fhir operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | Patient being opened

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
              },
              "system": "urn:oid:1.2.36.146.595.217.0.1",
              "value": "213434"
            }
          ]
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
1.1 | Deprecate encounter element in favor of dedicated `encounter-open` event.

