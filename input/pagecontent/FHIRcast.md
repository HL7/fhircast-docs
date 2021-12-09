# FHIRcast

1. The generated Toc will be an ordered list
{:toc}

## Introduction

### Overview

FHIRcast synchronizes healthcare applications in real time to show the same clinical content to a common user. For example, a radiologist often works in three disparate applications at the same time (a radiology information system, a PACS and a dictation system), she wants each of these three systems to display the same study or patient at the same time. 

FHIRcast isn't limited to radiology use-cases. Modeled after the common webhook design pattern and specifically [WebSub](https://www.w3.org/TR/websub/), FHIRcast naturally extends the SMART on FHIR launch protocol to achieve tight integration between disparate, full-featured applications. 

FHIRcast builds on the [CCOW](https://www.hl7.org/implement/standards/product_brief.cfm?product_id=1) abstract model to specify an http-based and simple context synchronization specification that doesn't require a separate context manager. FHIRcast is intended to be both less sophisticated, and more implementer-friendly than CCOW and therefore is not a one-to-one replacement of CCOW, although it solves many of the same problems.

Adopting the WebSub terminology, FHIRcast describes an app as a subscriber synchronizing with an EHR in the role of a Hub, but any user-facing application can synchronize with FHIRcast. While less common,  bidirectional communication between multiple applications is also possible.

### Why?

The large number of vendor-specific or proprietary context synchronization methods in production limit the industry's ability to enhance the very large number of integrations currently in production. In practice, these integrations are decentralized and simple. 

### How it works

The _driving application_ could be an EHR, a PACS, a worklist or any other clinical workflow system. The driving application integrates the Hub, the SMART authorization server and a FHIR server. As part of a SMART launch, the app requests appropriate [fhircast OAuth 2.0 scopes](specification/STU1/#fhircast-authorization-smart-scopes) and receives the initial shared context as well as the location of the Hub and a unique `hub.topic` session identifier.

The app subscribes to specific workflow events for the given user's session by contacting the Hub. The Hub verifies the subscription notifies the app when those workflow events occur; for example, by the clinician opening a patient's chart. The app deletes its subscription when it no longer wants to receive notifications.

### Example scenario

A radiologist working in their reporting system clicks a button to open their dictation system. The dictation app is authorized and subscribes to the radiologist's session. Each time the radiologist opens a patient's chart in the reporting system, the dictation app will be notified of the current patient and therefore presents the corresponding patient information on its own UI. The reporting system and dictation app share the same session's context.

<img align="left" width="100%"  src="colorful%20overview%20diagram.png">


* Event notifications are thin json wrappers around FHIR resources.	
* The app can request context changes by sending an event notification to the Hub's `hub.topic` session identifier. The HTTP response status indicates success or failure. 	
* The Event Catalog documents the workflow events that can be communicated in FHIRcast. Each event will always carry the same type of FHIR resources.

### Get involved
* Check out our [awesome community contributions on github](https://github.com/fhircast)
* [Log issues](https://jira.hl7.org/secure/CreateIssue.jspa), [submit a PR!](https://github.com/fhircast/docs)
* [Converse at chat.fhir.org](https://chat.fhir.org/#narrow/stream/subscriptions)
## FHIRcast specification

The FHIRcast specification describes the APIs used to synchronize disparate healthcare applications' user interfaces in real time,  allowing them to show the same clinical content to a user (or group of users). 

Once the subscribing app [knows about the session](#session-discovery), the app [subscribes](#subscribing-and-unsubscribing) to specific workflow-related events for the given session. The app is then [notified](#event-notification) when those workflow-related events occur; for example, when the clinician opens a patient's chart. The subscribing app can also [initiate context changes](#request-context-change) by accessing APIs defined in this specification; for example, closing the patient's chart. The app [deletes its subscription](#unsubscribe) to no longer receive notifications. The notification messages describing the workflow event are defined as a simple JSON wrapper around one or more FHIR resources.

FHIRcast recommends the [HL7 SMART on FHIR launch protocol](http://www.hl7.org/fhir/smart-app-launch) for both session discovery and API authentication. FHIRcast enables a subscriber to receive notifications either through a webhook or over a WebSocket connection. This protocol is modeled on the [W3C WebSub RFC](https://www.w3.org/TR/websub/), such as its use of GET vs POST interactions and a Hub for managing subscriptions. The Hub exposes APIs for subscribing and unsubscribing, requesting context changes, and distributing event notifications. The flow diagram presented below illustrates the series of interactions specified by FHIRcast, their origination and their outcome.

{% include img.html img="FHIRcast%20overview%20for%20abstract.png" caption="Figure: FHIRcast overview" %}

All data exchanged through the HTTP APIs SHALL be formatted, sent and received as [JSON](https://tools.ietf.org/html/rfc8259) structures, and SHALL be transmitted over channels secured using the Hypertext Transfer Protocol (HTTP) over Transport Layer Security (TLS), also known as HTTPS which is defined in [RFC2818](https://tools.ietf.org/html/rfc2818).

All data exchanged through WebSockets SHALL be formatted, sent and received as [JSON](https://tools.ietf.org/html/rfc8259) structures, and SHALL be transmitted over Secure Web Sockets (WSS) as defined in [RFC6455](https://tools.ietf.org/html/rfc6455).

This specification consists of the following elements:

* [Event Definition](2-1-EventDefinition.html)
* [FHIRcast Smart scopes](2-2-fhircastSmartScopes.html)
* [Subscribing to events](2-3-subscribing.html)
* [Event notification](2-4-eventNotification.html)
* [Request context change](2-5-requestContextChange.html)
* [Conformance](2-6-conformance.html)## Event Definition

### <a name="events"></a> Events

FHIRcast describes a workflow event subscription and notification scheme with the goal of improving a clinician's workflow across multiple disparate applications. The set of events defined in this specification is not a closed set; anyone is able to define new events to fit specific use cases and are encouraged to propose those events to the community for standardization. 

New events are proposed in a prescribed format using the [documentation template](../../events/template) by submitting a [pull request](https://github.com/fhircast/docs/tree/master/docs/events). FHIRcast events are versioned, and mature according to the [Event Maturity Model](#event-maturity-model).

FHIRcast events do not communicate previous state. For a given event, opens and closes are complete replacements of previous communicated events, not "deltas". Understanding an event SHALL not require receiving a previous or future event.

#### Event Definition Format

Each event definition: specifies a single event name, a description of the workflow in which the event occurs, and contextual information associated with the event. FHIR is the interoperable data model used by FHIRcast. The context information associated with an event is communicated as subsets of FHIR resources. Event notifications SHALL include the elements of the FHIR resources defined in the context from the event definition. Event notifications MAY include other elements of these resources.

For example, when the [`ImagingStudy-open`](../../events/imagingstudy-open) event occurs, the notification sent to a subscriber SHALL include an ImagingStudy FHIR resource, which includes at least the elements defined in the *_elements* query parameter, as indicated in the event's definition. For ImagingStudy, this is defined as: `ImagingStudy/{id}?_elements=identifier,accession`. (The *_elements* query parameter is defined in the [FHIR specification](https://www.hl7.org/fhir/search.html#elements)). 

A Hub SHALL at least send the required elements; a subscriber SHALL gracefully handle receiving a full FHIR resource in the context of a notification.

Each defined event in the standard event catalog SHALL be defined in the following format.

##### Event Definition Format: hook-name

Most FHIRcast events conform to an extensible syntax based upon FHIR resources. In the rare case where the FHIR data model doesn't describe content in the session, FHIRcast events MAY be named differently. For example, FHIR doesn't cleanly contain the concept of a user or user's session.  

Patterned after the SMART on FHIR scope syntax and expressed in EBNF notation, the FHIRcast syntax for workflow related events is:

`hub.events ::= ( fhir-resource | '*' ) '-' ( 'open' | 'close' | '*' )`

{% include img.html img="events-railroad.png" caption="Figure: Syntax for new events" %}

FHIRcast events SHOULD conform to this extensible syntax.

Event names are unique and case-insensitive. Implementers may define their own events. Such proprietary events SHALL be named with reverse domain notation (e.g. `org.example.patient_transmogrify`). Reverse domain notation SHALL NOT be used by a standard event catalog. Proprietary events SHALL NOT contain a dash ("-").

##### Event Definition Format: Workflow

Describe the workflow in which the event occurs. Event creators SHOULD include as much detail and clarity as possible to minimize any ambiguity or confusion amongst implementers.

##### Event Definition Format: Context

Describe the set of contextual data associated with this event. Only data logically and necessarily associated with the purpose of this workflow related event should be represented in context. An event SHALL contain all required data fields, MAY contain optional data fields and SHALL NOT contain any additional fields.
 
All fields available within an event's context SHALL be defined in a table where each field is described by the following attributes:

- **Key**: The name of the field in the context JSON object. Event authors SHOULD name their context fields to be consistent with other existing events when referring to the same context field.
- **Optionality**: A string value of either `Required`, `Optional` or `Conditional`
- **FHIR operation to generate context**: A FHIR read or search string illustrating the intended content of the event. 
- **Description**: A functional description of the context value. If this value can change according to the FHIR version in use, the description SHOULD describe the value for each supported FHIR version.

### Session Discovery

A session is an abstract concept representing a shared workspace, such as user's login session over multiple applications or a shared view of one application distributed to multiple users. FHIRcast requires a session to have a unique, unguessable, and opaque identifier. This identifier is exchanged as the value of the `hub.topic` parameter. Before establishing a subscription, an app must not only know the `hub.topic`, but also the `hub.url` which contains the base URL of the Hub.

Systems SHOULD use SMART on FHIR to authorize, authenticate, and exchange initial shared context. If using SMART, following a [SMART on FHIR EHR launch](http://www.hl7.org/fhir/smart-app-launch#ehr-launch-sequence) or [SMART on FHIR standalone launch](http://www.hl7.org/fhir/smart-app-launch/#standalone-launch-sequence), the app SHALL request and, if authorized, SHALL be granted one or more FHIRcast OAuth 2.0 scopes. Accompanying this scope grant, the authorization server SHALL supply the `hub.url` and `hub.topic` SMART launch parameters alongside the access token and other parameters appropriate to establish initial shared context. Per SMART, when the `openid` scope is granted, the authorization server additionally sends the current user's identity in an `id_token`.

Although FHIRcast works best with the SMART on FHIR launch and authorization process, implementation-specific launch, authentication, and authorization protocols may be possible. If not using SMART on FHIR, the mechanism enabling the app to discover the `hub.url` and `hub.topic` is not defined in FHIRcast. See [other launch scenarios](/launch-scenarios) for guidance.

## FHIRcast SMART scopes

### FHIRcast Authorization & SMART scopes

FHIRcast defines OAuth 2.0 access scopes that correspond directly to [FHIRcast events](#events). Our scopes associate read or write permissions to an event. Apps that need to receive workflow related events SHOULD ask for `read` scopes. Apps that request context changes SHOULD ask for `write` scopes. Hubs may decide what specific interactions and operations will be enabled by these scopes.

Expressed in [Extended Backus-Naur Form](https://www.iso.org/obp/ui/#iso:std:iso-iec:14977:ed-1:v1:en) (EBNF) notation, the FHIRcast syntax for OAuth 2.0 access scopes is:

`scope ::= ( 'fhircast' ) '/' ( FHIRcast-event | '*' ) '.' ( 'read' | 'write' | '*' )`

{% include img.html img="fhircast-smart-scopes.png" caption="Figure: Syntax for FHIRcast scopes" %}

For example, a requested scope of `fhircast/patient-open.read` would authorize the subscribing application to receive a notification when the patient in context changed. Similarly, a scope of  `fhircast/patient-open.write` authorizes the subscribed app to [request a context change](#request-context-change).

#### SMART Launch Example

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

## Subscribing and unsubscribing

### <a name="subscribing"></a> Subscribing and Unsubscribing

Subscribing and unsubscribing is how applications establish their connection and determine which events they will be notified of. Hubs SHALL support WebSockets and MAY support webhooks. If the Hub does not support webhooks then they should deny any subscription requests with `webhook` as the channel type.

Subscribing consists of two exchanges:

* Subscriber requests a subscription at the `hub.url` URL.
* The hub confirms that the subscription was requested by the subscriber. This exchange can be implemented in two ways depending on the channel type:
  * For `webhook` subscriptions, the Hub confirms the subscription was actually requested by the subscriber by contacting the `hub.callback` URL. 
  * For `websocket` subscriptions, the Hub returns a wss URL and subscriber establishes WebSocket connection. 

Unsubscribing works in the same way, using the same message format. The `hub.mode` parameter is set to a value of `unsubscribe`, instead of `subscribe`. The Hub SHALL NOT validate unsubscribe requests with the subscriber.

#### Subscription Request

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

#### Subscription Response
Upon receiving subscription or unsubscription requests, the Hub SHALL respond to a subscription request with an HTTP 202 "Accepted" response. This indicates that the request was received and will now be verified by the Hub. When using WebSockets, the HTTP body of the response SHALL consist of a JSON object containing an element name of `hub.channel.endpoint` and a value of the WSS URL. The WebSocket WSS URL SHALL be cryptographically random, unique, and unguessable. If using webhooks, the Hub SHOULD perform verification of intent as soon as possible.

If a Hub refuses the request or finds any errors in the subscription request, an appropriate HTTP error response code (4xx or 5xx) SHALL be returned. In the event of an error, the Hub SHOULD return a description of the error in the response body as plain text, to be used by the client developer to understand the error. This is not meant to be shown to the end user. Hubs MAY decide to reject some subscription requests based on their own policies.

#### `webhook` vs `websocket`

A Hub SHALL support WebSockets and MAY support webhooks subscriptions. A subscriber specifies the preferred `hub.channel.type` of either `webhook` or `websocket` during creation of its subscription. Websockets are particularly useful if a subscriber is unable to host an accessible callback URL.

> Implementer feedback is solicited around the optionality and possible deprecation of webhooks.

##### webhook

###### `webhook` Subscription Request Example

In this example, the app asks to be notified of the `patient-open` and `patient-close` events.

```
POST https://hub.example.com
Host: hub.example.com
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.channel.type=webhook&hub.callback=https%3A%2F%2Fapp.example.com%2Fsession%2Fcallback%2Fv7tfwuk17a&hub.mode=subscribe&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065&hub.secret=shhh-this-is-a-secret&hub.events=patient-open,patient-close
```

###### `webhook` Subscription Response Example 

```
HTTP/1.1 202 Accepted
```

##### websocket

###### `websocket` Initial Subscription Request Example

In this example, the app creates an initial subscription and asks to be notified of the `patient-open` and `patient-close` events.

```
POST https://hub.example.com
Host: hub.example.com
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.channel.type=websocket&hub.mode=subscribe&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065&hub.events=patient-open,patient-close
```

###### `websocket` Subscription Response Example

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

{% include img.html img="Denied%20Webhook%20Subscription%20Sequence.png" caption="Figure: Webhook subscription denial" %}

###### `webhook` Subscription Denial Example

```
GET https://app.example.com/session/callback/v7tfwuk17a?hub.mode=denied&hub.topic=fdb2f928-5546-4f52-87a0-0648e9ded065hub.events=patient-open,patient-close&hub.reason=session+unexpectedly+stopped HTTP 1.1
Host: subscriber
```

#### `websocket` Subscription Denial
To deny a `websocket` subscription, the Hub sends a JSON object to the subscriber through the established WebSocket connection. 

###### `websocket`Subscription Denial Sequence

{% include img.html img="Denied%20Websocket%20Subscription%20Sequence.png" caption="Figure: Websocket subscription denial" %}

###### `websocket` Subscription Denial Example

```json
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

{% include img.html img="Successful%20Subscription%20Sequence.png" caption="Figure: Successful subscription sequence" %}

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

{% include img.html img="Successful%20WebSocket%20Subscription%20Sequence.png" caption="Figure: Successful web socket subscription flow diagram" %}

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

{% include img.html img="UnsubscriptionSequence.png" caption="Figure: Unsubscription flow diagram" %}

## <a name="eventnotification"></a> Event Notification

The Hub SHALL notify subscribed apps of workflow-related events to which the app is subscribed. The notification is a JSON object communicated over the `webhook` or `websocket` channel.

## Event notification

### Event Notification Request

The HTTP request notification interaction to the subscriber SHALL include a description of the subscribed event that just occurred, an ISO 8601-2 formatted timestamp in UTC and an event identifier that is universally unique for the Hub. The timestamp SHOULD be used by subscribers to establish message affinity (message ordering) through the use of a message queue. Subscribers SHALL ignore messages with older timestamps than the message that established the current context. The event identifier MAY be used to differentiate retried messages from user actions.

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

{ ... json object ... }
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
202 | Accepted | The subscriber has successfully received the event notification, but has not yet taken action. If it decides to refuse the event, it will send a syncerror event. Clients are RECOMMENDED to do so within 10 seconds after receiving the context event.
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

{% include img.html img="EventNotificationSequence.png" caption="Figure: Event Notification flow diagram" %}

## Event Notification Errors

All standard events are defined outside of the base FHIRcast specification in the Event Catalog with the single exception of the infrastructural `syncerror` event. 

If the subscriber cannot follow the context of the event, for instance due to an error or a deliberate choice to not follow a context, the subscriber SHALL communicate the error to the Hub in one of two ways.

* Responding to the event notification with an HTTP error status code as described in [Event Notification Response](#event-notification-response).
* Responding to the event notification with an HTTP 202 (Accepted) as described above, then, once experiencing the error or refusing the change, send a `syncerror` event to the Hub. If the application cannot determine whether it will follow context within 10 seconds after reception of the event it SHOULD send a `syncerror` event.

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

{% include img.html img="ErrorSequence.png" caption="Figure: Event Notification Error flow diagram" %}

## Request Context Change

### Request Context Change

Similar to the Hub's notifications to the subscriber, the subscriber MAY request context changes with an HTTP POST to the `hub.url`. The Hub SHALL either accept this context change by responding with any successful HTTP status or reject it by responding with any 4xx or 5xx HTTP status. Similar to event notifications, described above, the Hub MAY also respond with a 202 (Accepted) status, process the request, and then later respond with a `syncerror` event in order to reject the request. In this case the `syncerror` would only be sent to the requestor. The subscriber SHALL be capable of gracefully handling a rejected context request. 

Once a requested context change is accepted, the Hub SHALL broadcast the context notification to all subscribers, including the original requestor. The requestor can use the broadcasted notification as confirmation of their request. The Hub reusing the request's `id` is further confirmation that the event is a result of their request. 

{% include img.html img="Request%20Context%20Change%20Flow.png" caption="Figure: Request context change flow diagram" %}

#### Request Context Change Request

##### Request Context Change Parameters

Field | Optionality | Type | Description
--- | --- | --- | ---
`timestamp` | Required | *string* | ISO 8601-2 timestamp in UTC describing the time at which the event occurred. 
`id` | Required | *string* | Event identifier, which MAY be used to recognize retried notifications. This id SHALL be uniquely generated by the subscriber and could be a UUID. Following an accepted context change request, the Hub MAY re-use this value in the broadcasted event notifications.
`event` | Required | *object* | A JSON object describing the event. See [below](#request-context-change-event-object-parameters).

##### Request Context Change Event Object Parameters

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
## Conformance


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

## Event library

This the definition of the event maturity model and the events defined in this specification. What events are supported by a hub is defined by the hub.

The sections in this chapter are:

* [Event Maturity Model](3-0-EventMaturityModel.html)
* [Event template](3-1-template.html)
* [Patient open event](3-2-patient-open.html)
* [Patient close event](3-3-patient-close.html)
* [Encounter open event](3-4-encounter-open.html)
* [Encounter close event](3-5-encounter-close.html)
* [ImagingStudy open event](3-6-imagingstudy-open.html)
* [ImagingStudy close event](3-7-imagingstudy-close.html)
* [Sync error event](3-8-syncerror.html)
* [User logout event](3-9-userlogout.html)
* [User hibernate event](3-10-userhibernate.html)
* [Heartbeat event](3-11-heartbeat.html)## Event template

## <mark>[FHIR resource]-[open|close]</mark>

eventMaturity | [0 - Draft](../../specification/STU1/#event-maturity-model)

### Workflow

<mark>Describe when this event occurs in a workflow. Describe how the context fields relate to one another. Event creators SHOULD include as much detail and clarity as possible to minimize any ambiguity or confusion amongst implementors.</mark>

### Context

<mark>Define context values that are provided when this event occurs, and indicate whether they must be provided, and the FHIR query used to generate the resource. </mark>

Key | Optionality | FHIR operation to generate context | Description
----- | -------- | ---- | ---- 
<mark>`example`</mark> | REQUIRED | `FHIRresource/{id}?_elements=identifer` | <mark>Describe the context value</mark>
<mark>`encounter`</mark> | OPTIONAL | `Encounter/{id}` | <mark>Describe the context value</mark>

### Examples

<mark>

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "patient-open",
    "context": [
      {
        "key": "key-from-above",
        "resource": {
          "resourceType": "resource-type-from-above"
        }
      },
      {
        "key": "encounter",
        "resource": {
          "resourceType": "Encounter"
        } 
      }
    ]
  }
}
```

</mark>

### Change Log

Version | Description
---- | ----
1.0 | Initial Release
## Patient open event

## Patient-open

eventMaturity | [2 - Tested](../../specification/STU1/#event-maturity-model)

### Workflow

User opened patient's medical record. Only a single patient is currently in context.  

### Context

Key | Optionality | Fhir operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose chart is currently in context.
~~`encounter`~~ | ~~REQUIRED, if exists~~ | ~~`Encounter/{id}?_elements=identifier`~~ | ~~FHIR Encounter resource in context in the newly opened patient's chart.~~ DEPRECATED in favor of a dedicated `encounter-open` event. 


### Examples

<mark>

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
                    "display": "Medical Record Number"
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

</mark>

### Change Log

Version | Description
---- | ----
1.0 | Initial Release
1.1 | Deprecate encounter element in favor of dedicated `encounter-open` event.

## Patient close event

## Patient-close

eventMaturity | [2 - Tested](../../specification/STU1/#event-maturity-model)

### Workflow

User closed patient's medical record. A previously open and in context patient chart is no longer open nor in context. 

### Context

Key | Optionality | Fhir operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose chart was previously in context.
~~`encounter`~~ | ~~REQUIRED, if exists~~ | ~~`Encounter/{id}?_elements=identifier`~~ | ~~FHIR Encounter resource previously in context in the now closed patient's chart.~~ DEPRECATED in favor of dedicated `encounter-close` event.


### Examples

<mark>

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "patient-close",
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
                    "display": "Medical Record Number"
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

</mark>

### Change Log

Version | Description
---- | ----
1.0 | Initial Release
1.1 | Deprecate encounter element in favor of dedicated `encounter-close` event.

## Encounter open event

## Encounter-open

eventMaturity | [0 - Draft](../../specification/STU1/#event-maturity-model)

### Workflow

User opened patient's medical record in the context of a single encounter. Only a single patient and encounter is currently in context.

### Context

Key | Optionality | Fhir operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose encounter is currently in context.
`encounter` | REQUIRED | `Encounter/{id}?_elements=identifier	` | FHIR Encounter resource in context.



### Examples

<mark>

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "encounter-open",
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
                    "display": "Medical Record Number"
                  }
                ]
              }
            },
            {
              "key": "encounter",
              "resource": {
                "resourceType": "Encounter",
                "id": "90235y2347t7nwer7gw7rnhgf",
                "identifier": [
                  {
                    "system": "28255",
                    "value": "344384384"
                  }
                ],
                "patient": {
                  "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
                }
              }
            }
          ]
        }
      }
    ]
  }
}
```

</mark>

### Change Log

Version | Description
---- | ----
1.0 | Initial Release
## Encounter close event

## Encounter-close

eventMaturity | [0 - Draft](../../specification/STU1/#event-maturity-model)

### Workflow

User closed patient's medical record encounter context. A previously open and in context patient encounter is no longer open nor in context. 

### Context

Key | Optionality | Fhir operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose encounter was previously in context.
`encounter` | REQUIRED | `Encounter/{id}?_elements=identifier	` | FHIR Encounter resource previously in context.


### Examples

<mark>

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "encounter-close",
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
                    "display": "Medical Record Number"
                  }
                ]
              }
            },
            {
              "key": "encounter",
              "resource": {
                "resourceType": "Encounter",
                "id": "90235y2347t7nwer7gw7rnhgf",
                "identifier": [
                  {
                    "system": "28255",
                    "value": "344384384"
                  }
                ],
                "patient": {
                  "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
                }
              }
            }
          ]
        }
      }
    ]
  }
}
```

</mark>

### Change Log

Version | Description
---- | ----
1.0 | Initial Release
## ImagingStudy open event

## ImagingStudy-open

eventMaturity | [2 - Tested](../../specification/STU1/#event-maturity-model)

### Workflow

User opened record of imaging study. The newly open study may have been associated with a specific patient, or not. 

### Context

Key | Optionality | Fhir operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient associated with the study currently in context.
`study` | REQUIRED | `ImagingStudy/{id}?_elements=identifier,accession` | FHIR ImagingStudy resource in context. Note that in addition to the request identifier and accession elements, the DICOM uid and FHIR patient reference are included because they're required by the FHIR specification.


### Examples

<mark>
  
```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "imagingstudy-open",
    "context": [
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "ewUbXT9RWEbSj5wPEdgRaBw3",
          "identifier": [
            {
              "system": "urn:oid:1.2.840.114350",
              "value": "185444"
            },
            {
              "system": "urn:oid:1.2.840.114350.1.13.861.1.7.5.737384.27000",
              "value": "2667"
            }
          ]
        }
      },
      {
        "key": "study",
        "resource": {
          "resourceType": "ImagingStudy",
          "id": "8i7tbu6fby5ftfbku6fniuf",
          "uid": "urn:oid:2.16.124.113543.6003.1154777499.30246.19789.3503430045",
          "identifier": [
            {
              "system": "7678",
              "value": "185444"
            }
          ],
          "patient": {
            "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
          }
        }
      }
    ]
  }
}
```

</mark>

### Change Log

Version | Description
---- | ----
1.0 | Initial Release
## ImagingStudy close event

## ImagingStudy-close

eventMaturity | [2 - Tested](../../specification/STU1/#event-maturity-model)

### Workflow

User opened record of imaging study. 

User closed patient's medical record. A previously open and in context study is no longer open nor in context. The previously open study may have been associated with a specific patient, or not. 

### Context

Key | Optionality | Fhir operation to generate context | Description
----- | -------- | ---- | ---- 
`patient` | REQUIRED | `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient associated with the study currently in context.
`study` | REQUIRED | `ImagingStudy/{id}?_elements=identifier,accession` | FHIR ImagingStudy resource previously in context. Note that in addition to the request identifier and accession elements, the DICOM uid and FHIR patient reference are included because they're required by the FHIR specification.


### Examples

<mark>

```json
{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "imagingstudy-close",
    "context": [
      {
        "key": "patient",
        "resource": {
          "resourceType": "Patient",
          "id": "ewUbXT9RWEbSj5wPEdgRaBw3",
          "identifier": [
            {
              "system": "urn:oid:1.2.840.114350",
              "value": "185444"
            },
            {
              "system": "urn:oid:1.2.840.114350.1.13.861.1.7.5.737384.27000",
              "value": "2667"
            }
          ]
        }
      },
      {
        "key": "study",
        "resource": {
          "resourceType": "ImagingStudy",
          "id": "8i7tbu6fby5ftfbku6fniuf",
          "uid": "urn:oid:2.16.124.113543.6003.1154777499.30246.19789.3503430045",
          "identifier": [
            {
              "system": "7678",
              "value": "185444"
            }
          ],
          "patient": {
            "reference": "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
          }
        }
      }
    ]
  }
}
```

</mark>

### Change Log

Version | Description
---- | ----
1.0 | Initial Release
## Sync error event

## syncerror

eventMaturity | [2 - Tested](../../specification/STU1/#event-maturity-model)

### Workflow

A synchronization error has been detected. Inform subscribed clients. 

Unlike most of FHIRcast events, `syncerror` is an infrastructural event and does not follow the `FHIR-resource`-`[open|close]` syntax and is directly referenced in the [underlying specification](../../specification/STU1/#event-notification-errors).

### Context

Key | Optionality | Fhir operation to generate context | Description
----- | -------- | ---- | ---- 
`operationoutcome` | OPTIONAL | `OperationOutcome` | FHIR resource describing an outcome of an unsuccessful system action.

The OperationOutcome SHALL use a code of `processing`.  
The OperationOutcome's `issue[0].details.coding.code` SHALL contain the id of the event that this error is related to as a `code` with the `system` value of "https://fhircast.hl7.org/events/syncerror/eventid".  
The OperationOutcome's `issue[0].details.coding.code` SHALL contain the name of the relevant event with a `system` value of "https://fhircast.hl7.org/events/syncerror/eventname".  
The OperationOutcome's `issue[0].details.coding.code` SHALL contain the name of the relevant subscriber `system` value of "https://fhircast.hl7.org/events/syncerror/subscriber".  
Other `coding` values can be included with different `system` values so as to include extra information about the `syncerror`.
The `diagnostics` field SHALL contain a human readable explanation on the source and reason for the error.

### OperationOutcome profile

The profile of the OperationOutcome resource expressed in FHIR shorthand.

```

Profile:     SyncErrorOperationOutcome
Parent:      OperationOutcome
Id:          sync-error-operationoutcome
Description: The OperationOutcome included in a syncerror event.
* issue[0].severity.code = #error
* issue[0].code = #processing
* issue[0].diagnostics MS
* issue[0].diagnostics 1..1
* issue[0].details.coding ^slicing.discriminator.type = #value
* issue[0].details.coding ^slicing.discriminator.path = "system"
* issue[0].details.coding ^slicing.discriminator.description = "Reason and source of syncerror."
* issue[0].details.coding 
        contains eventid 1..1 MS and 
        eventname 1..1 MS
* issue[0].details.coding[eventid].system = https://fhircast.hl7.org/events/syncerror/eventid
* issue[0].details.coding[eventname].system = https://fhircast.hl7.org/events/syncerror/eventname

```


### Examples

<mark>

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
              "severity": "error",
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

</mark>

### Change Log

Version | Description
---- | ----
1.0 | Initial Release
2.0 | Require id of event syncerror is about, in `OperationOutcome.details.coding.code`
## User logout event


eventMaturity | [1 - Submitted](../../specification/STU1/#event-maturity-model)

### Workflow

User's session has ended, perhaps by exiting the application through a logout, session time-out or other reason.

Unlike most of FHIRcast events, `userlogout` is a statically named event and therefore does not follow the `FHIR-resource`-`[open|close]` syntax.

### Context

The context is empty.

### Examples

<mark>

```json
{
  "timestamp": "2019-11-25T13:16:00.00",
  "id": "35d0b1d4-de45-4b5b-a0e9-9c51b21ee71a",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065", 
    "hub.event": "userLogout", 
    "context": [] 
  }
}
```

</mark>

### Change Log

Version | Description
---- | ----
1.0 | Initial Release
## User hibernate event


eventMaturity | [1 - Submitted](../../specification/STU1/#event-maturity-model)

### Workflow

User temporarily suspended their session. The user's session will eventually resume.
 
Unlike most of FHIRcast events, `userhibernate` is a statically named event and therefore does not follow the `FHIR-resource`-`[open|close]` syntax.

### Context

The context is empty.

### Examples

<mark>

```json
{
  "timestamp": "2019-11-25T13:16:00.00",
  "id": "35d0b1d4-de45-4b5b-a0e9-9c51b21ee71a",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "userHibernate",
    "context": []
  }
}
```

</mark>

### Change Log

Version | Description
---- | ----
1.0 | Initial Release
## Heartbeat event

!!! important Implementator feedback is requested for the need to support heartbeats for websockets.


The heartbeat event is sent regularly to indicate a channel is open (typically by the hub).

The name of the event is: heartbeat

### Workflow
This event SHALL be send at least every 10 second, or an order of magnitude lower than the subscription time-out.

### Context
The context of the -monitor event described in the table below.

| Key       | Optionality   | #   | type      | *Description*       |
|-----------|:--------------|-----|-----------|---------------------|
| `period` | REQUIRED      | 1   | decimal   | The maximum resend period in seconds |

The `period` field indicates the repeat interval. If an event is not received within this time period, the connection may be assumed to be lost.

### Example

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
## Scenario's

This chapter contains a set of typical deployment scenario's:

* [App launch scenarios and session discovery](4-1-launch-scenarios.html)
* [Synchronization considerations](4-2-syncconsiderations.html)
* [Security considerations](4-3-security-considerations.html)
* [Multi-tab considerations](4-4-multitab-considerations.html)
* [Multi-anchor considerations](4-5-multi-anchor-considerations.html)
## App launch scenarios and session discovery

A FHIRcast Hub uses a unique `hub.topic` session id to identify a single session across the Hub, subscribing and driving applications which are engaged in the shared session. The `hub.topic` must be known by a system for it to participate in the session. Typically, the Hub defines the `hub.topic`.

The [HL7 SMART on FHIR app launch specification](http://www.hl7.org/fhir/smart-app-launch) enables the launched, synchronizing app to discover the `hub.topic`, because the SMART OAuth 2.0 server provides it during the OAuth 2.0 handshake as a SMART launch parameter. Use of SMART requires either that a synchronizing app supports the SMART on FHIR specification and specifically either be launched from the driving app or use the hub's authorization server's login page. 

Once the `hub.topic` and url to the hub (`hub.url`) are known by the synchronizing app, the subscription and workflow event notification process proceeds per the FHIRcast specification, regardless of the specific app launch used. 

The use of the SMART on FHIR OAuth 2.0 profile simplifies, secures and standardizes FHIRcast context synchronization. While more creative approaches, such as the alternate app launch and shared session identifier generation algorithm are possible to use with FHIRcast, care must be taken by the implementer to ensure synchronization and to protect against PHI loss, session hijacking and other security risks. Specifically, the `hub.topic` session identifier must be unique, unguessable, and specific to the session. 

### SMART on FHIR

FHIRcast extends SMART on FHIR to support clinical context synchronization between disparate, full featured healthcare applications which cannot be embedded within one another. Two launch scenarios are explicitly supported. The app is authorized to synchronize to a user's session using the OAuth2.0 [FHIRcast scopes](2_specification.html#fhircast-authorization-smart-scopes).

During the OAuth2.0 handshake, the app [requests and is granted](http://www.hl7.org/fhir/smart-app-launch/#2-ehr-evaluates-authorization-request-asking-for-end-user-input) one or more FHIRcast scopes. The EHR's authorization server returns the hub url and any relevant session topics as SMART launch parameters. 

| SMART launch parameter | Optionality | Type | Description |
| --- | --- | --- | --- |
| `hub.url` | Required | string | The base url of the EHR's hub. |
| `hub.topic` | Optional | string | The session topic identifiers. The `hub.topic` is a unique, opaque identifier to the a user's session, typically expressed as a hub-generated guid. |

The app requests one or more FHIRcast scopes, depending upon its needs to learn about specific workflow events or to direct the workflow itself.

```
Location: https://ehr/authorize?
            response_type=code&
            client_id=app-client-id&
            redirect_uri=https%3A%2F%2Fapp%2Fafter-auth&
            launch=xyz123&
            scope=fhircast%2FImagingStudy-open.read+launch+patient%2FObservation.read+patient%2FPatient.read+openid+profile&
            state=98wrghuwuogerg97&
            aud=https://ehr/fhir
```

Following the OAuth2.0 handshake, the authorization server returns the FHIRcast SMART launch parameters alongside the access_token.

```json
{
  "access_token": "i8hweunweunweofiwweoijewiwe",
  "token_type": "bearer",
  "expires_in": 3600,
  "scope": "patient/Observation.read patient/Patient.read",
  "state": "98wrghuwuogerg97",
  "intent": "client-ui-name",
  "patient":  "123",
  "encounter": "456",
  "hub.url" : "https://hub.example.com",
  "hub.topic": "2e5e1b95-5c7f-4884-b19a-0b058699318b"
  "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065"
}
```

The app then [subscribes](/#app-subscribes-to-session) to the identified session

Two different launch scenarios are supported. For each launch scenario, the app discovers the session topic to which it subscribes.


#### EHR Launch: User SSO's into app from EHR

The simplest launch scenario is the [SMART on FHIR EHR launch](http://www.hl7.org/fhir/smart-app-launch/#ehr-launch-sequence), in which the subscribing app is launched from an EHR authenticated session. The app requests both the `launch` and desired FHIRcast scopes (for example, `fhircast/ImagingStudy-open.read`) and  receives information about the user and session as part of the launch. The app subsequently subscribes to the launching user's session. 

In this scenario, the EHR authorizes the app to synchronize. The EHR provides a session topic as a SMART launch parameter which belongs to the EHR's current user. 

#### Standalone launch: User authenticates to EHR to authorize synchronization

If the app can't be launched from the EHR, for example, it's opening on a different machine, it can use the standard [SMART on FHIR standalone launch](http://www.hl7.org/fhir/smart-app-launch/#standalone-launch-sequence). 

In this scenario, the user authorizes the app to synchronize to her session by authenticating to the EHR's authorization server. The app requests desired FHIRcast scopes and the EHR provides a session topic as a SMART launch parameter which belongs to the EHR's authorizing user. 

### Alternate app launch

In practice, even enterprise apps are often launched from within a clinician's workflow through a variety of bespoke web and desktop technologies. For example, an EHR might launch a desktop app on the same machine by specifying the executable on the Windows shell and passing contextual information as command line switches to the executable. Similarly, bespoke Microsoft COM APIs, shared polling of designated filesystem directories or web service ticketing APIs are also commonly used in production environments.  The use of OAuth 2.0 strengthens and standardizes the security and interoperability of integrations. In the absence of OAuth 2.0 support, these alternate app launch mechanisms can also be used to share a session topic and therefore initiate a shared FHIRcast session. 

A fictitious example Windows shell integration invokes a PACS system at system startup by passing some credentials, user identity and the FHIRcast session identifier (`hub.topic`) and hub base url (`hub.url`).

```
C:\Windows\System32\PACS.exe /credentials:<secured credentials> /user:jsmith /hub.url:https://hub.example.com /hub.topic:2e5e1b95-5c7f-4884-b19a-0b058699318b
```

An additional example is a simple (and relatively insecure) web application launch extended with the addition of `hub.url` and `hub.topic` query parameters.
```
GET https://app.example.com/launch.html?user=jsmith&hub.url=https%3A%2F%2Fhub.example.com&hub.topic=2e5e1b95-5c7f-4884-b19a-0b058699318b
```

Similarly, any bespoke app launch mechanism can establish a FHIRcast session by adding the `hub.url` and `hub.topic` parameters into the existing contextual information shared during the launch.  Once launched, the app subscribes to the session and receives notifications following the standardized FHIRcast interactions. 

### No app launch

In a scenario in which the user manually starts two or more applications, the applications do not have the capability to establish a shared session topic. Since there's no "app launch", with its corresponding ability to exchange contextual information, the unique, unguessable, and session-specific `hub.topic` must be calculated by both the driving application's hub and the subscribing application. The synchronizing application could use a shared algorithm and secret to generate the `hub.topic`.

A bespoke session topic generation algorithm could encrypt the current user's username and a nonce with a shared secret to a pre-configured base url. In this contrived example, a base url and secret are securely configured on the subscribing app. The subscribing app generates and appends a nonce to the current user's Active Directory username, encrypts that string with the shared secret according to an agreed upon encryption algorithm, and finally appends that encrypted string to the base url. The resulting url is unique to the current user and unguessable to a middle man due to the shared secret.

```
https://hub.example/com/AES256(username+nonce, shared secret)
```
## Synchronization considerations

FHIRcast describes a mechanism for synchronizing distinct applications. Sometimes things go wrong, and applications fail to synchronize or become out of sync. For example, the user within the EHR opens a new patient's record, but the app fails to process the update and continues displaying the initial patient.

### Scenarios

Depending upon the expectations of the user and the error handling of the applications in use, this scenario is potentially risky. Identified below are four distinct synchronization scenarios, ranging from lowest level of expected synchronization to highest.
Also note that synchronization failure is a worst-case scenario and should rarely occur in production.
Machine-to-machine-to-machine: Different machines, different times

#### Machine-to-machine-to-machine: Different machines, different times

**Scenario**: Clinician walks away from her desktop EHR and accesses an app on her mobile device which synchronizes to the EHR's hibernated session.

| Consideration | Risk |
|--|--|
|Synchronization failure significance | low |
|Performance expectations|negligible|
|User inability to distinguish between synchronized applications| n/a|

**Summary**: This serial or sequential use-case is a convenience synchronization and the clinical risk for synchronization failure is low.

#### Cross device: Different machines, same time

**Scenario**: Clinician accesses her desktop EHR as well an app on her mobile device at the same time. Mobile device synchronizes with the EHR desktop session.

|Consideration|Risk|
|--|--|
|Synchronization failure significance|medium|
|Performance expectations|low|
|User inability to distinguish between synchronized applications| low|

**Summary**: The user clearly distinguishes between the applications synchronized on multiple devices and therefore clinical risk for a synchronization failure depends upon the workflow and implementer's goals. User manual action may be appropriate when synchronization fails.

#### Same machine, same time

**Scenario**: Clinician is accessing two or more applications on the same machine in a single workflow.  

|Consideration|Risk|
|--|--|
|Synchronization failure significance| medium|
|Performance expectations|high|
|User inability to distinguish between synchronized applications| medium|

**Summary**: Although, the applications applications are distinguishable from one another, the workflow requires rapidly accessing one then another application. Application responsivity to synchronization is particularly important. Synchronization failure may introduce clinical risk and therefore user notification of synchronization failure is suggested.

#### Embedded apps: Same machine, same time, same UI

**Scenario**: Clinician accesses multiple applications within a single user interface.

|Consideration|Risk|
|--|--|
|Synchronization failure significance|very high|
|Performance expectations|high|
|User inability to distinguish between synchronized applications|very high|

**Summary**: Disparate applications indistinguishable from one another require the greatest amount of context synchronization. Clinical risk of synchronization failure is critical. Application responsivity to synchronization should be high. Synchronization failure may introduce clinical risk and therefore user notification of synchronization failure is suggested.

#### Multiple machines, multiple synchronized applications, same time

**Scenario**: Clinician accesses multiple applications on different monitors and machines at the same time. Each application fulfills a specific role. A typical example of such set-up is a radiology workstation.

|Consideration | Risk |
|--|--|
| Synchronization failure significance | very high |
| Performance expectations | high |
| User inability to distinguish between synchronized applications | very high |

**Summary**: Different applications that work together require the greatest amount of context synchronization. Clinical risk of synchronization failure is critical. Application responsivity to synchronization should be high. Synchronization failure may introduce clinical risk and therefore user notification of synchronization failure is required.

### Synchronization error situations

FHIRcast is based on a subscription model where each subscribing client receives notifications of the updated state of the topic being subscribed to. There is no explicit requirement for a subscribing client to follow the context of another client. The subscription model also implies that it is the subscribing clients responsibility to maintain a contextual synchronization or to notify end users whenever the contextual synchronization is lost.
However, as noted in above scenarios, there may be risk associated with the end user expectation of have two tightly synchronized applications if they fall out of sync.

There are in some cases good reasons for a client not to follow the subscribed context and this section will outline some of the recommended approaches.

#### Blocking action on subscribing client preventing context synchronization

Many applications go into edit mode or start a modal dialog that locks the system from changing context without user intervention. Examples can be when modifying texts, reports, annotating images or performing administrative tasks. The clients may then decline to follow the subscribed context to prevent loss of end user data.

|System|Failure mode|Possible actions|
|--|--|--|
| Subscribing Client | Modal dialog open in UI, unable to change case without losing end user data | Present end user with clear indication that contextual synchronization is lost. Respond with a http status code of 409 conflict. |
| Subscribing Client | Unable to change context | Respond with a http status code of 409 conflict|
| Subscribing Client | Ask user whether context can be changed, user refuses. | The Client responds to the initial event with an 202 Accepted and sends a `syncerror` when the context change is refused, stating the source and reason for change. |
| Subscribing Client | Ask user whether context can be changed, user does not react in time. | The Client responds to the initial event with an 202 Accepted. When the user does not respond within 10 seccond,  it sends a `syncerror` text change is refused, stating the source and reason for change. |
| Hub | One of the subscribing clients cannot follow context | No action/Update all subscribing clients with event sync-error |

#### Failure off subscribing client preventing context synchronization

Although not intended, application do fail. In this case the event is received by the application but some internal error prevents it from processing it.
|System|Failure mode|Possible actions|
|--|--|--|
| Subscribing Client | Internal error state prevents processing of the event. | If possible, present end user with clear indication that contextual synchronization is lost. Respond with a http status code of 50X. |
| Hub | One of the subscribing clients cannot follow context | No action/update all subscribing clients with event sync-error using information from the subscriber.name field in the original subscription. |

#### Connection is lost

This error scenario is all about the Hub losing contact with its subscribing clients. This may be due to a client crash, mis-configured callback URL or simply an underlying network failure. In these cases, the clients are usually not aware of the fact that the context has changed or that the subscription messages are not received.
To mitigate this situation, clients are recommended to register for `heartbeat` events.

|System|Failure mode|Possible actions|
|--|--|--|
| Subscribing Client | No event received from Hub within the heartbeat time-out. | Present a clear indication to the end-user that the connection has been lost. Resubscribe to the topic. The resend relevant event feature will make sure the application will come back into sync. |
| Hub | Timeout or error from client callback URL | No action/Retry/Update all subscribing clients with event sync-error using information from the subscriber.name field in the original subscription. |

#### Race condition during launch

Once an app is launched with initial context, for example, the currently in context patient, the app must subscribe before it receives notifications of updated context. Between the instant of launch and the instant of a confirmed subscription, it is technically possible for context to change, such that the newly launched app joins a session with stale contextual information. In most scenarios, this problem is likely noticeable by the end user. This error situation is mitigated by the hub sending the last relevant event(s) when a client (re)subscribes.

#### `syncerror` event received from Hub

In the scenarios where the Hub is aware of a synchronization error, it is advisable for the Hub to signal this to the subscribing applications to minimize any patient risk associated with having one or many applications out of sync.

| System | Failure mode | Possible actions |
|--|--|--|
| Subscribing Client | Sync-error event received from Hub | Present end user with clear indication that contextual synchronization is lost |

#### Subscription has expired

The client subscription has expired causing it no longer receive event. The application can prevent this by resubscribing before the subscription expires.
| System | Failure mode | Possible actions |
|--|--|--|
| Subscribing Client | Subscription has expired | Present a clear indication to the end-user that the subscription has expired. Resubscribe to the topic. The resend relevant event feature will make sure the application will come back into sync.
| Hub | None | The hub cannot distinguish between an intentional and unintentional subscription expiration. So it cannot mitigate this.|

#### Race condition between context changes

Two or more clients are sending context change event shortly after each other causing the events to cross.
| System | Failure mode | Possible actions |
|--|--|--|
| Subscribing Client | Receive older events | Ensure that the timestamp is checked and that events older than the event that triggered the current context state are ignored. |
| Subscribing Client | Conflicting events | When a client detects an event with a suggested context change that is send shortly after its own event, it should compare the timestamp of these events and treat the most recent event as current. It should also not respond with a resend of its context change without querying the user to prevent triggering an endless context switch waterfall. |
| Hub | None | The hub cannot and should not be involved in distinguishing between an intentional and unintentional event  expiration. So it cannot mitigate this. |

### Reestablishing sync

The situations in which a sync error can occur are indicated in the previous section. Once a sync error situation occurs, applications need to be able to recover from it.

#### Clients that initiate a context change

A Client that initiates a context change and receives a `syncerror` related to a context change event it send, SHOULD resend this event at regular intervals until sync is reestablished or another, newer, event has been received. It is recommended to wait at least 10 seconds before resending the event. Note that such resend will use the timestamp of the original event to prevent race conditions.

#### Clients that follow context change

A Client that follow context change should monitor new events or re-sends of the old event. When an event is received with a timestamp equal or newer than the event that caused the `syncerror`, it shall assume sync is restored unless a new `syncerror` is received.

#### Clients that lose the connection to the hub

These Clients should resubscribe to the hub and topic. Once resubscribed, and the most recent relevant event has been received, the Client can assume that sync is restored.

#### Hubs

A hub that send a `syncerror` event (e.g. as it is not able to deliver an event) MAY resend this event regularly until sync has been reestablished or a newer event has been received.

### Open topics

* Do I get all sync-errors or only those related to events I subscribed to?
* Does a hub send an `syncerror` for each client that cannot be reached or refused or is it allowed to combine them in one.
* When the hub/application resends an context change event, is the `heartbeat` still needed?## Security considerations

!!! info "Implementer guidance" 
    This page contains guidance to implementers and is not part of the normative-track [FHIRcast specification](../specification/STU2).

### Security Considerations

FHIRcast enables the synchronization of healthcare applications user interfaces in real-time through the exchange of a workflow event to a small number of disparate applications. The notification message which describes the workflow event is a simple json wrapper around one or more FHIR resources. These FHIR resources can contain Protected Health Information (PHI). 

#### Actors 

* Subscribing app
* Hub
* Authorization Server
* Resource server

FHIRcast ties SMART as the authnz layer together with WebSub for subscription and event notification.

#### Sources of Risk
1. The FHIRcast Hub pushes PHI to a dynamic url specified by the authenticated app. 
1. An app's credentials or a Hub's lack of authentication could be used by a malicious system to control the user's session.
1. FHIRcast recommends the use of SMART on FHIR, but does not require it. Implementation-specific launch, authentication, and authorization protocols may be possible. These alternate protocols should be scrutinized by implementers for additional security risks.


#### SMART on FHIR
[SMART on FHIR](http://www.hl7.org/fhir/smart-app-launch/) profiles [OAuth 2.0's authorization code grant type](https://tools.ietf.org/html/rfc6749#section-1.3.1) and extends it by introducing an "[EHR Launch Sequence](http://www.hl7.org/fhir/smart-app-launch/#ehr-launch-sequence)". The Argonaut Project performed a formal security review of SMART on FHIR, resulting in a [Risk Assessment report](http://argonautwiki.hl7.org/images/e/ed/%282015May26%29RiskAssessment_ReportV1.pdf).

FHIRcast builds on SMART by introducing a new [syntax for standard OAuth 2.0 scopes](/specification/STU1/#fhircast-authorization-smart-scopes), as well as two new SMART launch parameters of `hub.url` and `hub.topic`. 

* [HL7 SMART on FHIR specification](http://www.hl7.org/fhir/smart-app-launch/)
* [Argonaut Risk Assessment report](http://argonautwiki.hl7.org/images/e/ed/%282015May26%29RiskAssessment_ReportV1.pdf).
* [OAuth 2.0 Threat Model and Security Considerations](https://tools.ietf.org/html/rfc6819)

#### HTTP Web Hooks using WebSub

[WebSub](https://www.w3.org/TR/websub/) is a W3C RFC designed for the distribution of web content through a standardized web hooks architecture. FHIRcast uses WebSub to allow clients to subscribe and unsubscribe to the Hub and, for the Hub to notify subscribers of events. 

Unlike WebSub, FHIRcast requires that both the Hub and the subscribing apps endpoints are exposed over https.

The below [flow diagram](https://drive.google.com/file/d/16pdG6Kw4pAG53J9d7_rK98DSvm_GMiCC/view?usp=sharing) illustrates each of the interactions. 

![FHIRcast flow diagram](/img/FHIRcast%20WebSub%20security%20sequence.png)


##### How does the subscriber authenticate to the Hub?
The subscribing app can make three distinct API calls to the Hub. For each of these calls, the subscribing app authenticates to the Hub with the Hub's authorization server issued SMART `access_token`. Per SMART on FHIR, this `access_token` is presented to the Hub in the HTTP Authorization header.

1. App subscribes to Hub
1. App requests change to shared context
1. App unsubscribes from session

```
POST https://hub.example.com
Host: hub.example.com
Authorization: Bearer i8hweunweunweofiwweoijewiwe
```

##### How does the Hub validate the subscriber?
The Hub can make three distinct API calls to the subscribing app's `hub.callback` url. 

1. Hub verifies callback url with app
1. Hub notifies app of event
1. Hub denies subscription


This [flow diagram](https://drive.google.com/file/d/1sqh3Jghd2QGzq_EhRR-uv6axgIkVW1EE/view?usp=sharing) describes the actors and actions. 

![WebSub security flow](/img/WebSub%20security%20sequence%20flow.png)


The [subscribing app initiates](http://fhircast.org/#app-subscribes-to-session) the FHIRcast subscription, authenticating to the Hub with its bearer token, and providing the `hub.secret` and `hub.callback` url. The Hub verifies intent and ownership by performing an HTTP GET to the `hub.callback` url, with a `hub.challenge`. The subscribing app must echo the `hub.challenge` in the body of an HTTP 202 response. Once a workflow event occurs, the Hub notifies the app of the event by POSTing to the subscribing app's `hub.callback` url. The Hub provides an [HMAC signature](https://www.w3.org/TR/websub/#bib-RFC6151) of the previously provided `hub.secret` in the `X-Hub-Signature` HTTP header.

```
POST https://app.example.com/session/callback/v7tfwuk17a HTTP/1.1
Host: subscriber
X-Hub-Signature: sha256=dce85dc8dfde2426079063ad413268ac72dcf845f9f923193285e693be6ff3ae
```

The client that creates the subscription may not be the same system as the server hosting the callback url. (For example, some type of federated authorization model could possibly exist between these two systems.) However, in FHIRcast, the Hub assumes that the same authorization and access rights apply to both the subscribing client and the callback url.

##### WebSub Security Considerations
The WebSub RFC defines [specific security considerations](https://www.w3.org/TR/websub/#security-considerations), including the below, which are listed here for emphasis or elevation from optional to mandatory.
* Subscribers must communicate with a Hub over https.
* Hub must reject unsecured http callback urls. 
* The subscribing app's `hub.callback` url should be unique and unguessable. 
* Subscribing apps must provide a `hub.secret` and validate the `X-Hub-Signature` in the notification message.
* Hubs must reject subscriptions if the callback url does not echo the `hub.challenge` as part of the intent verification GET.
* When computing the HMAC digest with the `hub.secret` for the `X-Hub-Signature` HTTP header, Hubs must use SHA-256 or greater and must not use SHA-1.
* For each subscription, the `hub.secret` must be unique, unguessable and securely stored by both the Hub and the app. 
* To prevent a subscriber from continuing to receive information after its authorization has ended, if using OAuth 2.0, the Hub must limit the subscription's `lease_seconds` to be less than or equal to the access token's expiration timestamp.


* [W3C WebSub RFC](https://www.w3.org/TR/websub/)
* [W3C WebSub RFC's Security Considerations](https://www.w3.org/TR/websub/#security-considerations)
* [HMAC RFC 6151](https://www.w3.org/TR/websub/#bib-RFC6151)


#### Experimental Websockets support

In addition to the web hooks communication pattern, the FHIRcast community is experimenting with the use of websockets for event notification. Below are some incomplete considerations for a potential websockets implementation.

Subscribers SHOULD only use and Hub's SHOULD only accept connections made over the secure _wss://_ websocket protocol and not the unsecured _ws://_ websocket protocol.

The WebSockets standard defines an `Origin` header, sent from the client to the server and intended to contain the url of the client. Subscribers using websockets may be running in a browser, in which case the browser enforces origin reporting to the Hub, or native apps in which the origin reported to the Hub can not be trusted. Therefore, a Hub exposing a websocket connection MUST not rely upon the origin sent by the subscriber. 

While native app subscribers can send any standard HTTP headers, notably including _Authorization: Bearer_, browser-based subscribers are limited to only HTTP Basic Auth or cookies. Therefore, the typical use of the OAuth 2.0 access_token for bearer authentication does not consistently work with websockets. FHIRcast describes a "ticket"-based authentication system, in which the `hub.topic` provided to the subscriber as part of the secured SMART app launch serves not only as a unique session identifier, but also as an "authorization ticket". This authorization ticket effectively acts as a bearer token. The Hub should therefore take care to generate opaque and unique `hub.topic` values. 

* [The WebSocket Protocol RFC 6455](https://tools.ietf.org/html/rfc6455)
* [Heroku's excellent explanation of websocket security](https://devcenter.heroku.com/articles/websocket-security)
## Multi-tab considerations

!!! info "Implementer guidance" 
    This page contains guidance to implementers and is not part of the normative-track [FHIRcast specification](../specification/STU2).

### Considerations for application with simultaneous contexts

Just as a modern web browser supports multiple pages loaded, but only a single in active use at a given time, some healthcare applications support multiple, distinct patient charts loaded even though  only a single chart is interacted with at a given time. Other applications in healthcare may only support a single patient (or study or ...) context being loaded in the application at a given time. It's important to be able to synchronize the context between two applications supporting these different behaviors. For convenience, we refer to these two types of application behavior as "multi-tab" and "single tab".
    
#### Single and Multiple Tab Applications
Applications can have different capabilities and layouts, but with FHIRcast they should still be able to stay in sync. A potential situation that could cause confusion is when a single and a multi-tab application work together. While the below guidance describes a patient chart as the primary concept for synchronization, the same guidance applies for other concepts.  

Let's start with a simple case.

##### Opening and Closing a Patient
The diagrams below show two applications without any context, followed by a `patient-open` event communicated to the other app resulting in same patient being opened in the receiving app. When the patient is closed, a `patient-close` event is triggered leading to the patient being closed in the other app as well.

{% include img.html img="PatientOpenAndClose.png" caption="Figure: Simple patient open and close example" %}


##### Opening Multiple Patients
As illustrated below, context synchronization is maintained between multiple and single-tabbed applications even across multiple contexts being opened. The initial `patient-open` works as expected by synchronizing the two apps for Patient 1. When the multi-tab app opens a second patient (without closing the first) the single-tab app follows the context change, resulting in the applications staying in sync. Even when the user is working within the multi-tab app, the single-tab app can still stay in sync with the current context.

{% include img.html img="MultiplePatientOpens.png" caption="Figure: Multiple patient open example" %}

#### Recommendations
* When synchronizing with a multi-tab application, receiving multiple, sequential `-open` events (for example, `patient-open`) does not indicate a synchronization error. 
* Multi-tab applications should differentiate between the closing versus inactivating of contexts, by not communicating the inactivation of a context through a `-close` event. 

#### Launching A Context-Less Tab
Many applications can have a "home" or "default" tab that contains no clinical context, but may hold useful application features. In some cases other applications may want to subscribe to and be notified when another app has switched to the no context tab. To avoid confusion with other events, a new event is proposed to represent a user switching to this context-less tab. 

!!! note 
    Implementer feedback is solicited around the semantics of communicating a context change to a "context-less tab". For example, why not a `patient-open` (or `imagingstudy-open` or ...) with a patient (or study or ...). 

Since we are inherently representing the lack of context, the event will not fully conform to the defined event naming syntax and will instead use a static name (similar to `userlogout`).


##### home-open

eventMaturity | [1 - Submitted](../../specification/STU1/#event-maturity-model)

###### Workflow

The user has opened or switched back to the application's home page or tab which does not have any FHIR related context.

Unlike most of FHIRcast events, `home-open` is representing the lack of a FHIR resource context and therefore does not fully follow the `FHIR-resource`-`[open|close]` syntax.

###### Context

The context is empty.

###### Example

<mark>
```json
{
  "timestamp": "2019-11-25T13:16:00.00",
  "id": "35d0b1d4-de45-4b5b-a0e9-9c51b21ee71a",
  "event": {
	"hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065", 
	"hub.event": "home-open", 
	"context": [] 
  }
}
```
</mark>


#### notes
Assumption: Open of an already open means a select.

Late joining  - event stating the current selected patient.

#### Risk

Order of patients can be different between different application. (Late app joining, temperarely out of sync)## Multi-anchor considerations

This section describes how FHIRcast can be used in a scenario where multiple applications subscribe to different anchor-types.

## Glossary

### Glossary

* session: an abstract concept representing a shared workspace, such as a user's login session across multiple applications or a shared view of one application distributed to multiple users.  A session results from a user logging into an application and can encompass one or more workflows.
* topic: an identifier of a session
* client: subscribes to and requests or receives session events
* current context: data associated with a session at a given time and communicated between clients that share a session
* session event: a user initiated workflow event, communicated to clients, containing the current context
## Change log

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



### Revision History
All changes to the FHIRcast specification are tracked in the [specification's HL7 github repository](https://github.com/HL7/fhircast-docs/commits/master). Further, issues may be submitted and are tracked in [jira](https://jira.hl7.org/browse/FHIR-25651?filter=12642) or (historically as) [github issues](https://github.com/HL7/fhircast-docs/issues).   For the reader's convenience, the below table additionally lists significant changes to the specification.

#### 20200715 Significant changes as part of the STU2 publication included: 

* Introduction of WebSockets as the preferred communication mechanism over webhooks.
* Creation of a FHIR CapabilityStatement extension to support Hub capability discovery. 
* Additional, required information on `syncerror` OperationOutcome (namely communication of the error'd event's id and event name). 
* Websocket WSS URL communicated in HTTP body, instead of `Content-Location` HTTP header.
* Subscribers should differentiate between immediately applied context changes and mere successfully received notifications with HTTP code responses of 200 and 202, respectively.
## Open Issues

The following open issues require attention:

* Fix hyperlinks in the documents - there still based  the old specification format
* Populate the multi-anchor scenario
* Include the content exchange scenario
* Fix the `.fsh` files.
* ? update the sequence diagrams to plantuml ?