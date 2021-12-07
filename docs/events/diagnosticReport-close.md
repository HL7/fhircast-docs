# DiagnosticReport-close
eventMaturity | [1 - Submitted](../../specification/STU3/#event-maturity-model)

## Workflow
A `DiagnosticReport-close` event is posted to the Hub when an application desires to close the active anchor context centered workflow.  After the event is distributed to all applications subscribed to the topic, it is expected that the Hub will remove any content associated with the anchor context from its memory.

## Examples

### DiagnosticReport-close Example
This example closes a DiagnosticReport anchor context.

```
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

## Change Log
Version | Description
---- | ----
0.1 | Initial draft
