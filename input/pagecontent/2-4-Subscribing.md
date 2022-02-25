Subscribing and unsubscribing is how applications establish their connection and determine which events they will be notified of. Hubs SHALL support WebSockets and MAY support webhooks. If the Hub does not support webhooks then they should deny any subscription requests with `webhook` as the channel type.

Subscribing consists of different exchanges:

[Subscription Request](#subscription-request) | Subscriber requests a subscription at the `hub.url` URL
[Subscription Response](#subscription-confirmation) | The hub confirms that the subscription was requested by the subscriber.
[Subscription Confirmation](#subscription-confirmation) | The client confirms the subscription
[Subscription Denial](#subscription-denial) | The hub indicates that the subscription has ended.
[Unsubscribing](#unsubscribe) | Subscriber indicates that it wants to unsubscribe.

These exchanges can be implemented in two ways depending on the channel type:

* For `webhook` subscriptions, the Hub confirms the subscription was actually requested by the subscriber by contacting the `hub.callback` URL.
* For `websocket` subscriptions, the Hub returns a wss URL and subscriber establishes WebSocket connection.

A Hub SHALL support WebSockets and MAY support webhooks subscriptions. A subscriber specifies the preferred `hub.channel.type` of either `webhook` or `websocket` during creation of its subscription. Websockets are particularly useful if a subscriber is unable to host an accessible callback URL.

> Implementer feedback is solicited around the optionality and possible deprecation of webhooks.

### Subscription Request

To create a subscription, the subscribing app SHALL perform an HTTP POST to the Hub's base URL (as specified in `hub.url`) with the parameters in the table below.

This request SHALL have a `Content-Type` header of `application/x-www-form-urlencoded` and SHALL use the following parameters in its body, formatted accordingly:

Field | Optionality | Channel | Type | Description
---------- | ----- | -------- | -------------- | ----------
`hub.channel.type` | Required | All | *string* | The subscriber SHALL specify a channel type of `websocket` or `webhook`. Subscription requests without this field SHOULD be rejected by the Hub.
`hub.mode` | Required | All | *string* | The literal string `subscribe` or `unsubscribe`, depending on the goal of the request.
`hub.topic` | Required | All | *string* | The identifier of the session that the subscriber wishes to subscribe to or unsubscribe from. MAY be a Universally Unique Identifier ([UUID](https://tools.ietf.org/html/rfc4122)).
`hub.events` | Conditional | All | *string* | Required for `subscribe` requests, SHALL NOT be present for `unsubscribe` requests. Comma-separated list of event types from the Event Catalog for which the Subscriber wants to subscribe. Partial unsubscribe requests are not supported and SHALL result in a full unsubscribe.
`hub.lease_seconds` | Optional | All | *number* | Number of seconds for which the subscriber would like to have the subscription active, given as a positive decimal integer. Hubs MAY choose to respect this value or not, depending on their own policies, and MAY set a default value if the subscriber omits the parameter. If using OAuth 2.0, the Hub SHALL limit the subscription lease seconds to be less than or equal to the access token's expiration.
`hub.callback` | Required | `webhook` | *string* | The Subscriber's callback URL where notifications should be delivered. The callback URL SHOULD be an unguessable URL that is unique per subscription.
`hub.secret` | Optional | `webhook` | *string* | A subscriber-provided cryptographically random unique secret string that SHALL be used to compute an [HMAC digest](https://www.w3.org/TR/websub/#bib-RFC6151) delivered in each notification. This parameter SHALL be less than 200 bytes in length.
`hub.channel.endpoint` | Conditional | `websocket` | *string* | Required when `hub.channel.type`=`websocket` for re-subscribes and unsubscribes. The WSS URL identifying an existing WebSocket subscription.
`subscriber.name` | Optional | All | *string* | An optional description of the subscriber that will be used in `syncerror` notifications when an event is refused or cannot be delivered.

If OAuth 2.0 authentication is used, this POST request SHALL contain the Bearer access token in the HTTP Authorization header.

Hubs SHALL allow subscribers to re-request subscriptions that are already activated. Each subsequent and verified request to a Hub to subscribe or unsubscribe SHALL override the previous subscription state for a specific `hub.topic`, `hub.callback` / `hub.channel.endpoint` url combination. For example, a subscriber MAY modify its subscription by sending a subscription request (`hub.mode=subscribe`) with a different `hub.events` value with the same topic and callback/endpoint url, in which case the Hub SHALL replace the subscription’s previous `hub.events` with the newly provided list of events.

For `webhook` subscriptions, the callback URL MAY contain arbitrary query string parameters (e.g., `?foo=bar&red=fish`). Hubs SHALL preserve the query string during subscription verification by appending new, Hub-defined, parameters to the end of the list using the `&` (ampersand) character to join. When sending event notifications, the Hub SHALL make a POST request to the callback URL including any query string parameters in the URL portion of the request, not as POST body parameters.

The client that creates the subscription MAY NOT be the same system as the server hosting the callback URL or connecting to the WSS URL (e.g., a federated authorization model could exist between these two systems). However, in FHIRcast, the Hub assumes that the same authorization and access rights apply to both the subscribing client and the system receiving notifications.

#### `websocket` Initial Subscription Request Example

In this example, the app creates an initial subscription and asks to be notified of the `patient-open` and `patient-close` events.

```text
POST https://hub.example.com
Host: hub.example.com
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.channel.type=websocket&hub.mode=subscribe&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065&hub.events=patient-open,patient-close
```

#### `webhook` Subscription Request Example

In this example, the app asks to be notified of the `patient-open` and `patient-close` events.

```text
POST https://hub.example.com
Host: hub.example.com
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.channel.type=webhook&hub.callback=https%3A%2F%2Fapp.example.com%2Fsession%2Fcallback%2Fv7tfwuk17a&hub.mode=subscribe&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065&hub.secret=shhh-this-is-a-secret&hub.events=patient-open,patient-close
```

### Subscription Response

Upon receiving subscription or unsubscription requests, the Hub SHALL respond to a subscription request with an HTTP 202 "Accepted" response. This indicates that the request was received and will now be verified by the Hub. When using WebSockets, the HTTP body of the response SHALL consist of a JSON object containing an element name of `hub.channel.endpoint` and a value of the WSS URL. The WebSocket WSS URL SHALL be cryptographically random, unique, and unguessable. If using webhooks, the Hub SHOULD perform verification of intent as soon as possible.

If a Hub refuses the request or finds any errors in the subscription request, an appropriate HTTP error response code (4xx or 5xx) SHALL be returned. In the event of an error, the Hub SHOULD return a description of the error in the response body as plain text, to be used by the client developer to understand the error. This is not meant to be shown to the end user. Hubs MAY decide to reject some subscription requests based on their own policies.

#### `websocket` Subscription Response Example

```text
HTTP/1.1 202 Accepted

{   
 "hub.channel.endpoint": wss://hub.example.com/ee30d3b9-1558-464f-a299-cbad6f8135de
}
```

#### `webhook` Subscription Response Example

```text
HTTP/1.1 202 Accepted
```

### Subscription Confirmation

If a subscribe or unsubscribe request is not denied, the Hub SHALL confirm the subscription. The subscription confirmation step informs the subscriber of the details of Hub's recently created subscription. For `webhook` subscriptions, the confirmation also verifies the intent of the subscriber and ensures that the subscriber actually controls the callback URL.

#### `webhook` Intent Verification Request

In order to prevent an attacker from creating unwanted subscriptions on behalf of a subscriber, a Hub must ensure that a `webhook` subscriber did indeed send the subscription request. The Hub SHALL verify a subscription request by sending an HTTPS GET request to the subscriber's callback URL as given in the subscription request. This request SHALL have the following query string arguments appended.

Field | Optionality | Type | Description
---  | --- | --- | ---
`hub.mode` | Required | *string* | The literal string `subscribe` or `unsubscribe`, which matches the original request to the Hub from the subscriber.
`hub.topic` | Required | *string* | The session topic given in the corresponding subscription request. MAY be a UUID.
`hub.events` | Required | *string* | A comma-separated list of events from the Event Catalog corresponding to the events string given in the corresponding subscription request.
`hub.challenge` | Required | *string* | A Hub-generated, random string that SHALL be echoed by the subscriber to verify the subscription.
`hub.lease_seconds` | Required | *number* | The Hub-determined number of seconds that the subscription will stay active before expiring, measured from the time the verification request was made from the Hub to the subscriber. If provided to the client, the Hub SHALL unsubscribe the client once `lease_seconds` has expired, close the websocket connection if used, and MAY send a subscription denial. If the subscriber wishes to continue the subscription it MAY resubscribe.

##### `webhook` Intent Verification Request Example

```text
GET https://app.example.com/session/callback/v7tfwuk17a?hub.mode=subscribe&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065&hub.events=patient-open,patient-close&hub.challenge=meu3we944ix80ox&hub.lease_seconds=7200 HTTP 1.1
Host: subscriber
```

#### `webhook` Intent Verification Response

If the `hub.topic` of the Intent Verification Request corresponds to a pending subscribe or unsubscribe request that the subscriber wishes to carry out it SHALL respond with an HTTP success (2xx) code, a header of `Content-Type: text/html`, and a response body equal to the `hub.challenge` parameter. If the subscriber does not agree with the action, the subscriber SHALL respond with a 404 "Not Found" response.

The Hub SHALL consider other server response codes (3xx, 4xx, 5xx) to mean that the verification request has failed. If the subscriber returns an HTTP success (2xx) but the content body does not match the `hub.challenge` parameter, the Hub SHALL consider verification to have failed.

The below flow diagram and example illustrate the successful subscription sequence and message details.

##### `webhook` Successful Subscription Sequence

{% include img.html img="Successful Subscription Sequence.png" caption="Figure: Successful subscription sequence" %}

##### `webhook` Intent Verification Response Example

```text
HTTP/1.1 200 OK
Content-Type: text/html

meu3we944ix80ox
```

> NOTE
> The spec uses GET vs POST to differentiate between the confirmation/denial of the subscription request and delivering the content. While this is not considered "best practice" from a web architecture perspective, it does make implementation of the callback URL simpler. Since the POST body of the content distribution request may be any arbitrary content type and only includes the actual content of the document, using the GET vs POST distinction to switch between handling these two modes makes implementations simpler.

#### `websocket` Subscription Confirmation

To confirm a subscription request, upon the subscriber establishing a WebSocket connection to the `hub.channel.endpoint` WSS URL, the Hub SHALL send a confirmation. This confirmation includes the following elements:

Field | Optionality | Type | Description
---  | --- | --- | ---
`hub.mode` | Required | *string* | The literal string `subscribe`.
`hub.topic` | Required | *string* | The session topic given in the corresponding subscription request.
`hub.events` | Required | *string* | A comma-separated list of events from the Event Catalog corresponding to the events string given in the corresponding subscription request.
`hub.lease_seconds` | Required | *number* | The Hub-determined number of seconds that the subscription will stay active before expiring, measured from the time the verification request was made from the Hub to the subscriber. If provided to the client, the Hub SHALL unsubscribe the client once `lease_seconds` has expired, close the websocket connection if used, and MAY send a subscription denial. If the subscriber wishes to continue the subscription it MAY resubscribe.

##### `websocket` Subscription Confirmation Example

```json
{
  "hub.mode": "subscribe",
  "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
  "hub.events": "patient-open,patient-close",
  "hub.lease_seconds": 7200
}
```

##### `websocket` Successful Subscription Sequence

{% include img.html img="Successful WebSocket Subscription Sequence.png" caption="Figure: Successful web socket subscription flow diagram" %}

### Current context notification upon successful subscription

> NOTE
 > Implementer feedback on this optional feature is required.

Upon the successful creation of a new subscription, the subscribing application will receive notifications for subsequent workflow steps, according to the `hub.events` specified in the subscription. Any previously established context is unknown to the newly subscribed application. To improve user experience, Hubs SHOULD follow a successful subscription with an event notification informing the newly subscribed application of the most recent \*-open event for which no \*-close event has occurred, according to the app's subscription.  Hubs that implement this feature, SHALL NOT send an app events to which it is not subscribed.

 Although these event notifications are triggered by a successful subscription, they are indistinguishable from a normal, just-occurred workflow event triggered notification, as specified in Event Notification](#event-notification). Note that the `timestamp` in the event notification is the time at which the event occurred and not at which the notification is generated.
  
### Subscription Denial

If (and when) a subscription is denied, the Hub SHALL inform the subscriber. This can occur when a subscription is requested for a variety of reasons, or it can occur after a subscription had already been accepted because the Hub no longer supports that subscription (e.g. it has expired). The communication mechanism for a subscription denial varies per `hub.channel.type`, but the information communicated from the Hub to the subscriber does not.

Field | Optionality | Type | Description
--- | --- | --- | ---
`hub.mode` | Required | *string* | The literal string `denied`.
`hub.topic` | Required | *string* | The topic given in the corresponding subscription request. MAY be a UUID.
`hub.events` | Required | *string* | A comma-separated list of events from the Event Catalog corresponding to the events string given in the corresponding subscription request, which are being denied.
`hub.reason` | Optional | *string* | The Hub may include a reason. A subscription MAY be denied by the Hub at any point (even if it was previously accepted). The Subscriber SHOULD then consider that the subscription is not possible anymore.

The below webhook flow diagram and WebSocket flow diagram and examples illustrate the subscription denial sequence and message details.

#### `webhook` Subscription Denial

To deny a `webhook` subscription, the Hub sends an HTTP GET request to the subscriber's callback URL as given in the subscription request.  This request appends the fields as query string arguments. The subscriber SHALL respond with an HTTP success (2xx) code.

##### `webhook` Subscription Denial Sequence

{% include img.html img="Denied Webhook Subscription Sequence.png" caption="Figure: Webhook subscription denial" %}

##### `webhook` Subscription Denial Example

```text
GET https://app.example.com/session/callback/v7tfwuk17a?hub.mode=denied&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065hub.events=patient-open,patient-close&hub.reason=session+unexpectedly+stopped HTTP 1.1
Host: subscriber
```

#### `websocket` Subscription Denial

To deny a `websocket` subscription, the Hub sends a JSON object to the subscriber through the established WebSocket connection.

##### `websocket`Subscription Denial Sequence

{% include img.html img="Denied Websocket Subscription Sequence.png" caption="Figure: Websocket subscription denial" %}

##### `websocket` Subscription Denial Example

```json
{
   "hub.mode": "denied",
   "hub.topic": "fba7b1e2-53e9-40aa-883a-2af57ab4e2c",
   "hub.events": "patient-open,patient-close",
   "hub.reason": "session unexpectedly stopped"
}
```

### Unsubscribe

Once a subscribing app no longer wants to receive event notifications, it SHALL unsubscribe from the session. An unsubscribe cannot alter an existing subscription, only cancel it. Note that the unsubscribe request is performed over HTTP(s), even for subscriptions using WebSockets. `websocket` unsubscribes will destroy the websocket which cannot be reused. A subsequent subscription SHALL be done over a newly created and communicated WebSocket endpoint.

Field | Optionality | Channel | Type | Description
----- | ----------- | ------- | ---- | -----------
`hub.channel.type` | Required | All | *string* | The subscriber SHALL specify a channel type of `websocket` or `webhook`. Subscription requests without this field SHOULD be rejected by the Hub.
`hub.mode` | Required | All | *string* | The literal string `unsubscribe`.
`hub.topic` | Required | All | *string* | The identifier of the session that the subscriber wishes to subscribe to or unsubscribe from. MAY be a UUID.
`hub.lease_seconds` | Optional | All | *number* | This parameter MAY be present for unsubscribe requests and MUST be ignored by the hub in that case.
`hub.callback` | Required | `webhook` | *string* | The Subscriber's callback URL. 
`hub.secret` | Optional | `webhook` | *string* | A subscriber-provided cryptographically random unique secret string that SHALL be used to compute an [HMAC digest](https://www.w3.org/TR/websub/#bib-RFC6151) delivered in each notification. This parameter SHALL be less than 200 bytes in length.
`hub.channel.endpoint` | Conditional | `websocket` | *string* |  Required for `websocket` re-subscribes and unsubscribes. The WSS URL identifying an existing WebSocket subscription.

#### `webhook` Unsubscribe Request Example

```text
POST https://hub.example.com
Host: hub
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.channel.type=webhook&hub.callback=https%3A%2F%2Fapp.example.com%2Fsession%2Fcallback%2Fv7tfwuk17a&hub.mode=unsubscribe&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065&hub.secret=shhh-this-is-a-secret&hub.challenge=meu3we944ix80ox
```

#### `websocket` Unsubscribe Request Example

```text
POST https://hub.example.com
Host: hub
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.channel.type=websocket&hub.channel.endpoint=wss%3A%2F%2Fhub.example.com%2Fee30d3b9-1558-464f-a299-cbad6f8135de%0A&hub.mode=unsubscribe&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065
```

#### `webhook` and `websocket` Unsubscription Sequence

{% include img.html img="UnsubscriptionSequence.png" caption="Figure: Unsubscription flow diagram" %}
