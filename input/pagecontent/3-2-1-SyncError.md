### Event-name: SyncError

eventMaturity | [2 - Tested](3-1-2-eventmaturitymodel.html)

### Workflow

A synchronization error has been detected and this is indicated to Subscribers. 

Unlike most of FHIRcast events, `SyncError` is an infrastructural event and does not follow the `FHIR-resource`-`[open|close]` syntax and is directly referenced in the [underlying specification](2_Specification.html).

A `syncerror` is sent by a Subscriber when:
1. It responds to a context change event with a 202 indicating the context change is accepted but has not yet occurred, and later the Subscriber decides to refuse the context (see: [`Event Notification Response`](2-5-EventNotification.html#event-notification-response)) - the `severity` of the `operationoutcome` resource in the `syncerror` SHALL be `warning`

A `syncerror` is broadcast by the Hub when one of the following conditions occur:
1. A Subscriber encounters an error when following a context, returning a server error (50X) to the Hub (see: [`Event Notification Response`](2-5-EventNotification.html#event-notification-response)) - the `severity` of the `operationoutcome` resource in the `syncerror` SHALL be `information`
2. A Subscriber decides not to follow a context, returning a server conflict (409) to the Hub (see: [`Event Notification Response`](2-5-EventNotification.html#event-notification-response)) - the `severity` of the `operationoutcome` resource in the `syncerror` SHALL be `information`
3. The Hub detects a connection issue with a Subscriber (see: [`Hub Generated syncerror Events`](2-5-EventNotification.html#hub-generated-syncerror-events)) - the `severity` of the `operationoutcome` resource shall be `information`

### Context

The `context` array SHALL contain a single FHIR OperationOutcome.

{:.grid}
Key | Optionality | FHIR operation to generate context | Description
----- | -------- | ---- | ----
`operationoutcome` | REQUIRED | `OperationOutcome` | FHIR resource describing an outcome of an unsuccessful system action.

Content of the OperationOutcome resource SHALL be at least one `issue` with the initial `issue` containing:
* `issue[0].severity` as per the above workflow section
* `issue[0].code` of `processing`
* `issue[0].details` SHALL be present
* `issue[0].details.coding` SHALL contain at least three elements
  * `issue[0].details.coding[0]` SHALL contain the id of the event that this error is related to as a `code` with the `system` value of "https://fhircast.hl7.org/events/syncerror/eventid"
  * `issue[0].details.coding[1]` SHALL contain the name of the relevant event with a `system` value of "https://fhircast.hl7.org/events/syncerror/eventname" 
  * `issue[0].details.coding[2]` SHALL contain the optional `subscriber.name` attribute of the original subscription of the relevant Subscriber with a `system` value of "https://fhircast.hl7.org/events/syncerror/subscriber"; the `code` attribute MAY be an empty string if no `subscriber.name` of the relevant Subscriber was provided in the original subscription
  * additional `coding` elements MAY be included with different `system` values to provide extra information about the `syncerror`
* `issue[0].diagnostics` attribute SHALL contain a human readable explanation on the source and reason for the error.

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
| 3.0     | Clarify scenarios, make the OperationOutcome resource required, and specify explicit `severity` codes |