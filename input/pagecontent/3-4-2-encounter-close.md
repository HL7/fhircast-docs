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
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "Encounter-close",
    "context": [
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "9adc8698-33a4-4f50-897b-4873b64a38c1",
          "identifier" : [{
            "use" : "usual",
            "type" : {
              "coding" : [{
                "system" : "http://terminology.hl7.org/CodeSystem/v2-0203",
                "code" : "MR"
              }]
            },
            "system" : "urn:oid:1.2.36.146.595.217.0.1",
            "value" : "12345",
            "assigner" : {
              "display" : "Acme Healthcare"
              }
          }],
          "name" : [{
            "use": "official",
            "family": "Umbrage",
            "given": "Lola"
            }]
        }
      },
      {
        "key": "encounter",
        "resource": {
          "resourceType": "Encounter",
          "id": "9adc8698-33a4-4f50-897b-4873b64a38c1",
          "identifier": [
            {
              "system": "28255",
              "value": "344384384"
            }
          ],
          "subject": {
            "reference": "Patient/9adc8698-33a4-4f50-897b-4873b64a38c1"
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
