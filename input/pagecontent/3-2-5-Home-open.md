### Home-open

eventMaturity | [1 - Submitted](3-1-2-eventmaturitymodel.html)

### Workflow

The user has opened or switched back to the application's home page or tab which does not have any FHIR related context.

Unlike most of FHIRcast events, `Home-open` is representing the lack of a FHIR resource context and therefore does not fully follow the `FHIR-resource`-`[open|close]` syntax.

Note that sending a `Home-open` event merely signals that an application has switched to the no-context tab. It does not change the current context. For instance, if a specific patient is currently in context, sending a Home-open event does not imply that this patient is no longer in context.

### Context

The context field is empty.

### Example

```json
{
  "timestamp": "2019-11-25T13:16:00.00",
  "id": "35d0b1d4-de45-4b5b-a0e9-9c51b21ee71a",
  "event": {
  "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065", 
  "hub.event": "home-open", 
  "context": [] 
  }
}
```

### Change Log

{:.grid}
| Version | Description
| ---- | ----
| 1.0 | Initial Release
