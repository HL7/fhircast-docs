Subscribing and unsubscribing to a topic is how applications establish their connection and determine which events the Hub will distribute to them.

Subscribing consists of different exchanges:

[Subscription Request](#subscription-request) | Subscriber requests a subscription at the `hub.url` URL
[Subscription Response](#subscription-confirmation) | The Hub confirms that the subscription was requested by the Subscriber
[Subscription Confirmation](#subscription-confirmation) | The subscribing application confirms the subscription
[Subscription Denial](#subscription-denial) | The Hub indicates that the subscription has ended
[Unsubscribing](#unsubscribe) | Subscriber indicates that it wants to unsubscribe

Any content returned from subscription requests SHALL be returned as `application/json`.

### Subscription

#### Subscription Request

To create a subscription, the subscribing application SHALL perform an HTTP POST to the Hub's base URL (as specified in `hub.url`) with the parameters in the table below. Each parameter SHALL appear at most one time; parameters that accept multiple values use a comma-delimited syntax and explicitly state support in their description. This request SHALL have a `Content-Type` header of `application/x-www-form-urlencoded` and SHALL use the following parameters in its body, formatted accordingly:

{:.grid}
Field                  | Optionality | Type     | Description
---------------------- | ----------- | -------- | ------------
`hub.channel.type`     | Required    | *string* | The Subscriber SHALL specify the channel type of `websocket`. Subscription requests without this field SHOULD be rejected by the Hub.
`hub.mode`             | Required    | *string* | The literal string `subscribe` or `unsubscribe`, depending on the goal of the request.
`hub.topic`            | Required    | *string* | The identifier of the session that the Subscriber wishes to subscribe to or unsubscribe from. 
`hub.events`           | Conditional | *string* | A comma-separated list of event types for which the Subscriber wants to subscribe. SHALL be included for `subscribe` requests, SHALL NOT be present for `unsubscribe` requests. Partial unsubscribe requests are not supported and SHALL result in a full unsubscribe.
`hub.lease_seconds`    | Optional    | *number* | Number of seconds for which the Subscriber would like to have the subscription active, given as a positive decimal integer. Hubs MAY choose to respect this value or not, depending on their own policies, and MAY set a default value if the Subscriber omits the parameter. If using OAuth 2.0, the Hub SHALL limit the subscription lease seconds to be less than or equal to the access token's expiration.
`hub.channel.endpoint` | Conditional | *string* | The WSS URL identifying an existing WebSocket subscription.
`subscriber.name`      | Optional    | *string* | An optional description of the subscriber that will be used in `syncerror` notifications when an event is refused or cannot be delivered.

If OAuth 2.0 authentication is used, this POST request SHALL contain the Bearer access token in the HTTP Authorization header.

Hubs SHALL allow subscribers to re-request subscriptions that are already activated. Each subsequent and verified request to a Hub to subscribe or unsubscribe SHALL override the previous subscription state for a specific (`hub.topic`, `hub.callback`) combination or (`hub.topic`, `hub.channel.endpoint` url) combination. For example, a Subscriber MAY modify its subscription by sending a subscription request (`hub.mode=subscribe`) with a different `hub.events` value with the same topic and callback/endpoint url, in which case the Hub SHALL replace the subscription’s previous `hub.events` with the newly provided list of events.

The application that creates the subscription MAY NOT be the same system as the server connecting to the WSS URL (e.g., a federated authorization model could exist between these two systems). However, in FHIRcast, the Hub assumes that the same authorization and access rights apply to both the Subscriber and the system receiving notifications.

> NOTE
> The spec uses GET vs POST to differentiate between the confirmation/denial of the subscription request and delivering the content. While this is not considered "best practice" from a web architecture perspective, it does make implementation of the callback URL simpler. Since the POST body of the content distribution request may be any arbitrary content type and only includes the actual content of the document, using the GET vs POST distinction to switch between handling these two modes makes implementations simpler.

##### Initial Subscription Request Example

In this example, the subscribing application creates an initial subscription and asks to be notified of the `patient-open` and `patient-close` events.

```text
POST https://hub.example.com HTTP/1.1
Host: hub.example.com
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.channel.type=websocket&hub.mode=subscribe&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065&hub.events=patient-open,patient-close
```

#### Subscription Response

Upon receiving subscription or unsubscription requests, the Hub SHALL respond to a subscription request with an appropriate HTTP response.

If a Hub refuses the request or finds any errors in the subscription request, an appropriate HTTP error response code (4xx or 5xx) SHALL be returned. In the event of an error, the Hub SHOULD return a description of the error in the response body as plain text, to be used by the client developer to understand the error. This is not meant to be shown to the end user. Hubs MAY decide to reject some subscription requests based on their own policies, for example, a Hub may require that all applications subscribe to the same set of events.

In the case of an acceptable subscription requires, an HTTP 202 "Accepted" response is returned. This indicates that the request was received and will now be verified by the Hub. The HTTP body of the response SHALL consist of a JSON object containing an element name of `hub.channel.endpoint` and a value for the WSS URL. The WebSocket WSS URL SHALL be cryptographically random, unique, and unguessable.


##### Subscription Response Example

```text
HTTP/1.1 202 Accepted

{   
 "hub.channel.endpoint": "wss://hub.example.com/ee30d3b9-1558-464f-a299-cbad6f8135de"
}
```

#### Subscription Confirmation

To confirm a subscription request, upon the Subscriber establishing a WebSocket connection to the `hub.channel.endpoint` WSS URL, the Hub SHALL send a confirmation. This confirmation includes the following elements:

{:.grid}
Field               | Optionality | Type | Description
------------------- | ----------- | --- | ---
`hub.mode`          | Required    | *string* | The literal string `subscribe`.
`hub.topic`         | Required    | *string* | The session topic given in the corresponding subscription request.
`hub.events`        | Required    | *string* | A comma-separated list of events from the Event Catalog corresponding to the events string given in the corresponding subscription request. Note that the granted events may be the same as, a subset, or a superset of those requested.
`hub.lease_seconds` | Required    | *number* | The Hub-determined number of seconds that the subscription will stay active before expiring, measured from the time the verification request was made from the Hub to the Subscriber. If provided to the Subscriber, the Hub SHALL unsubscribe the Subscriber once `lease_seconds` has expired, close the WebSocket connection, and MAY send a subscription denial. If the Subscriber wishes to continue the subscription it MAY resubscribe.

Once the subscription is confirmed, the application is subscribed. 

##### Subscription Confirmation Example

```json
{
  "hub.mode": "subscribe",
  "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
  "hub.events": "patient-open,patient-close",
  "hub.lease_seconds": 7200
}
```

#### Successful Subscription Sequence

<figure>
  {% include SuccessfulWebSocketSubscriptionSequence.svg %}
  <figcaption><b>Figure: Successful WebSocket Subscription Sequence</b></figcaption>
</figure>

#### Current context notification upon successful subscription

> NOTE
 > Implementer feedback on this optional feature is required.

Upon the successful creation of a new subscription, the Subscriber will receive notifications for subsequent workflow steps, according to the `hub.events` specified in the subscription. Any previously established context is unknown to the newly subscribed application. To improve user experience, Hubs SHOULD follow a successful subscription with an event notification informing the new Subscriber of the most recent \*-open event per anchor type for which no \*-close event has occurred, according to the Subscriber's subscription.  Hubs that implement this feature, SHALL NOT send a Subscriber events to which it is not subscribed.

Although these event notifications are triggered by a successful subscription, they are indistinguishable from a normal, just-occurred workflow event triggered notification, as specified in [Event Notification](2-5-EventNotification.html). Note that the `timestamp` in the event notification is the time at which the event occurred and not the time at which the notification is generated.
  
### Subscription Denial

If (and when) a subscription is denied, the Hub SHALL inform the Subscriber. This can occur when a subscription is requested for a variety of reasons, or it can occur after a subscription had already been accepted because the Hub no longer supports that subscription (e.g. it has expired).

To deny a `WebSocket` subscription, the Hub sends a JSON object to the Subscriber through the established WebSocket connection holding the fields indicated below.

{:.grid}
Field        | Optionality | Type     | Description
------------ | ----------- | -------- | ---
`hub.mode`   | Required    | *string* | The literal string `denied`.
`hub.topic`  | Required    | *string* | The topic given in the corresponding subscription request. 
`hub.events` | Required    | *string* | A comma-separated list of events from the Event Catalog corresponding to the events string given in the corresponding subscription request, which are being denied.
`hub.reason` | Optional    | *string* | The Hub may include a reason. A subscription MAY be denied by the Hub at any point (even if it was previously accepted). The Subscriber SHOULD then consider that the subscription is not possible anymore.

#### Subscription Denial Sequence

<figure>
  {% include DeniedSubscriptionSequence.svg %}
  <figcaption><b>Figure: Denied Subscription Sequence</b></figcaption>
</figure>

#### `WebSocket` Subscription Denial Example

```json
{
   "hub.mode": "denied",
   "hub.topic": "fba7b1e2-53e9-40aa-883a-2af57ab4e2c",
   "hub.events": "patient-open,patient-close",
   "hub.reason": "session unexpectedly stopped"
}
```

### Unsubscribe

Once a Subscriber no longer wants to receive event notifications, it SHALL unsubscribe from the session. An unsubscribe cannot alter an existing subscription, only cancel it. Note that the unsubscribe request is performed over HTTP(s), even while subscriptions notifications use WebSockets. Unsubscribes will destroy the WebSocket which cannot be reused. A subsequent subscription SHALL be done over a newly created and communicated WebSocket endpoint.

#### Unsubscribe Request

To unsubscribe, the Subscriber SHALL perform an HTTP POST to the Hub's base URL (as specified in `hub.url`) with the parameters in the table below. Each parameter SHALL appear at most one time; parameters that accept multiple values use a comma-delimited syntax and explicitly state support in their description. This request SHALL have a `Content-Type` header of `application/x-www-form-urlencoded` and SHALL use the following parameters in its body, formatted accordingly:

{:.grid}
Field                  | Optionality | Type     | Description
---------------------- | ----------- | -------- | -----------
`hub.channel.type`     | Required    | *string* | The (un)subscriber SHALL specify a channel type of `websocket`. Subscription requests without this field SHOULD be rejected by the Hub.
`hub.mode`             | Required    | *string* | The literal string `unsubscribe`.
`hub.topic`            | Required    | *string* | The identifier of the session that the subscriber wishes to subscribe to or unsubscribe from.
`hub.channel.endpoint` | Required    | *string* | The WSS URL identifying an existing WebSocket subscription.

#### Unsubscribe Response

Upon receiving an unsubscribe request, if a Hub encounters any errors or refuses the request, it SHALL return an appropriate HTTP error response code (4xx or 5xx) along with a description of the error in the response body as plain text. This information is intended to be used by the client developer for troubleshooting and is not meant to be shown to the end user. Hubs may choose to reject unsubscribe requests based on their own policies.

When an unsubscribe request is accepted, the Hub SHALL respond with an HTTP 202 "Accepted" response. This indicates that the request has been received and will be processed by the Hub. The response SHALL include a JSON object in the body, containing the key hub.channel.endpoint with the WSS URL value of the WebSocket subscription. Additionally, the Hub SHALL send a Subscription Denial over the WebSocket.

#### Unsubscribe Request Example

```text
POST https://hub.example.com HTTP/1.1
Host: hub
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.channel.type=websocket&hub.channel.endpoint=wss%3A%2F%2Fhub.example.com%2Fee30d3b9-1558-464f-a299-cbad6f8135de%0A&hub.mode=unsubscribe&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065
```
#### Unsubscribe Response Example


```json
{   
 "hub.channel.endpoint": "wss://hub.example.com/ee30d3b9-1558-464f-a299-cbad6f8135de"
}
```

#### Unsubscription Sequence

 <figure>
  {% include UnsubscriptionSequence.svg %}
  <figcaption><b>Figure: Unsubscription sequence</b></figcaption>
</figure>
