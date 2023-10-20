### Event-name: UserLogout

{:.grid}
| Event-maturity | [1 - Submitted](3-1-2-eventmaturitymodel.html) | 
| Version | 2.0 |
| All Versions | [1.0](https://fhircast.hl7.org/events/userlogout/), [2.0](3-2-3-UserLogout.html)  |


### Workflow

A Subscriber indicates that the User's session has ended, perhaps by exiting the Subscriber through a logout, session time-out or other reason. 

Unlike most of FHIRcast events, `UserLogout` is a statically named event and therefore does not follow the regular FHIRcast syntax.

Implementers are encouraged to consider if and when their application should logout the user upon receiving an userLogout event, and if so, how to preserve application state.

If a Subscriber decides that it will not logout the current user it SHOULD send a [SyncError](3-2-1-SyncError.html) with appropriate details indicating why the Subscriber chose not to logout the current user. 

### Context

The context SHOULD contain a Parameters resource according to the following profile [Logout Context](StructureDefinition-fhircast-logout.html).

### Examples

```json
{
  "timestamp": "2019-11-25T13:16:00.00",
  "id": "35d0b1d4-de45-4b5b-a0e9-9c51b21ee71a",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065", 
    "hub.event": "userLogout", 
    "context": [{
      "key": "parameters",
      "resource" : {
        "resourceType": "Parameters",
        "parameter":[{
          "name": "code",
          "valueCoding": {
            "system": "http://hl7.org/fhir/uv/fhircast/CodeSystem/fhircast-logout-codesystem",
            "code" : "user-initiated",
            "display": "The user initiated the logour and suggests all Subscribers should logout."
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
| ---- | ----
| 1.0 | Initial Release
