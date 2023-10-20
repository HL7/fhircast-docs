### Event-name: UserHibernate

eventMaturity | [1 - Submitted](3-1-2-eventmaturitymodel.html)

### Workflow

User temporarily suspended their session due to a session time-out or other reason. The user's session will eventually resume.
 
Unlike most of FHIRcast events, `UserHibernate` is a statically named event and therefore does not follow the `FHIR-resource`-`[open|close]` syntax.

### Context

The context SHOULD contain a Parameters resource according to the following profile [Hibernate Context](StructureDefinition-fhircast-hibernate.html).

### Examples

```json
{
  "timestamp": "2019-11-25T13:16:00.00",
  "id": "35d0b1d4-de45-4b5b-a0e9-9c51b21ee71a",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "userHibernate",
    "context": [{
      "key": "parameters",
      "resource" : {
        "resourceType": "Parameters",
        "parameter":[{
          "name": "code",
          "valueCoding": {
            "system": "http://hl7.org/fhir/uv/fhircast/CodeSystem/fhircast-hibernate-codesystem",
            "code" : "user-initiated",
            "display" : "The user initiated the hibernation."
          }
        }]
      }
    }]
  }
}
```

### Change Log

{:.grid}
| Version | Description
| ------- | ----
| 1.0     | Initial Release
