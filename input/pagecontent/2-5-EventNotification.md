The Hub SHALL notify Subscribers of workflow-related events to which the Subscriber is subscribed. The notification is a JSON object communicated over the `WebSocket` channel.

### Event Notification

The event notification interaction include the following fields:

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
		"hub.event": "Patient-open",
		"context": [{
			"key": "patient",
			"resource": {
				"resourceType": "Patient",
				"id": "ewUbXT9RWEbSj5wPEdgRaBw3",
				"identifier": [{
					"type": {
						"coding": [{
							"system": "http://terminology.hl7.org/CodeSystem/v2-0203",
							"value": "MR",
							"display": "Medication Record Number"
						}]
					}
				}]
			}
		}]
	}
}
```

### Event Notification Response

The Subscriber SHALL respond to the event notification with an appropriate HTTP status code. In the case of a successful notification, the Subscriber SHALL respond with any of the response codes indicated below:

{:.grid}
Code  |          | Description
----- | -------- | ---
200   | OK       | The Subscriber is able to implement the context change.
202   | Accepted | The Subscriber has successfully received the event notification, but has not yet taken action. If the Subscriber decides to refuse the event, it will send a [`SyncError`](3-2-1-SyncError.html) event. Subscribers are RECOMMENDED to do so within 10 seconds after receiving the context event.
409   | Conflict | The Subscriber refuses to follow the context change. The Hub SHALL send a [`SyncError`](3-2-1-SyncError.html) indicating the event was refused.
4xx   | Other Client Error | For Subscriber errors other than a 409; Subscribers can return other appropriate 4xx HTTP statuses. The Hub SHALL send a [`SyncError`](3-2-1-SyncError.html) indicating the event was refused.
500   | Server Error | There is an issue in the Subscriber preventing it from processing the event. The Hub SHALL send a [`SyncError`](3-2-1-SyncError.html) indicating the event was not delivered.
5xx   | Other Server Error | If the Subscriber is able to more specifically identify the server error preventing it from processing the event, it can send a 5xx status other than 500. The Hub SHALL send a [`SyncError`](3-2-1-SyncError.html) indicating the event was not delivered.

The Hub MAY use these statuses to track synchronization state.

#### Event Notification Response Example

The `id` of the event notification and the HTTP status code is communicated from the Subscriber to Hub through the existing WebSocket channel, wrapped in a JSON object. Since the WebSocket channel does not have a synchronous request/response, this `id` is necessary for the Hub to correlate the response to the correct notification.

{:.grid}
Field    | Optionality | Type     | Description
-------- | ----------- | -------- | ---
`id`     | Required    | *string* | Event identifier from the event notification to which this response corresponds.
`status` | Required    | *numeric HTTP status code* | Numeric HTTP response code to indicate success or failure of the event notification within the Subscriber. Any 2xx code indicates success, any other code indicates failure.

```json
{
  "id": "q9v3jubddqt63n1",
  "status": "200"
}
```

### Event Notification Sequence

<figure>
  {% include EventNotificationSequence.svg %}
  <figcaption><b>Figure: Event Notification Sequence</b></figcaption>
  <p></p>
</figure>

### Event Notification Errors

If the Subscriber cannot follow the context of the event, for instance due to an error or a deliberate choice to not follow a context, the Subscriber SHALL communicate the error to the Hub in one of two ways.

* Responding to the event notification with an HTTP error status code as described in [Event Notification Response](#event-notification-response).
* Responding to the event notification with an HTTP 202 (Accepted) as described above, then, once experiencing the error or refusing the change, send a [`SyncError`](3-2-1-SyncError.html) event to the Hub. If the Subscriber cannot determine whether it will follow context within 10 seconds after reception of the event it SHOULD send a [`SyncError`](3-2-1-SyncError.html) event.

If the Hub receives an error notification from a Subscriber, it SHALL generate a [`SyncError`](3-2-1-SyncError.html) event to the other Subscribers of that topic. [`SyncError`](3-2-1-SyncError.html) events are like other events in that they need to be subscribed to in order for a Subscriber to receive the notifications and they have the same structure as other events, the context being a single FHIR `OperationOutcome` resource.

The figure below illustrates the Event Notification Error Sequence.

<figure>
  {% include EventNotificationErrorSequence.svg %}
  <figcaption><b>Figure: Event Notification Error Sequence</b></figcaption>
  <p></p>
</figure>

More information on the source of notification errors and how to resolve them can be found in [Synchronization Considerations](4-2-syncconsiderations.html).

### Hub Generated `SyncError` Events

In addition to distributing [`SyncError`](3-2-1-SyncError.html) events sent by one Subscriber to other Subscribers, the Hub MAY generate and communicate [`SyncError`](3-2-1-SyncError.html) events to Subscribers under the following conditions: 

1. A Subscriber's WebSocket connection is closed with any Connection Close Reason other than 1000 (normal closure) or 1001 (going away) (see [WebSocket RFC](https://www.rfc-editor.org/rfc/rfc6455.html#section-7.1.6) and [WebSocket Status Codes](https://www.rfc-editor.org/rfc/rfc6455.html#section-7.4))

2. A Subscriber does not respond to a FHIRcast event within 10 seconds or an order of magnitude lower than the subscription time-out.

{% include questionnote.html text='Implementer input is solicited on the amount and specificity of time, in the above.' %}

 As with all FHIRcast events, [`SyncError`](3-2-1-SyncError.html) events are distributed only to Subscribers which have subscribed to them.

Upon communicating a `SyncError` resulting from an unresponsive Subscriber, the Hub SHALL unsubscribe the Subscriber.

The Hub SHALL NOT generate [`SyncError`](3-2-1-SyncError.html) events in the following situations:

1. A Subscriber closes its WebSocket connection to the Hub with a [Connection Close Reason](https://www.rfc-editor.org/rfc/rfc6455.html#section-7.4.1) of 1000 (normal closure) or 1001 (going away).  

During a normal shutdown of a Subscriber, it SHALL unsubscribe, and provide a WebSocket Connection Close Reason of 1000 and not rely upon the Hub recognizing and unsubscribing it as an unresponsive Subscriber.

{% include questionnote.html text='Implementer feedback is solicited on Hub Generated `SyncError` Events particularly on the following topics:' %}

> * after the first time a Hub has distributed a [`SyncError`](3-2-1-SyncError.html) indicating that a Subscriber is not responsive, should the nonresponsive Subscriber be automatically unsubscribed (removed from the Hub's list of Subscribers of the topic)?  This would avoid [`SyncError`](3-2-1-SyncError.html) events being sent after subsequent operations; however, it may conflict with the approach of [`SyncError`](3-2-1-SyncError.html) events generated by the Hub only being distributed to Subscribers of the event which triggered the [`SyncError`](3-2-1-SyncError.html) event to be generated.
>* should [`SyncError`](3-2-1-SyncError.html) events generated by the Hub be distributed only to Subscribers of the event which triggered the [`SyncError`](3-2-1-SyncError.html) event to be generated?  However, this could conflict with automatically unsubscribing a non-responsive Subscriber after the initial [`SyncError`](3-2-1-SyncError.html) is generated and distributed.
>* should all FHIRcast requests trigger  [`SyncError`](3-2-1-SyncError.html) events to be generated by the Hub for an unresponsive Subscriber or only when a context change is requested ([FHIR Resource]-open or [FHIR Resource]-close)?

### Hub Generated `open` Events

{% include questionnote.html text='This capability is experimental.' %}


If a Hub grants subscriptions to different sets of `hub.events` to different Subscribers for the same session, the Hub is responsible for generation of implied open events. Close events are typically not generated by the Hub.  When distributing a received event, a Hub SHALL ensure open events for the referenced resource types of the received event are also sent to subscribers. Hubs SHOULD either support derived events or require that Subscribers are subscribed to the same context. Hubs SHOULD NOT generate and send duplicative events.
