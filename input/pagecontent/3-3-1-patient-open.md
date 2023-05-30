### Event name: `Patient-open`

eventMaturity | [3 - Considered](3-1-2-eventmaturitymodel.html)

### Workflow

User opened patient's medical record. The indicated patient is the current patient in context. 

### Context

{:.grid}
Key | Cardinality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | 1..1 | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient currently in context.

The following profile provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in a Patient open request:

* [Patient for Open Events](StructureDefinition-fhircast-patient-open.html)

Other attributes of the Patient resource (or resource extensions) may be present in the provided resource; however, attributes not called out in the profile are not required by the FHIRcast standard.

### Examples

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "Patient-open",
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
            }],
          "gender" : "female",
          "birthDate" : "1945-11-14"
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

