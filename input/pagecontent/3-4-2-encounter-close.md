### Event-name: Encounter-close

eventMaturity | [1 - Submitted](3-1-2-eventmaturitymodel.html)

### Workflow

User closed patient's medical record encounter context. A previously open and in context patient encounter is no longer open nor in context. 

### Context

{:.grid}
Key | Cardinality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`encounter` | 1..1 | `Encounter/{id}` | FHIR Encounter resource previously in context.
`patient` | 1..1 | `Patient/{id}?` | FHIR Patient resource describing the patient whose encounter was previously in context.

### Attribute guidance
This section provides guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in an `Encounter` close request.  Other attributes of each resource (or resource extensions) may be present in the provided resources; however, attributes not called out in the below tables are not required by the FHIRcast standard.

#### Encounter resource

{:.grid}
Attribute | Cardinality | Comments
----- | -------- | -------- 
`id` | 1..1 | The logical id of the `Encounter` resource which was provided in the corresponding [Encounter open event](3-4-1-encounter-open.html).
`identifier` | 0..* | The Subscriber making the close request may provide one or more of the `indentifier` values for the `Encounter` which was provided in the corresponding [Encounter open event](3-4-1-encounter-open.html).  The inclusion of `identifier` values enables Subscribers to perform identity verification according to their requirements.
`subject` | 1..1 | SHALL be valued with a reference to the `Patient` resource which was present in the [Encounter open event](3-4-1-encounter-open.html).

#### Patient resource

{:.grid}
Attribute | Cardinality | Comments
----- | -------- | -------- 
`id` | 1..1 |  The logical id of the `Patient` resource which was provided in the corresponding [Encounter open event](3-4-1-encounter-open.html).
`identifier` | 0..* | The Subscriber making the close request may provide one or more of the `indentifier` values for the `Patient` which was provided in the corresponding [Encounter open event](3-4-1-encounter-open.html).  The inclusion of `identifier` values enables Subscribers to perform identity verification according to their requirements.

### Examples

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
