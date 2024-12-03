### Event-name: Encounter-close

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

User closed a patient's medical record encounter context. A previously open and in context patient encounter is no longer open nor in context. 

### Context

{:.grid}
Key | Cardinality | Description
----- | -------- | ---- 
`encounter` | 1..1 | FHIR Encounter resource describing the encounter previously in context that is being closed.

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in an Encounter close request:

* [Encounter for Close Events](StructureDefinition-fhircast-encounter-close.html)

Other attributes of the Encounter and Patient resources (or resource extensions) may be present in the provided resources; however, attributes not called out in the profiles are not required by the FHIRcast standard.

### Examples

```json
{
  "timestamp": "2023-04-01T010:58:32.35",
  "id": "96e847ed-4889-47e8-9f96-1458f50f405d",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "Encounter-close",
    "context": [
      {
        "key": "encounter",
        "resource": {
          "resourceType": "Encounter",
          "id": "8cc652ba-770e-4ae1-b688-6e8e7c737438",
          "identifier": [
            {
              "use" : "official",
              "system" : "http://myhealthcare.com/visits",
              "value" : "r2r22345"
            }
          ],
          "status" : "unknown",
          "class" : {
            "system" : "http://terminology.hl7.org/CodeSystem/v3-ActCode",
            "code" : "AMB"
          },
          "subject": {
            "reference": "Patient/503824b8-fe8c-4227-b061-7181ba6c3926"
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
|    1.0  | Initial Release
|    1.1  | Reference context resource profiles and update example to be compliant with the profiles
|    2.0  | Removed references to other resources.
