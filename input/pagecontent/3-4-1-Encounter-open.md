### Event-name: Encounter-open

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

User opened patient's medical record in the context of a single encounter. The indicated encounter and its patient are now in context.

### Context

{:.grid}
Key | Cardinality |Description
----- | -------- |---- 
`encounter` | 1..1 | FHIR Encounter resource describing the encounter now in context.
`patient` | 1..1 | FHIR Patient resource describing the patient whose encounter is now in context.

The following profiles provide guidance as to which resource attributes should be present and considerations as to how each attribute should be valued in an Encounter open request:

* [Encounter for Open Events](StructureDefinition-fhircast-encounter-open.html)
* [Patient for Open Events](StructureDefinition-fhircast-patient-open.html)

Other attributes of the Encounter and Patient resources (or resource extensions) may be present in the provided resources; however, attributes not called out in the profiles are not required by the FHIRcast standard.

### Examples

```json
{
  "timestamp": "2023-04-01T010:54:10.23",
  "id": "c6a3e2eb-16b4-4eb8-b48b-7eb6c924919b",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "Encounter-open",
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
| 2.0 | Reference context resource profiles and update example to be compliant with the profiles
