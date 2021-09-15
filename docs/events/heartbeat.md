!!! important Implementator feedback is requested for the need to support heartbeats for websockets.


### Heartbeat event
The heartbeat event is sent regularly to indicate a channel is open.

The name of the event is: heartbeat



#### Workflow
This event SHALL be send at least every 10 second. or an order of magnitude lower than the subscription time-out.

#### Context
The context of the -monitor event described in the table below.

| Key       | Optionality   | #   | type      | *Description*       |
|-----------|:--------------|-----|-----------|---------------------|
| `period` | REQUIRED      | 1   | decimal   | The resend period in seconds |

The first field indicates the repeat interval. If an event is not received within this time period, the connection may be assumed to be lost.

## Example
An example heartbeat event is indicated below.
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
    "hub.event":"heartbeat"
  }
}
