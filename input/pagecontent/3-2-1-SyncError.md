### Event-name: SyncError

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

A synchronization error has been detected and this is indicated to Subscribers. 

Unlike most of FHIRcast events, `SyncError` is an infrastructural event and does not follow the `FHIR-resource`-`[open|close|update|select]` syntax and is directly referenced in the [underlying specification](2_Specification.html).

A `SyncError` is sent by a Subscriber when:
1. It responds to a context change event with a 202 indicating the context change is accepted but has not yet occurred, and later the Subscriber decides to refuse the context (see: [`Event Notification Response`](2-5-EventNotification.html#event-notification-response)). 

In these events the field `issue.severity` is SHALL be set to `warning` as is specified in [Operation outcome for Subscriber generated sync-errors](StructureDefinition-fhircast-subscriber-operation-outcome-syncerrror.html). `SyncError` is not used when a Subscriber responds to an `*-update` or `*-select` event.


A `SyncError` is broadcast by the Hub when one of the following conditions occur:
1. A Subscriber encounters an error when following a context, returning a server error (50X) to the Hub (see: [`Event Notification Response`](2-5-EventNotification.html#event-notification-response)).
2. A Subscriber decides not to follow a context, returning a server conflict (409) to the Hub (see: [`Event Notification Response`](2-5-EventNotification.html#event-notification-response)).
3. The Hub detects a connection issue with a Subscriber (see: [`Hub Generated SyncError Events`](2-5-EventNotification.html#hub-generated-syncerror-events)).

In these events the field `issue.severity` SHALL beset to `warning` as is specified in [Operation outcome for Hub generated sync-errors](StructureDefinition-fhircast-hub-operation-outcome-syncerrror.html).

### Context

{:.grid}
Key       | Cardinality | Type      | Description
--------- | ----------- | --------- | --------------
`operationoutcome` | 1..1 | resource  | A FHIR OperationOutcome based on the profile [Operation outcome for sync-errors](StructureDefinition-fhircast-operation-outcome-syncerror.html).


### Example

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "7544fe65-ea26-44b5-835d-14287e46390b",
    "hub.event": "syncerror",
    "context": [
      {
        "key": "operationoutcome",
        "resource": {
          "resourceType": "OperationOutcome",
          "issue": [
            {
              "severity": "warning",
              "code": "processing",
              "diagnostics": "Acme Product failed to follow context",
              "details": {
                "coding": [
                  {
                    "system": "https://fhircast.hl7.org/events/syncerror/eventid",
                    "code": "fdb2f928-5546-4f52-87a0-0648e9ded065"
                  },
                  {
                    "system": "https://fhircast.hl7.org/events/syncerror/eventname",
                    "code": "Patient-open"
                  },
                  {
                    "system": "https://fhircast.hl7.org/events/syncerror/subscriber",
                    "code": "Acme Product"
                  },
                  {
                    "system": "http://example.com/events/syncerror/your-error-code-system",
                    "code": "FHIRcast sync error"
                  }
                ]
              }
            }
          ]
        }
      }
    ]
  }
}
```

### Change Log

{:.grid}
| Version | Description |
| ------- | ------------- |
| 1.0     | Initial Release |
| 2.0     | Require id of event syncerror is about, in `OperationOutcome.details.coding.code` |
| 2.1     | Clarify scenarios, make the OperationOutcome resource required, and specify explicit `severity` codes |
