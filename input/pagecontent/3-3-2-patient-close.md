### Event-name: Patient-close

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

User closed patient's medical record. A previously opened and in context patient is no longer open nor in context. 

### Context

{:.grid}
Key | Cardinality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | 1..1 | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient who was previously in context.

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in a Patient close request:

* [Patient for Close Events](StructureDefinition-fhircast-patient-close.html)

Other attributes of the Patient resource (or resource extensions) may be present in the provided resource; however, attributes not called out in the profile are not required by the FHIRcast standard.

### Examples

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "Patient-close",
    "context": [
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "9adc8698-33a4-4f50-897b-4873b64a38c1",
          "identifier" : [
            {
              "use" : "usual",
              "type" : {
                "coding" : [
                  {
                    "system" : "http://terminology.hl7.org/CodeSystem/v2-0203",
                    "code" : "MR"
                  }
                ]
              },
              "system" : "urn:oid:1.2.36.146.595.217.0.1",
              "value" : "12345",
              "assigner" : {
                "display" : "Acme Healthcare"
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
| 1.1 | Deprecate encounter element in favor of dedicated `encounter-close` event
| 2.0 | Reference context resource profiles and update example to be compliant with the profiles
