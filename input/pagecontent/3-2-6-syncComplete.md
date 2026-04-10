This section presents the template to use for defining new events. 

### Event-name: SyncComplete

eventMaturity | [0 - Draft](3-1-2-eventmaturitymodel.html)

### Workflow

All subscribers have affirmatively acknowledged receipt of a context change and this is indicated to Subscribers.

Unlike most of FHIRcast events, SyncComplete is an infrastructural event and does not follow the FHIR-resource-[open|close|update|select] syntax and is directly referenced in the [underlying specification](2_Specification.html).


A `SyncComplete` MAY be sent by the Hub when all subscribers have either:
1. Responded to a context change event with a 200.
2. Responded to a context change event with a 202, followed by a SyncComplete.
3. Responded to a context change event with a 202, followed by a SyncError containing an [OperationOutcome](StructureDefinition-fhircast-subscriber-operation-outcome-syncerrror.html) with a `severity` of merely `warning`.
`SyncComplete` is not used when a Subscriber responds to an `*-update` or `*-select` event.

```
OR

A `SyncComplete` MAY be sent by the Hub when all subscribers have :
1. Responded to a context change event with a 200.

`SyncComplete` is not used when a Subscriber responds to a context change event with an HTTP 202.
```

`SyncComplete` is not used when a Subscriber responds to an `*-update` or `*-select` event.

### Context

{:.grid}
Key       | Cardinality | Type      | Description
--------- | ----------- | --------- | --------------
`operationoutcome` | 1..1 | resource  | A FHIR OperationOutcome based on the profile [Operation outcome for SyncComplete]().

### Examples

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "7544fe65-ea26-44b5-835d-14287e46390b",
    "hub.event": "synccomplete",
    "context": 
"context": [{
  "key": "parameters",
  "resource": {
    "resourceType": "Parameters",
    "parameter": [{
      "name": "relatedEvent",
      "valueIdentifier": {
        "system": "http://hl7.org/fhir/uv/fhircast/eventid",
        "value": "b9a4b2e1-3f4c-4d6a-8e7f-1a2b3c4d5e6f"
      }
    }]
  }
}]
  }
}
```

## Change Log
{:.grid}
Version | Description
------- | ----
1.0     | Initial Release
