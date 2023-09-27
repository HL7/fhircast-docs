### Event name: Patient-open

| eventMaturity | [3 - Considered](3-1-2-eventmaturitymodel.html)| 
| Version | [1.0](3-2-3-Patient-open.html) |

### Workflow

User opened a patient's medical record. The indicated patient is now the current patient in context. 

### Context

{:.grid}
Key | Cardinality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | 1..1 | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient now in context.

The following profile provides guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in a Patient open request:

* [Patient for Open Events](StructureDefinition-fhircast-patient-open.html)

Other attributes of the Patient resource (or resource extensions) may be present in the provided resource; however, attributes not called out in the profile are not required by the FHIRcast standard.

### Examples

```json
{
  "timestamp": "2023-04-01T010:38:04.16",
  "id": "6efe28b2-7f8b-4cbc-bc59-a21a902f7e04",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "Patient-open",
    "context": [
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
          ],
          "name" : [
            {
              "use" : "official",
              "family" : "Smith",
              "given" : [
                "John"
              ],
              "prefix" : [
                "Dr."
              ],
              "suffix" : [
                "Jr.",
                "M.D."
              ]
            }
          ],
          "gender" : "male",
          "birthDate" : "1978-11-03"
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
| 1.1 | Deprecate encounter element in favor of dedicated `encounter-open` event
| 2.0 | Reference context resource profiles and update example to be compliant with the profiles