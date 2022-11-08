The Hub SHALL notify subscribed apps of workflow-related events to which the app is subscribed. The notification is a JSON object communicated over the `websocket` channel.

### Event Notification Request

The HTTP request notification interaction include the following fields:

{:.grid}
Field       | Optionality | Type | Description
----------- | ----------- | ---- | ------------
`timestamp` | Required    | *string* | ISO 8601-2 timestamp in UTC describing the time at which the event occurred.
`id`        | Required    | *string* | Event identifier used to recognize retried notifications. This id SHALL be unique for the Hub, for example a UUID.
`event`     | Required    | *object* | A JSON object describing the event see [Event Definition](2-3-Events.html).

The timestamp SHOULD be used by subscribers to establish message affinity (message ordering) through the use of a message queue. Subscribers SHALL ignore messages with older timestamps than the message that established the current context. The event identifier MAY be used to differentiate retried messages from user actions.

#### Event Notification Request Example

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "patient-open",
    "context": [
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "ewUbXT9RWEbSj5wPEdgRaBw3",
          "identifier": [
             {
               "type": {
                    "coding": [
                        {
                            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
                            "value": "MR",
                            "display": "Medication Record Number"
                         }
                        "text": "MRN"
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

### Event Notification Response

The subscriber SHALL respond to the event notification with an appropriate HTTP status code. In the case of a successful notification, the subscriber SHALL respond with any of the response codes indicated below:
HTTP 200 (OK) or 202 (Accepted) response code to indicate a success; otherwise, the subscriber SHALL respond with an HTTP error status code.

{:.grid}
Code  |          | Description
----- | -------- | ---
200   | OK       | The subscriber is able to implement the context change.
202   | Accepted | The subscriber has successfully received the event notification, but has not yet taken action. If it decides to refuse the event, it will send a [`syncerror`](3-2-1-syncerror.html) event. Clients are RECOMMENDED to do so within 10 seconds after receiving the context event.
500   | Server Error | There is an issue in the client preventing it from processing the event. The hub SHALL send a [`syncerror`](3-2-1-syncerror.html) indicating the event was not delivered.
409   | Conflict | The client refuses to follow the context change. The hub SHALL send a [`syncerror`](3-2-1-syncerror.html) indicating the event was refused.

The Hub MAY use these statuses to track synchronization state.

#### Event Notification Response Example

The `id` of the event notification and the HTTP status code is communicated from the client to Hub through the existing WebSocket channel, wrapped in a JSON object. Since the WebSocket channel does not have a synchronous request/response, this `id` is necessary for the Hub to correlate the response to the correct notification.

{:.grid}
Field    | Optionality | Type     | Description
-------- | ----------- | -------- | ---
`id`     | Required    | *string* | Event identifier from the event notification to which this response corresponds.
`status` | Required    | *numeric HTTP status code* | Numeric HTTP response code to indicate success or failure of the event notification within the subscribing app. Any 2xx code indicates success, any other code indicates failure.

```text
{
  "id": "q9v3jubddqt63n1",
  "status": "200"
}
```

### Event Notification Sequence

{%include EventNotificationSequence.svg%}

### Event Notification Errors

If the subscriber cannot follow the context of the event, for instance due to an error or a deliberate choice to not follow a context, the subscriber SHALL communicate the error to the Hub in one of two ways.

* Responding to the event notification with an HTTP error status code as described in [Event Notification Response](#event-notification-response).
* Responding to the event notification with an HTTP 202 (Accepted) as described above, then, once experiencing the error or refusing the change, send a [`syncerror`](3-2-1-syncerror.html) event to the Hub. If the application cannot determine whether it will follow context within 10 seconds after reception of the event it SHOULD send a [`syncerror`](3-2-1-syncerror.html) event.

If the Hub receives an error notification from a subscriber, it SHALL generate a [`syncerror`](3-2-1-syncerror.html) event to the other subscribers of that topic. [`syncerror`](3-2-1-syncerror.html) events are like other events in that they need to be subscribed to in order for an app to receive the notifications and they have the same structure as other events, the context being a single FHIR `OperationOutcome` resource.

The figure below illustrates the Event Notification Error Sequence.

{%include EventNotificationErrorSequence.svg%}

More information on the source of notification errors and how to resolve them can be found in [Synchronization Considerations](4-2-syncconsiderations.html).

### Hub Generated `syncerror` Events

In addition to distributing [`syncerror`](3-2-1-syncerror.html) events sent by one application to other subscribed applications, the Hub MAY generate and communicate [`syncerror`](3-2-1-syncerror.html) events to applications under the following conditions -- 

1. A subscribed application's WebSocket connection is closed with any Connection Close Reason other than 1000 (normal closure) or 1001 (going away) (see [WebSocket RFC](https://www.rfc-editor.org/rfc/rfc6455.html#section-7.1.6) and [WebSocket Status Codes](https://www.rfc-editor.org/rfc/rfc6455.html#section-7.4))

2. And, the subscribed application, does not respond to a FHIRcast event within 10 seconds or an order of magnitude lower than the subscription time-out.

> Implementer input is solicited on the amount and specificity of time, in the above.

[`syncerror`](3-2-1-syncerror.html) events are distributed only to applications which have subscribed to `syncerror`s.

Upon communicating a `syncerror` resulting from an unresponsive app, the Hub SHALL unsubscribe the application.

The Hub SHALL NOT generate [`syncerror`](3-2-1-syncerror.html) events in the following situations:

1. If a client fails to respond to a [`heartbeat`](3-2-2-heartbeat.html) event (because occasional missed heartbearts are expected and are not a context synchronization failure).
2. The application closes its WebSocket connection to the Hub with a [Connection Close Reason](https://www.rfc-editor.org/rfc/rfc6455.html#section-7.4.1) of 1000 (normal closure) or 1001 (going away).  

During a normal shutdown of an application, it SHALL unsubscribe, and provide a WebSocket Connection Close Reason of 1000 and not rely upon the Hub recognizing and unsubscribing it as an unresponsive app.

> <u>Implementer feedback is solicited on Hub Generated `syncerror` Events particularly on the following topics:</u>
>
> * after the first time a Hub has distributed a [`syncerror`](3-2-1-syncerror.html) indicating that an application is not responsive, should the nonresponsive application be automatically unsubscribed (removed from the Hub's list of applications subscribed to the topic)?  This would avoid [`syncerror`](3-2-1-syncerror.html) events being sent after subsequent operations; however, it may conflict with the approach of [`syncerror`](3-2-1-syncerror.html) events generated by the Hub only being distributed to subscribers of the event which triggered the [`syncerror`](3-2-1-syncerror.html) event to be generated.
>* should [`syncerror`](3-2-1-syncerror.html) events generated by the Hub be distributed only to subscribers of the event which triggered the [`syncerror`](3-2-1-syncerror.html) event to be generated?  However, this could conflict automatically unsubscribe a non-responsive application after the initial [`syncerror`](3-2-1-syncerror.html) is generated and distributed.
>* should all FHIRcast requests trigger  [`syncerror`](3-2-1-syncerror.html) events to be generated by the Hub for an unresponsive application or only when a context change is requested ([FHIR Resource]-open or [FHIR Resource]-close)?

### Hub Generated `open` Events

If a Hub grants subscriptions to different sets of `hub.events` to different applications for the same session, the Hub is responsible for generation of implied open events. When distributing a received event, a hub SHALL ensure open events for the referenced resource types of the received event are also sent to subscribers. Hubs SHOULD NOT generate and send duplicative events.
