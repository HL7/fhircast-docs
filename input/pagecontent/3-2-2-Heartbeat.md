{% include questionnote.html text='Implementer feedback is requested for the need to support Heartbeat.htmls for WebSockets.' %}

### Event-name: Heartbeat event

eventMaturity | [1 - Submitted](3-1-2-eventmaturitymodel.html)

### Workflow

The Heartbeat.html event is sent regularly by the Hub to indicate that a connection should remain open.  This event SHALL be sent at least every 10 second, or an order of magnitude lower than the subscription time-out.

### Context

The context of the Heartbeat.html event described in the table below.

{:.grid}
| Key | Optionality | # | type | Description
| --- | --- | --- | --- | ---
| `period` | REQUIRED | 1 | decimal | The maximum resend period in seconds

The `period` field indicates the repeat interval. If an event is not received within this time period, the connection may be assumed to be lost.

### Example

An example Heartbeat.html event is indicated below.

````json
{
  "timestamp":"2021-05-19T10:24:58.614989800Z",
  "id":"sdkasldkals;610101498614",
  "event":{
    "context":[
      { "key":"period",
        "decimal": "10"
      }
    ],
    "hub.topic":"Topic1",
    "hub.event":"Heartbeat.html"
  }
}
````

### Change Log

{:.grid}
| Version | Description
| ---- | ----
| 1.0 | Initial Release
