### Event-name: userhibernate

eventMaturity | [1 - Submitted](3-1-2-eventmaturitymodel.html)

### Workflow

User temporarily suspended their session. The user's session will eventually resume.
 
Unlike most of FHIRcast events, `userhibernate` is a statically named event and therefore does not follow the `FHIR-resource`-`[open|close]` syntax.

### Context

The context is empty.

### Examples

```json
{
  "timestamp": "2019-11-25T13:16:00.00",
  "id": "35d0b1d4-de45-4b5b-a0e9-9c51b21ee71a",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "userHibernate",
    "context": []
  }
}
```

### Change Log

Version | Description
---- | ----
1.0 | Initial Release
