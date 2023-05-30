### Event-name: `Encounter-open`

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

User opened patient's medical record in the context of a single encounter. Only a single patient and encounter is currently in context.

### Context

{:.grid}
Key | Cardinality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`encounter` | 1..1 | `Encounter/{id}?_elements=identifier	` | FHIR Encounter resource describing the encounter currently in context.
`patient` | 1..1 | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose encounter is currently in context.

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in an Encounter open request:

* [Encounter for Open Events](StructureDefinition-fhircast-encounter-open.html)
* [Patient for Open Events](StructureDefinition-fhircast-patient-open.html)

Other attributes of the Encounter and Patient resources (or resource extensions) may be present in the provided resources; however, attributes not called out in the profiles are not required by the FHIRcast standard.

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
      },
      {
        "key": "encounter",
        "resource": {
          "resourceType": "Encounter",
          "id": "9d253ea5-34a5-4c36-90ef-d5234cee88af",
          "identifier": [
            {
              "system": "28255",
              "value": "344384384"
            }
          ],
          "status" : "unknown",
          "class" : {
            "system" : "http://terminology.hl7.org/CodeSystem/v3-ActCode",
            "code" : "AMB"
            },
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
