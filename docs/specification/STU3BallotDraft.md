<img style="float: left;padding-right: 5px;" src="../img/hl7-logo-header-good-resolution.png" width=20%" />
# FHIRcast

!!! important Draft "Standard for Trial Use" (STU3) This is the draft of the 1.2 release of the FHIRcast specification. We are currently working towards a 1.2 release and would love your feedback and proposed changes. Look at our current issue list and get involved!
										      
## Overview
The FHIRcast specification describes the APIs used to synchronize disparate healthcare applications' user interfaces in real time,  allowing them to show the same clinical content to a user (or group of users). 

Once the subscribing app [knows about the session](#session-discovery), the app [subscribes](#subscribing-and-unsubscribing) to specific workflow-related events for the given session. The app is then [notified](#event-notification) when those workflow-related events occur; for example, when the clinician opens a patient's chart. The subscribing app can also [initiate context changes](#request-context-change) by accessing APIs defined in this specification; for example, closing the patient's chart. The app [deletes its subscription](#unsubscribe) to no longer receive notifications. The notification messages describing the workflow event are defined as a simple JSON wrapper around one or more FHIR resources. 

FHIRcast recommends the [HL7 SMART on FHIR launch protocol](http://www.hl7.org/fhir/smart-app-launch) for both session discovery and API authentication. FHIRcast enables a subscriber to receive notifications either through a webhook or over a WebSocket connection. This protocol is modeled on the [W3C WebSub RFC](https://www.w3.org/TR/websub/), such as its use of GET vs POST interactions and a Hub for managing subscriptions. The Hub exposes APIs for subscribing and unsubscribing, requesting context changes, and distributing event notifications. The flow diagram presented below illustrates the series of interactions specified by FHIRcast, their origination and their outcome.

![FHIRcast flow diagram overview](../img/FHIRcast%20overview%20for%20abstract.png)

All data exchanged through the HTTP APIs SHALL be formatted, sent and received as [JSON](https://tools.ietf.org/html/rfc8259) structures, and SHALL be transmitted over channels secured using the Hypertext Transfer Protocol (HTTP) over Transport Layer Security (TLS), also known as HTTPS which is defined in [RFC2818](https://tools.ietf.org/html/rfc2818).

All data exchanged through WebSockets SHALL be formatted, sent and received as [JSON](https://tools.ietf.org/html/rfc8259) structures, and SHALL be transmitted over Secure Web Sockets (WSS) as defined in [RFC6455](https://tools.ietf.org/html/rfc6455).

## Events

FHIRcast describes a workflow event subscription and notification scheme with the goal of improving a clinician's workflow across multiple disparate applications. The set of events defined in this specification is not a closed set; anyone is able to define new events to fit specific use cases and are encouraged to propose those events to the community for standardization. 

New events are proposed in a prescribed format using the [documentation template](../../events/template) by submitting a [pull request](https://github.com/fhircast/docs/tree/master/docs/events). FHIRcast events are versioned, and mature according to the [Event Maturity Model](#event-maturity-model).

FHIRcast events do not communicate previous state. For a given event, opens and closes are complete replacements of previous communicated events, not "deltas". Understanding an event SHALL not require receiving a previous or future event. 

### Event Definition Format

Each event definition: specifies a single event name, a description of the workflow in which the event occurs, and contextual information associated with the event. FHIR is the interoperable data model used by FHIRcast. The context information associated with an event is communicated as subsets of FHIR resources. Event notifications SHALL include the elements of the FHIR resources defined in the context from the event definition. Event notifications MAY include other elements of these resources.

For example, when the [`ImagingStudy-open`](../../events/imagingstudy-open) event occurs, the notification sent to a subscriber SHALL include an ImagingStudy FHIR resource, which includes at least the elements defined in the *_elements* query parameter, as indicated in the event's definition. For ImagingStudy, this is defined as: `ImagingStudy/{id}?_elements=identifier,accession`. (The *_elements* query parameter is defined in the [FHIR specification](https://www.hl7.org/fhir/search.html#elements)). 

A Hub SHALL at least send the required elements; a subscriber SHALL gracefully handle receiving a full FHIR resource in the context of a notification.

Each defined event in the standard event catalog SHALL be defined in the following format.

#### Event Definition Format: hook-name

Most FHIRcast events conform to an extensible syntax based upon FHIR resources. In the rare case where the FHIR data model doesn't describe content in the session, FHIRcast events MAY be named differently. For example, FHIR doesn't cleanly contain the concept of a user or user's session.  

Patterned after the SMART on FHIR scope syntax and expressed in EBNF notation, the FHIRcast syntax for workflow related events is:

`hub.events ::= ( fhir-resource | '*' ) '-' ( 'open' | 'close' | '*' )`

![syntax for new events](../img/events-railroad.png)

FHIRcast events SHOULD conform to this extensible syntax.

Event names are unique and case-insensitive. Implementers may define their own events. Such proprietary events SHALL be named with reverse domain notation (e.g. `org.example.patient_transmogrify`). Reverse domain notation SHALL NOT be used by a standard event catalog. Proprietary events SHALL NOT contain a dash ("-").

#### Event Definition Format: Workflow

Describe the workflow in which the event occurs. Event creators SHOULD include as much detail and clarity as possible to minimize any ambiguity or confusion amongst implementers.

#### Event Definition Format: Context

Describe the set of contextual data associated with this event. Only data logically and necessarily associated with the purpose of this workflow related event should be represented in context. An event SHALL contain all required data fields, MAY contain optional data fields and SHALL NOT contain any additional fields.
 
All fields available within an event's context SHALL be defined in a table where each field is described by the following attributes:

- **Key**: The name of the field in the context JSON object. Event authors SHOULD name their context fields to be consistent with other existing events when referring to the same context field.
- **Optionality**: A string value of either `Required`, `Optional` or `Conditional`
- **FHIR operation to generate context**: A FHIR read or search string illustrating the intended content of the event. 
- **Description**: A functional description of the context value. If this value can change according to the FHIR version in use, the description SHOULD describe the value for each supported FHIR version.

## Session Discovery

A session is an abstract concept representing a shared workspace, such as user's login session over multiple applications or a shared view of one application distributed to multiple users. FHIRcast requires a session to have a unique, unguessable, and opaque identifier. This identifier is exchanged as the value of the `hub.topic` parameter. Before establishing a subscription, an app must not only know the `hub.topic`, but also the `hub.url` which contains the base URL of the Hub. 

Systems SHOULD use SMART on FHIR to authorize, authenticate, and exchange initial shared context. If using SMART, following a [SMART on FHIR EHR launch](http://www.hl7.org/fhir/smart-app-launch#ehr-launch-sequence) or [SMART on FHIR standalone launch](http://www.hl7.org/fhir/smart-app-launch/#standalone-launch-sequence), the app SHALL request and, if authorized, SHALL be granted one or more FHIRcast OAuth 2.0 scopes. Accompanying this scope grant, the authorization server SHALL supply the `hub.url` and `hub.topic` SMART launch parameters alongside the access token and other parameters appropriate to establish initial shared context. Per SMART, when the `openid` scope is granted, the authorization server additionally sends the current user's identity in an `id_token`.

Although FHIRcast works best with the SMART on FHIR launch and authorization process, implementation-specific launch, authentication, and authorization protocols may be possible. If not using SMART on FHIR, the mechanism enabling the app to discover the `hub.url` and `hub.topic` is not defined in FHIRcast. See [other launch scenarios](/launch-scenarios) for guidance.

### FHIRcast Authorization & SMART scopes

FHIRcast defines OAuth 2.0 access scopes that correspond directly to [FHIRcast events](#events). Our scopes associate read or write permissions to an event. Apps that need to receive workflow related events SHOULD ask for `read` scopes. Apps that request context changes SHOULD ask for `write` scopes. Hubs may decide what specific interactions and operations will be enabled by these scopes.

Expressed in [Extended Backus-Naur Form](https://www.iso.org/obp/ui/#iso:std:iso-iec:14977:ed-1:v1:en) (EBNF) notation, the FHIRcast syntax for OAuth 2.0 access scopes is:

`scope ::= ( 'fhircast' ) '/' ( FHIRcast-event | '*' ) '.' ( 'read' | 'write' | '*' )`

![FHIRcast SMART scopes](../img/fhircast-smart-scopes.png)

For example, a requested scope of `fhircast/patient-open.read` would authorize the subscribing application to receive a notification when the patient in context changed. Similarly, a scope of  `fhircast/patient-open.write` authorizes the subscribed app to [request a context change](#request-context-change).

### SMART Launch Example
 An example of the launch parameters presented to the app during a SMART on FHIR launch is presented below. 

```
{
  "access_token": "i8hweunweunweofiwweoijewiwe",
  "token_type": "bearer",
  "patient":  "123",
  "expires_in": 3600,
  "encounter": "456",
  "imagingstudy": "789",
  "hub.url" : "https://hub.example.com",
  "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
}
```

Note that the SMART launch parameters include the Hub's base URL and the session identifier in the `hub.url` and `hub.topic` fields.

## Subscribing and Unsubscribing
 
Subscribing and unsubscribing is how applications establish their connection and determine which events they will be notified of. Hubs SHALL support WebSockets and MAY support webhooks. If the Hub does not support webhooks then they should deny any subscription requests with `webhook` as the channel type.

Subscribing consists of two exchanges:

* Subscriber requests a subscription at the `hub.url` URL.
* The hub confirms that the subscription was requested by the subscriber. This exchange can be implemented in two ways depending on the channel type:
  * For `webhook` subscriptions, the Hub confirms the subscription was actually requested by the subscriber by contacting the `hub.callback` URL. 
  * For `websocket` subscriptions, the Hub returns a wss URL and subscriber establishes WebSocket connection. 

Unsubscribing works in the same way, using the same message format. The `hub.mode` parameter is set to a value of `unsubscribe`, instead of `subscribe`. The Hub SHALL NOT validate unsubscribe requests with the subscriber.

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

If OAuth 2.0 authentication is used, this POST request SHALL contain the Bearer access token in the HTTP Authorization header.

Hubs SHALL allow subscribers to re-request subscriptions that are already activated. Each subsequent and verified request to a Hub to subscribe or unsubscribe SHALL override the previous subscription state for a specific `hub.topic`, `hub.callback` / `hub.channel.endpoint` url combination. For example, a subscriber MAY modify its subscription by sending a subscription request (`hub.mode=subscribe`) with a different `hub.events` value with the same topic and callback/endpoint url, in which case the Hub SHALL replace the subscription’s previous `hub.events` with the newly provided list of events.

For `webhook` subscriptions, the callback URL MAY contain arbitrary query string parameters (e.g., `?foo=bar&red=fish`). Hubs SHALL preserve the query string during subscription verification by appending new, Hub-defined, parameters to the end of the list using the `&` (ampersand) character to join. When sending event notifications, the Hub SHALL make a POST request to the callback URL including any query string parameters in the URL portion of the request, not as POST body parameters.

The client that creates the subscription MAY NOT be the same system as the server hosting the callback URL or connecting to the WSS URL (e.g., a federated authorization model could exist between these two systems). However, in FHIRcast, the Hub assumes that the same authorization and access rights apply to both the subscribing client and the system receiving notifications.

### Subscription Response
Upon receiving subscription or unsubscription requests, the Hub SHALL respond to a subscription request with an HTTP 202 "Accepted" response. This indicates that the request was received and will now be verified by the Hub. When using WebSockets, the HTTP body of the response SHALL consist of a JSON object containing an element name of `hub.channel.endpoint` and a value of the WSS URL. The WebSocket WSS URL SHALL be cryptographically random, unique, and unguessable. If using webhooks, the Hub SHOULD perform verification of intent as soon as possible.

If a Hub refuses the request or finds any errors in the subscription request, an appropriate HTTP error response code (4xx or 5xx) SHALL be returned. In the event of an error, the Hub SHOULD return a description of the error in the response body as plain text, to be used by the client developer to understand the error. This is not meant to be shown to the end user. Hubs MAY decide to reject some subscription requests based on their own policies.

### `webhook` vs `websocket`

A Hub SHALL support WebSockets and MAY support webhooks subscriptions. A subscriber specifies the preferred `hub.channel.type` of either `webhook` or `websocket` during creation of its subscription. Websockets are particularly useful if a subscriber is unable to host an accessible callback URL.

> Implementer feedback is solicited around the optionality and possible deprecation of webhooks.

#### `webhook` Subscription Request Example
In this example, the app asks to be notified of the `patient-open` and `patient-close` events.
```
POST https://hub.example.com
Host: hub.example.com
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.channel.type=webhook&hub.callback=https%3A%2F%2Fapp.example.com%2Fsession%2Fcallback%2Fv7tfwuk17a&hub.mode=subscribe&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065&hub.secret=shhh-this-is-a-secret&hub.events=patient-open,patient-close
```

#### `webhook` Subscription Response Example 
```
HTTP/1.1 202 Accepted
```

#### `websocket` Initial Subscription Request Example
In this example, the app creates an initial subscription and asks to be notified of the `patient-open` and `patient-close` events.
```
POST https://hub.example.com
Host: hub.example.com
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.channel.type=websocket&hub.mode=subscribe&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065&hub.events=patient-open,patient-close
```

#### `websocket` Subscription Response Example
```
HTTP/1.1 202 Accepted

{   
 "hub.channel.endpoint": wss://hub.example.com/ee30d3b9-1558-464f-a299-cbad6f8135de
}
```

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


###### `webhook` Subscription Denial Sequence
![Subscription denial flow diagram](../img/Denied%20Webhook%20Subscription%20Sequence.png)

###### `webhook` Subscription Denial Example
```
GET https://app.example.com/session/callback/v7tfwuk17a?hub.mode=denied&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065hub.events=patient-open,patient-close&hub.reason=session+unexpectedly+stopped HTTP 1.1
Host: subscriber
```

#### `websocket` Subscription Denial
To deny a `websocket` subscription, the Hub sends a JSON object to the subscriber through the established WebSocket connection. 

###### `websocket`Subscription Denial Sequence

![Subscription denial flow diagram](../img/Denied%20Websocket%20Subscription%20Sequence.png)

###### `websocket` Subscription Denial Example 
```
{
   "hub.mode": "denied",
   "hub.topic":" "fba7b1e2-53e9-40aa-883a-2af57ab4e2c",
   "hub.events": "patient-open,patient-close",
   "hub.reason": "session unexpectedly stopped"
}
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
```
GET https://app.example.com/session/callback/v7tfwuk17a?hub.mode=subscribe&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065&hub.events=patient-open,patient-close&hub.challenge=meu3we944ix80ox&hub.lease_seconds=7200 HTTP 1.1
Host: subscriber
```

#### `webhook` Intent Verification Response
If the `hub.topic` of the Intent Verification Request corresponds to a pending subscribe or unsubscribe request that the subscriber wishes to carry out it SHALL respond with an HTTP success (2xx) code, a header of `Content-Type: text/html`, and a response body equal to the `hub.challenge` parameter. If the subscriber does not agree with the action, the subscriber SHALL respond with a 404 "Not Found" response.

The Hub SHALL consider other server response codes (3xx, 4xx, 5xx) to mean that the verification request has failed. If the subscriber returns an HTTP success (2xx) but the content body does not match the `hub.challenge` parameter, the Hub SHALL consider verification to have failed.

The below flow diagram and example illustrate the successful subscription sequence and message details.

###### `webhook` Successful Subscription Sequence
![Successful subscription flow diagram](../img/Successful%20Subscription%20Sequence.png)

###### `webhook` Intent Verification Response Example
```
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
```
{
  "hub.mode": "subscribe",
  "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
  "hub.events": "patient-open,patient-close",
  "hub.lease_seconds": 7200
}
```

###### `websocket` Successful Subscription Sequence
![Successful web socket subscription flow diagram](../img/Successful%20WebSocket%20Subscription%20Sequence.png)


### Current context notification upon successful subscription
> NOTE
 > Implementer feedback on this optional feature is required. 

Upon the successful creation of a new subscription, the subscribing application will receive notifications for subsequent workflow steps, according to the `hub.events` specified in the subscription. Any previously established context is unknown to the newly subscribed application. To improve user experience, Hubs SHOULD follow a successful subscription with an event notification informing the newly subscribed application of the most recent \*-open event for which no \*-close event has occurred, according to the app's subscription.  Hubs that implement this feature, SHALL NOT send an app events to which it is not subscribed. 

 Although these event notifications are triggered by a successful subscription, they are indistinguishable from a normal, just-occurred workflow event trigged notification, as specified in Event Notification](#event-notification). Note that the `timestamp` in the event notification is the time at which the event occurred and not at which the notification is generated. 
  
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

```
POST https://hub.example.com
Host: hub
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.channel.type=webhook&hub.callback=https%3A%2F%2Fapp.example.com%2Fsession%2Fcallback%2Fv7tfwuk17a&hub.mode=unsubscribe&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065&hub.secret=shhh-this-is-a-secret&hub.challenge=meu3we944ix80ox

```

#### `websocket` Unsubscribe Request Example

```
POST https://hub.example.com
Host: hub
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.channel.type=websocket&hub.channel.endpoint=wss%3A%2F%2Fhub.example.com%2Fee30d3b9-1558-464f-a299-cbad6f8135de%0A&hub.mode=unsubscribe&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065

```

###### `webhook` and `websocket` Unsubscription Sequence
![Unsubscription flow diagram](/img/UnsubscriptionSequence.png)

## Event Notification

The Hub SHALL notify subscribed apps of workflow-related events to which the app is subscribed. The notification is a JSON object communicated over the `webhook` or `websocket` channel.

### Event Notification Request

The HTTP request notification interaction to the subscriber SHALL include a description of the subscribed event that just occurred, an ISO 8601-2 formatted timestamp in UTC and an event identifier that is universally unique for the Hub. The timestamp SHOULD be used by subscribers to establish message affinity (message ordering) through the use of a message queue. The event identifier MAY be used to differentiate retried messages from user actions.

#### Event Notification Request Details

The notification's `hub.event` and `context` fields inform the subscriber of the current state of the user's session. The `hub.event` is a user workflow event, from the Event Catalog (or an organization-specific event in reverse-domain name notation). The `context` is an array of named FHIR resources (similar to [CDS Hooks's context](https://cds-hooks.hl7.org/1.0/#http-request_1) field) that describe the current content of the user's session. Each event in the Event Catalog defines what context is included in the notification. The context contains zero, one, or more FHIR resources. Hubs SHOULD use the [FHIR _elements parameter](https://www.hl7.org/fhir/search.html#elements) to limit the size of the data being passed while also including additional, local identifiers that are likely already in use in production implementations. Subscribers SHALL accept a full FHIR resource or the [_elements](https://www.hl7.org/fhir/search.html#elements)-limited resource as defined in the Event Catalog.

Field | Optionality | Type | Description
--- | --- | --- | ---
`timestamp` | Required | *string* | ISO 8601-2 timestamp in UTC describing the time at which the event occurred. 
`id` | Required | *string* | Event identifier used to recognize retried notifications. This id SHALL be unique for the Hub, for example a UUID.
`event` | Required | *object* | A JSON object describing the event. See below.


Field | Optionality | Type | Description
--- | --- | --- | ---
`hub.topic` | Required | string | The session topic given in the subscription request. MAY be a UUID.
`hub.event`| Required | string | The event that triggered this notification, taken from the list of events from the subscription request.
`context` | Required | array | An array of named FHIR objects corresponding to the user's context after the given event has occurred. Common FHIR resources are: Patient, Encounter, and ImagingStudy. The Hub SHALL only return FHIR resources that the subscriber is authorized to receive with the existing OAuth 2.0 access_token's granted `fhircast/` scopes.

##### Extensions

The specification is not prescriptive about support for extensions. However, to support extensions, the specification reserves the name `extension` and will never define an element with that name, allowing implementations to use it to provide custom behavior and information. The value of an extension element MUST be a pre-coordinated JSON object. For example, an extension on a notification could look like this:


```
{
	"context": [{
			"key": "patient",
			"resource": {
				"resourceType": "Patient",
				"id": "ewUbXT9RWEbSj5wPEdgRaBw3"
			}
		},
		{
			"key": "extension",
			"data": {
				"user-timezone": "+1:00"
			}
		}
	]
}
```


#### `webhook` Event Notification Request Details

For `webhook` subscriptions, the Hub SHALL generate an HMAC signature of the payload (using the `hub.secret` from the subscription request) and include that signature in the request headers of the notification. The `X-Hub-Signature` header's value SHALL be in the form _method=signature_ where method is one of the recognized algorithm names and signature is the hexadecimal representation of the signature. The signature SHALL be computed using the HMAC algorithm ([RFC6151](https://www.w3.org/TR/websub/#bib-RFC6151)) with the request body as the data and the `hub.secret` as the key.

```
POST https://app.example.com/session/callback/v7tfwuk17a HTTP/1.1
Host: subscriber
X-Hub-Signature: sha256=dce85dc8dfde2426079063ad413268ac72dcf845f9f923193285e693be6ff3ae

<json object>
```

#### Event Notification Request Example
For both `webhook` and `websocket` subscriptions, the event notification content is the same. 

```
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

The subscriber SHALL respond to the event notification with an appropriate HTTP status code. In the case of a successful notification, the subscriber SHALL respond with an any of the response codes indicated below:
HTTP 200 (OK) or 202 (Accepted) response code to indicate a success; otherwise, the subscriber SHALL respond with an HTTP error status code. 

Code  |        | Description
--- | ---      | ---
200 | OK       | The subscriber is able to implement the context change.
202 | Accepted | The subscriber has successfully received the event notification, but has not yet taken action. If it decides to refuse the event, it will send a syncerror event. Clients are RECOMMENDED to do so within 5 seconds after receiving the context event.
500 | Server Error | There is an issue in the client preventing it from processing the event. The hub SHALL send a syncerror indicating the event was not delivered.
409 | Conflict | The client refuses to follow the context change. The hub SHALL send a syncerror indicating the event was refused.

The Hub MAY use these statuses to track synchronization state.

#### `webhook` Event Notification Response Example

For `webhook` subscriptions, the HTTP status code is communicated in the HTTP response, as expected.


```
HTTP/1.1 200 OK
```

#### `websocket` Event Notification Response Example

For `websocket` subscriptions, the `id` of the event notification and the HTTP status code is communicated from the client to Hub through the existing WebSocket channel, wrapped in a JSON object. Since the WebSocket channel does not have a synchronous request/response, this `id` is necessary for the Hub to correlate the response to the correct notification.

Field | Optionality | Type | Description
--- | --- | --- | ---
`id` | Required | *string* | Event identifier from the event notification to which this response corresponds.
`status` | Required | *numeric HTTP status code* | Numeric HTTP response code to indicate success or failure of the event notification within the subscribing app. Any 2xx code indicates success, any other code indicates failure.

```
{
  "id": "q9v3jubddqt63n1",
  "status": "200"
}
```

###### `webhook` and `websocket` Event Notification Sequence
![Event Notification flow diagram](../img/EventNotificationSequence.png)

## Event Notification Errors

All standard events are defined outside of the base FHIRcast specification in the Event Catalog with the single exception of the infrastructural `syncerror` event. 

If the subscriber cannot follow the context of the event, for instance due to an error or a deliberate choice to not follow a context, the subscriber SHALL communicate the error to the Hub in one of two ways.

* Responding to the event notification with an HTTP error status code as described in [Event Notification Response](#event-notification-response).
* Responding to the event notification with an HTTP 202 (Accepted) as described above, then, once experiencing the error or refusing the change, send a `syncerror` event to the Hub. 

If the Hub receives an error notification from a subscriber, it SHALL generate a `syncerror` event to the other subscribers of that topic. `syncerror` events are like other events in that they need to be subscribed to in order for an app to receive the notifications and they have the same structure as other events, the context being a single FHIR `OperationOutcome` resource.

### Event Notification Error Request
###### Request Context Change Parameters
Field | Optionality | Type | Description
--- | --- | --- | ---
`timestamp` | Required | *string* | ISO 8601-2 timestamp in UTC describing the time at which the `syncerror` event occurred. 
`id` | Required | *string* | Event identifier, which MAY be used to recognize retried notifications. This id SHALL be unique and could be a UUID. 
`event` | Required | *object* | A JSON object describing the event. See [below](#event-notification-error-event-object-parameters).

###### Event Notification Error Event Object Parameters
Field | Optionality | Type | Description
--- | --- | --- | ---
`hub.topic` | Required | string | The session topic given in the subscription request. 
`hub.event`| Required | string | Shall be the string `syncerror`.
`context` | Required | array | An array containing a single FHIR OperationOutcome. The OperationOutcome SHALL use a code of `processing`. The OperationOutcome's details SHALL contain the id of the event that this error is related to as a `code` with the `system` value of `https://fhircast.hl7.org/events/syncerror/eventid` and the name of the relevant event with a `system` value of `https://fhircast.hl7.org/events/syncerror/eventname`. Other `coding` values can be included with different `system` values so as to include extra information about the `syncerror`. The OperationOutcome's `diagnostics` element should contain additional information to aid subsequent investigation or presentation to the end-user. 

### Event Notification Error Example

```
POST https://hub.example.com/7jaa86kgdudewiaq0wtu HTTP/1.1
Host: hub
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/json

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
              "diagnostics": "AppId3456 failed to follow context",
              "details": {
                "coding": [
                  {
                    "system": "https://fhircast.hl7.org/events/syncerror/eventid",
                    "code": "fdb2f928-5546-4f52-87a0-0648e9ded065"
                  },
                  {
                    "system": "https://fhircast.hl7.org/events/syncerror/eventname",
                    "code": "patient-open"
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

###### `webhook` and `websocket` Event Notification Error Sequence
![Event Notification Error flow diagram](../img/ErrorSequence.png)

## Request Context Change

Similar to the Hub's notifications to the subscriber, the subscriber MAY request context changes with an HTTP POST to the `hub.url`. The Hub SHALL either accept this context change by responding with any successful HTTP status or reject it by responding with any 4xx or 5xx HTTP status. Similar to event notifications, described above, the Hub MAY also respond with a 202 (Accepted) status, process the request, and then later respond with a `syncerror` event in order to reject the request. In this case the `syncerror` would only be sent to the requestor. The subscriber SHALL be capable of gracefully handling a rejected context request. 

Once a requested context change is accepted, the Hub SHALL broadcast the context notification to all subscribers, including the original requestor. The requestor can use the broadcasted notification as confirmation of their request. The Hub reusing the request's `id` is further confirmation that the event is a result of their request. 

![Request context change flow diagram](../img/Request%20Context%20Change%20Flow.png)

### Request Context Change Request
###### Request Context Change Parameters
Field | Optionality | Type | Description
--- | --- | --- | ---
`timestamp` | Required | *string* | ISO 8601-2 timestamp in UTC describing the time at which the event occurred. 
`id` | Required | *string* | Event identifier, which MAY be used to recognize retried notifications. This id SHALL be uniquely generated by the subscriber and could be a UUID. Following an accepted context change request, the Hub MAY re-use this value in the broadcasted event notifications.
`event` | Required | *object* | A JSON object describing the event. See [below](#request-context-change-event-object-parameters).

###### Request Context Change Event Object Parameters
Field | Optionality | Type | Description
--- | --- | --- | ---
`hub.topic` | Required | string | The session topic given in the subscription request. 
`hub.event`| Required | string | The event that triggered this request for the subscriber, taken from the list of events from the subscription request.
`context` | Required | array | An array of named FHIR objects corresponding to the user's context after the given event has occurred. Common FHIR resources are: Patient, Encounter, ImagingStudy and List. 

```
POST https://hub.example.com/7jaa86kgdudewiaq0wtu HTTP/1.1
Host: hub
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/json

{
  "timestamp": "2018-01-08T01:40:05.14",
  "id": "wYXStHqxFQyHFELh",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "close-patient-chart",
    "context": [
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "798E4MyMcpCWHab9",
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
## Sharing of Content
In addition to basic context synchronization, FHIRcast supports real-time exchange of resources between clients subscribed to the same topic.

A key concept of the content sharing events is that the content is shared in a transactional manner.

![Transactional Updates](../img/TransactionalUpdates.png)

The above diagram shows a series of operations beginning with a `[FHIR resource]-open` request followed by three `[FHIR resource]-update` requests.  The content in an anchor context is built up by the successive `[FHIR resource]-update` requests which contain only changes to the current state.  These changes are propagated by the Hub to all subscribed clients using `[FHIR resource]-update` events containing only the changes to be made.

In order to avoid lost updates and other out of sync conditions, the Hub serves as the transaction coordinator.  It fulfills this responsibility by creating a version of the content's state with each update operation.  If an operation is requested by a client which provides an incorrect version, this request is rejected.  This approach is similar to the version concurrency approach used by [FHIR versions and managing resource contention](https://www.hl7.org/fhir/http.html#concurrency).  Additionally, many of the FHIRcast content sharing concepts have similarities to the [FHIR messaging mechanisms](https://www.hl7.org/fhir/messaging.html) and where possible the approaches and structures are aligned.

FHIR resources are used to convey the structured information being exchanged in `[FHIR resource]-update` operations.  However, it is possible that these resources are never be persisted in a FHIR server.  During the exchange of information, the content (FHIR resource instances) are often very dynamic in nature with a user creating, modifying, and even removing information which is being exchanged.  For example, a measurement made in an imaging application could be altered many times before it is finalized and it could be removed.

### Responsibilities of a FHIRcast Hub and a Subscribed Client

If supporting content sharing, a FHIRcast Hub must fulfill additional responsibilities:
1. Assign and maintain an anchor context's `versionId` when processing a `[FHIR resource]-open` request
2. Validate `[FHIR resource]-update` and `[FHIR resource]-select` requests for the correct `versionId` and reject the request if the version does not match the current `versionId` by returning a 4xx/5xx HTTP Status Code rather than updating the content or indication of selection
3. Assign and maintain a new `versionId` for the anchor context's content and provide the new `versionId` along with the `priorVersionId` in the event corresponding to the validated update request
4. Maintain a list of current FHIR resource content in the anchor context so that it may provide the anchor context's content in response to a [`GET Context`](../events/get-context.md) request
5. When a `[FHIR resource]-close` request is received, the Hub should dispose of the content for the anchor context since the Hub has no responsibility to persist the content

A Hub is not responsible for structurally validating FHIR resources.  While a Hub must be able to successfully parse FHIR resources sufficiently to perform its required capabilities (e.g., find the `id` of a resource), a Hub is not responsible for additional structural checking. 

A Hub is not responsible for any long-term persistence of shared information and should purge the content when a `[FHIR resource]-close` request is received.

Additionally, a Hub is not responsible to prevent applications participating in exchanging structured information from causing inconsistencies in the information exchanged.  For example, an inconsistency could arise if an application removes from the anchor context's content a resource which is referenced by another resource.  The Hub may check `[FHIR resource]-update` requests for such inconsistencies and reject the request with an appropriate error message; however, it is not required to do so.  Additionally, a Hub may check for inconsistencies which it deems to be critical but not perform exhaustive validation. For example, a Hub could validate that the content in a `DiagnosticReport` anchor context always includes at least one primary imaging study.

Clients wishing to exchange structured information must:
1. Handle FHIRcast events for anchor context types it supports: [FHIR resource]-[open|update|select|close]
2. Use a `[FHIR resource]-open` request to open a new resource which becomes the anchor context
3. Make a `[FHIR resource]-update` request when appropriate. The `[FHIR resource]-update` request contains a `Bundle` resource which is a collection of resources that are atomically processed by the Hub with the anchor context's content being adjusted appropriately
4. Maintain the current `versionId` of the anchor context provided by the Hub so that a subsequent `[FHIR resource]-update` request may provide the current `versionId`
5. Appropriately process [FHIR resource]-[open|update|select|close] events; note that a client may choose to ignore the contents of a `[FHIR resource]-update` event but should still track the `versionId` for subsequent use
6. If a `[FHIR resource]-update` request fails with the Hub, the client may issue a [`GET Context`](#../events/get-context.md) request to the Hub in order to retrieve the current content in the anchor context and its current `versionId`
7. When using websockets, clients will now receive the current content (if any exists) of the anchor context (if one has been established) in response to the Subscribe request, see [`return of current content`](#websocket-return-of-current-content).  Clients that don't support the exchange of structured information may ignore the content of the Subscribe response payload.

### Example of Content Sharing in an Anchor Context
The below example uses a `DiagnosticReport` as the anchor context.  However, the pattern of the example holds when other FHIR resource types are the anchor context.

#### Diagnostic Report Content Sharing Basics
When reporting applications integrate with PACS and/or RIS applications, a radiologist's (or other clinician's) workflow is centered on the final deliverable, a diagnostic report. In radiology, the imaging study (exam) is an integral resource with the report referencing one or more imaging studies. Structured data, many times represented by a FHIR `Observation` resource, may also be captured as part of a report.  In addition to basic context synchronization, a diagnostic report centered workflow builds upon the basic FHIRcast operations to support near real-time exchange of structured information between applications participating in a diagnostic report context.  Also, the `DiagnosticReport` resource contains certain attributes (such as report status), that are useful to PACS/RIS applications.  Participating applications may include clients such as reporting applications, PACS, EHRs, workflow orchestrators, and interactive AI applications.

Exchanged content need not have an independent existence. For the purposes of a working session in FHIRcast, they are all "contained" in one resource (the `DiagnosticReport` anchor context). For example, a radiologist may use the PACS viewer to create a measurement. The PACS application sends this measurement as an `Observation` to the other subscribing applications for consideration. If the radiologist determines the measurement is useful in another application (and accurate), it may then become an `Observation` to be included in the diagnostic report. Only when that diagnostic report becomes an official signed document would that `Observation` possibly be maintained with an independent existence. Until that time, FHIR domain resources serve as a convenient means to transfer data within a FHIRcast context.

Structured information may be added, changed, or removed quite frequently during the lifetime of a context. Exchanged information is transitory and it is not required that the information exchanged during the collaboration is persisted. However, as required by their use cases, each participating application may choose to persist information in their own structures which may or may not be expressed as a FHIR resource. Even if stored in the form of a FHIR resource, the resource may or may not be stored in a system which provides access to the information through a FHIR server and associated FHIR operations (i.e., it may be persisted only in storage specific to a given application).

| ![Basic Exchange of Content](../img/Basic%20Content%20Exchange.png) |
|:--:|
| Basics of Content Sharing |

#### Diagnostic Report Centered Workflow Events
When the anchor context is a 'DiagnosticReport' the following events are possible during content sharing. 

Operation | Description
--- | --- 
[`DiagnosticReport-open`](../events/diagnosticReport-open.md) | This notification is used to begin a new report. This should be the first event and establishes the anchor context.
[`DiagnosticReport-update`](../events/diagnosticReport-update.md) | This notification is used to make changes (updates) to the current report. These changes usually include adding/removing imaging studies and/or observations to the current report.
[`DiagnosticReport-select`](../events/diagnosticReport-select.md) | This notification is sent to tell subscribers to make one or more images or observations visible (in focus), such as a measurement (or other finding).
[`DiagnosticReport-close`](../events/diagnosticReport-close.md) | This notification is used to close the current diagnostic report anchor context with the current state of the exchanged content stored by subscribed applications as appropriate and cleared from these applications and the Hub. 

#### Example Use Case
A frequent scenario which illustrates a diagnostic report centered workflow involves an EHR, an image reading application, a reporting application, and an advanced quantification application.  The EHR, image reading application, and reporting application are authenticated and subscribed to the same topic using a FHIRcast Hub with the EHR establishing a patient context, see messages 1 through 7 in the below sequence diagram.

In an EHR a clinical users opens a patient with the EHR sending a Patient-open request to the Hub (messages 1 and 2).  The Hub notes the context and if it supports content sharing assigns a version to the context then distributes the Patient-open events (messages 3 and 4a, 4b, and 4c). The reporting application reacts to the patient context in some manner such as displaying available reports and imaging studies associated with the patient while storing the version of the patient context in case content is shared in this anchor context (message 5).  The imaging application is not interested in patient contexts so it ignores the event entirely (message 6) while the EHR identifies the Patient-open event as one it triggered and stores the version of the context provided by the Hub in case it would like to contribute content is this context (message 7).

Next the clinical user decides to create diagnostic report using the reporting application, see messages 8 through 14 in the below sequence diagram.

Using a reporting application, a clinical user creates a report by choosing an imaging study as the primary subject of the report (message 8).  The reporting application creates a report and then opens a diagnostic report context by posting a [`DiagnosticReport-open`](../events/diagnosticReport-open.md) request to the Hub (message 9). The Hub notes the context, assigns a version to the context and then distributes a [`DiagnosticReport-open`](../events/diagnosticReport-open.md) event with the generated `versionId` to subscribed applications (messages 10, 11a, 11b, and 11c). On receiving the [`DiagnosticReport-open`](../events/diagnosticReport-open.md) event from the Hub, an EHR decides not to react to this event noticing that the patient context has not changed (message 14). The image reading application responds to the event by opening the imaging study referenced in the diagnostic report anchor context (message 13) while the reporting application identifies the [`DiagnosticReport-open`](../events/diagnosticReport-open.md) event as one it triggered and stores the version of the context provided by the Hub (message 12).

| ![Opening a Diagnostic Report Context](../img/Open%20Report.png) |
|:--:|
| Opening a Diagnostic Report Context |

The clinical user takes a measurement using the imaging reading application (message 1 in the below sequence diagram) which then shares this measurement by making a [`DiagnosticReport-update`](../events/diagnosticReport-update.md) request to the Hub (message 2). The Hub validates that the `versionId` provided in the request is correct, updates its content, generates a new `versionId` (message 3). If the `versionId` provided in the request is not correct the Hub rejects the request (response to message 2). The Hub then distributes `DiagnosticReport-update`](../events/diagnosticReport-update.md) events which contain the newly generated `versionId` and the `priorVersionId` to all subscribed applications (messages 4a, 4b, and 4c). The reporting application receives the measurement through a [`DiagnosticReport-update`](../events/diagnosticReport-update.md) event from the Hub and adds this information to the report if the `versionId` it currently holds matches the `priorVersionId` provided in the event (message 7). If the `priorVersionId` does not match the `versionId` of the content known to the reporting application, it may resynchronize its content by requesting the current context from the Hub (message 8).

As the clinical user continues the reporting process they select a measurement or other structured information in the reporting application, the reporting application may note this selection by posting a [`DiagnosticReport-select`](../events/diagnosticReport-select.md) request to the Hub. Upon receiving the [`DiagnosticReport-select`](../events/diagnosticReport-select.md) event the image reading application may navigate to the image on which this measurement was acquired.

| ![Create a Measurement in a Diagnostic Report Context](../img/Share%20Content.png) |
|:--:|
| Create a Measurement |

At some point the image reading application (automatically or through user interaction) may determine that an advanced quantification application should be used and launches this application including the appropriate FHIRcast topic (messages 1 and 2 in the below sequence diagram).  The advanced quantification application then subscribes to the topic and requests the current context including any already exchanged structured information by making a [`GET Context`](../events/get-context.md) request to the Hub which returns the current context including existing content in the response (messages 3 and 4).  The user interacts with the advanced quantification application which then adds content to the anchor context (messages 6 through 13).

| ![Launch Advanced Quantification Application](../img/Advanced%20Quantification.png) |
|:--:|
| Newly Subscribed Application Contributes Content |

Finally the clinical user closes the report in the reporting application. The reporting application makes a [`DiagnosticReport-close`](../events/diagnosticReport-close.md) request. Upon receipt of the [`DiagnosticReport-close`](../events/diagnosticReport-close.md) event both the imaging reading application and advanced quantification application close all relevant image studies.

## Conformance
The FHIRcast specification can be described as a set of capabilities and any specific FHIRcast Hub may implement a subset of these capabilities. A FHIRcast Hub declares support for FHIRcast and specific capabilities by exposing an extension on its FHIR server's CapabilityStatement as described below. 

### Declaring support for FHIRcast 

To support various architectures, including multiple decentralized FHIRcast hubs, the Hub exposes a .well-known endpoint containing additional information about the capabilities of that hub. A Hub's supported events, version and other capabilities can be exposed as a Well-Known Uniform Resource Identifiers (URIs) ([RFC5785](https://tools.ietf.org/html/rfc5785)) JSON document.

Hubs SHOULD serve a JSON document at the location formed by appending `/.well-known/fhircast-configuration` to their `hub.url`. Contrary to RFC5785 Appendix B.4, the .well-known path component may be appended even if the `hub.url` endpoint already contains a path component.

A simple JSON document is returned using the `application/json` mime type, with the following key/value pairs -- 

Field | Optionality | Type | Description
--- | --- | --- | ---
`eventsSupported` | Required | array | Array of FHIRcast events supported by the Hub.
`websocketSupport` | Required | boolean | The static value: `true`, indicating support for websockets.
`webhookSupport` | Optional | boolean | `true` or `false` indicating support for webhooks. Hubs SHOULD indicate their support for web hooks. 
`fhircastVersion` | Optional | string | `STU1` or `STU2` indicating support for a specific version of FHIRcast. Hubs SHOULD indicate the version of FHIRcast supported.

#### Discovery Request Example
##### Base URL "www.hub.example.com/"
```
GET /.well-known/fhircast-configuration HTTP/1.1
Host: www.hub.example.com
```
#### Discovery Response Example  
```
HTTP/1.1 200 OK
Content-Type: application/json

{
  "eventsSupported": ["patient-open", "patient-close", "syncerror", "com.example.researchstudy-transmogrify"],
  "websocketSupport": true,
  "webhookSupport": false,
  "fhircastVersion": "STU2"
}
```
#### FHIR Capability Statement 

To supplement or optionally identify the location of a FHIRcast hub, a FHIR server MAY declare support for FHIRcast using the FHIRcast extension on its FHIR CapabilityStatement's `rest` element. The FHIRcast extension has the following internal components:

Component | Cardinality | Type | Description
--- | --- | --- | ---
`hub.url`| 0..1 | url | The url at which an app subscribes. May not be supported by client-side Hubs.

### CapabilityStatement Extension Example 

```
{
  "resourceType": "CapabilityStatement",
...
  "rest": [{
   ...
        "extension": [
          {
            "url": "http://fhircast.hl7.org/StructureDefinition/fhircast-configuration",
            "extension": [
              {
                "url": "hub.url",
                "valueUri": "https://hub.example.com/fhircast/hub.v2"
              }
            ]
        ]      ...
```

## Change Management and Versioning
#### Event Maturity Model

The intent of the FHIRcast Event Maturity Model is to attain broad community engagement and consensus before an event is labeled as mature, and to ensure that the event is necessary, implementable, and worthwhile to the systems that would reasonably be expected to use it. Implementer feedback should drive the maturity of new events. Diverse participation in open developer forums and events, such as HL7 FHIR Connectathons, is necessary to achieve significant implementer feedback. The below criteria will be evaluated with these goals in mind. 

Maturity Level | Maturity title | Requirements
--- | --- | ---
0 | Draft | Event is correctly named and defined per the [FHIRcast event template](../../events/template). 
1 | Submitted  | _The above, and …_ Event definition is written up as a pull request using the [Event template](../../events/template/) and community feedback is solicited from the community (e.g. the zulip FHIRcast stream](https://chat.fhir.org/#narrow/stream/179271-FHIRcast)).
2 | Tested | _The above, and …_ The event has been tested and successfully supports interoperability among at least one Hub and two independent subscribing apps using semi-realistic data and scenarios (e.g. at a FHIR Connectathon). The github pull request defining the event is approved and published.
3 | Considered |  _The above, and …_ At least 3 distinct organizations recorded ten distinct implementer comments (including a github or jira issue, tracker item, or comment on the event definition page), including at least two Hubs and three subscribing apps. The event has been tested at two connectathons.
4 | Documented | _The above, and …_ The author agrees that the artifact is sufficiently stable to require implementer consultation for subsequent non-backward compatible changes.  The event is implemented in the standard FHIRcast reference implementation and multiple prototype projects. The Event specification SHALL: <ul><ol>Identify a broad set of example contexts in which the event may be used with a minimum of three, but as many as 10.</ol><ol>Clearly differentiate the event from similar events or other standards to help an implementer determine if the event is correct for their scenario.</ol><ol>Explicitly document example scenarios when the event should not be used.</ol></ul>
5 | Mature | _The above, and ..._ The event has been implemented in production in at least two Hubs and three independent subscribing apps. An HL7 working group ballots the event and the event has passed HL7 STU ballot.
6 | Normative | _The above, and ..._ the responsible HL7 working group and the sponsoring working group agree the material is ready to lock down and the event has passed HL7 normative ballot


#### Event Maturity
As each event progresses through a process of being defined, tested, implemented, used in production environments, and balloted, the event's formal maturity level increases. Each event has its own maturity level, which SHALL be defined in the event's definition and correspond to the [Event Maturity Model](#event-maturity-model). 

#### Change Log

Changes made to an event's definition SHALL be documented in a change log to ensure event consumers can track what has been changed over the life of an event. The change log SHALL contain the following elements:

- Version: The version of the change
- Description: A description of the change and its impact

For example:

Version | Description
---- | ----
1.1 | Added new context FHIR object
1.0.1 | Clarified workflow description
1.0 | Initial Release
---

## Glossary

Concept | Description
--- | ---
session | an abstract concept representing a shared workspace, such as a user's login session across multiple applications or a shared view of one application distributed to multiple users - a session results from a user logging into an application and can encompass one or more workflows
topic | an identifier of a session
client | subscribes to and requests or receives session events
context | a resource associated with a session and communicated between clients that share a session which indicates a subject on which all clients should synchronize as appropriate to their functionality
current context | the context associated with a session that is active at a given time
anchor context | a context that is used as a container for shared content, typical anchor contexts are resources such as Patient, Encounter, ImagingStudy, and DiagnosticReport
content | resources created during a user's interaction with the anchor context - for example, if the anchor context is an imaging study the user may make a measurement resulting in an observation containing measurement information, the shared content either directly or indirectly references the anchor context
session event | a user initiated workflow event, communicated to clients, containing the current context

## Revision History
All changes to the FHIRcast specification are tracked in the [specification's HL7 github repository](https://github.com/HL7/fhircast-docs/commits/master). Further, issues may be submitted and are tracked in [jira](https://jira.hl7.org/browse/FHIR-25651?filter=12642) or (historically as) [github issues](https://github.com/HL7/fhircast-docs/issues).   For the reader's convenience, the below table additionally lists significant changes to the specification.

### 20200715 Significant changes as part of the STU2 publication included: 
* Introduction of WebSockets as the preferred communication mechanism over webhooks.
* Creation of a FHIR CapabilityStatement extension to support Hub capability discovery. 
* Additional, required information on `syncerror` OperationOutcome (namely communication of the error'd event's id and event name). 
* Websocket WSS URL communicated in HTTP body, instead of `Content-Location` HTTP header.
* Subscribers should differentiate between immediately applied context changes and mere successfully received notifications with HTTP code responses of 200 and 202, respectively.
