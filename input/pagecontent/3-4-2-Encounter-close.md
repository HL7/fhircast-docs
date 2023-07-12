### Event-name: Encounter-close

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

User closed a patient's medical record encounter context. A previously open and in context patient encounter is no longer open nor in context. 

### Context

{:.grid}
Key | Cardinality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`encounter` | 1..1 | `Encounter/{id}?_elements=identifier	` | FHIR Encounter resource describing the encounter previously in context that is being closed.
`patient` | 1..1 | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient associated with the encounter being closed.

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in an Encounter close request:

* [Encounter for Close Events](StructureDefinition-fhircast-encounter-close.html)
* [Patient for Close Events](StructureDefinition-fhircast-patient-close.html)

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
          "subject": {
            "reference": "Patient/503824b8-fe8c-4227-b061-7181ba6c3926"
          }
        }
      },
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "503824b8-fe8c-4227-b061-7181ba6c3926",
          "identifier" : [
            {
              "use" : "official",
              "type" : {
                "coding" : [
                  {
                    "system" : "http://terminology.hl7.org/CodeSystem/v2-0203",
                    "code" : "MR"
                  }
                ]
              },
              "system": "urn:oid:2.16.840.1.113883.19.5",
              "value": "4438001",
              "assigner": {
                "reference": "Organization/a92ac1be-fb34-49c1-be58-10928bd271cc",
                "display": "My Healthcare Provider"
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
| 2.0 | Reference context resource profiles and update example to be compliant with the profiles
