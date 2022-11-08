### Event-name: DiagnosticReport-close

eventMaturity | [1 - Submitted](3-1-2-eventmaturitymodel.html)

### Workflow

A `DiagnosticReport-close` event is posted to the Hub when an application desires to close the active anchor context centered workflow.  After the event is distributed to all applications subscribed to the topic, it is expected that the Hub will remove any content associated with the anchor context from its memory.

### Context

{:.grid}
Key | Optionality | FHIR operation to generate context | Description
---- | ---- | ---- | ----
`report` | REQUIRED | `DiagnosticReport/{id}?_elements=identifier` | Anchor context

### Examples

#### DiagnosticReport-close Example

This example closes a DiagnosticReport anchor context.

```json
{
  "timestamp": "2020-09-07T15:04:43.133Z",
  "id": "4441881",
  "event": {
    "hub.topic": "DrXRay",
    "hub.event": "DiagnosticReport-close",
    "context": [
      {
        "key": "Report",
        "resource": {
          "resourceType": "DiagnosticReport",
          "id": "40012366",
        }
      }
    ]
  }
}
```

### Change Log

{:.grid}
| Version | Description
| ------- | ----
| 0.1 | Initial draft
