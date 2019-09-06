<img style="float: left;padding-right: 5px;" src="/img/hl7-logo-header.png" width=90px" />
# FHIRcast

> "1.0 Draft" This is the draft of the 1.0 release of the FHIRcast specification. We are currently working towards a 1.0 release and would love your feedback and proposed changes. Look at our [current issue list](https://github.com/fhircast/docs/issues) and get involved!

## Overview
The FHIRcast specification describes the APIs and interactions to synchronize healthcare applications in real time to show the same clinical content to a user. All data exchanged through the HTTP APIs MUST be sent and received as [JSON](https://tools.ietf.org/html/rfc8259) structures, and MUST be transmitted over channels secured using the Hypertext Transfer Protocol (HTTP) over Transport Layer Security (TLS), also known as HTTPS and defined in [RFC2818](https://tools.ietf.org/html/rfc2818). FHIRcast is modeled on the webhook design pattern and specifically the [W3C WebSub RFC](https://www.w3.org/TR/websub/), such as its uses of GET vs POST interactions. FHIRcast also builds on the [HL7 SMART on FHIR launch protocol](http://www.hl7.org/fhir/smart-app-launch). 

An app subscribes to specific workflow events for a given session, the subscription is verified and the app is notified when those workflow events occur; for example, by the clinician opening a patient's chart. The subscring app may initiate context changes by accessing APIs exposed by the Hub. The app deletes its subscription when it no longer wants to receive notifications. In all cases the app authenticates to the Hub with an OAuth 2.0 bearer token. 

## Session Discovery

A session is an abstract concept representing a shared workspace, such as user's login session over multiple applications or a shared view of one application distributed to multiple users. FHIRcast requires a session to have a unique url as an identifier. This url is exchanged as the value of the `hub.topic` parameter. Before establishing a subscription, an app must not only know the `hub.topic`, but also the the `hub.url` which contains the base url of the hub. 

Systems SHOULD use SMART on FHIR to authorize, authenticate and exchange the `hub.url` and `hub.topic` urls as SMART on FHIR launch context parameters. If using SMART, the app SHALL either be launched from the driving application following the [SMART on FHIR EHR launch](http://www.hl7.org/fhir/smart-app-launch#ehr-launch-sequence) flow or the app may initiate the launch following the [SMART on FHIR standalone launch](http://www.hl7.org/fhir/smart-app-launch/#standalone-launch-sequence). In either case, the app SHALL request and, if authorized, SHALL be granted the `fhircast` OAuth2.0 scope. Accompanying this scope grant, the authorization server SHALL supply the `hub.url` and `hub.topic` SMART launch parameters alongside the access token. Per SMART, when scopes of `openid` and `fhirUser` are granted, the authorization server SHALL additionally send the current user's identity in an `id_token`.

If not using SMART on FHIR, the mechanism enabling the app to discover the `hub.url` and `hub.topic` is not defined in FHIRcast.

### SMART Launch Example
Note that the SMART launch parameters include the Hub's base url and and the session identifier in the `hub.url` and `hub.topic` fields.

```
{
  "access_token": "i8hweunweunweofiwweoijewiwe",
  "token_type": "bearer",
  "expires_in": 3600,
  "patient":  "123",
  "encounter": "456",
  "imagingstudy": "789",
  "hub.url" : "https://hub.example.com",
  "hub.topic": "https://hub.example.com/7jaa86kgdudewiaq0wtu",
}
```
Although FHIRcast works best with the SMART on FHIR launch and authorization process, implementation-specific launch, authentication, and authorization protocols may be possible. See [other launch scenarios](/launch-scenarios) for guidance.

## Subscribing and Unsubscribing

Subscribing consists of two exchanges:

* Subscriber requests a subscription at the `hub.url` url.
* Hub confirms the subscription was actually requested by the subscriber by contacting the `hub.callback` url. 

Unsubscribing works in the same way, except with a single parameter changed to indicate the desire to unsubscribe.

### Subscription Request
To create a subscription, the subscribing app SHALL perform an HTTP POST ([RFC7231](https://www.w3.org/TR/websub/#bib-RFC7231)) to the Hub's base url (as specified in `hub.url`) with the parameters in the table below.

This request SHALL have a `Content-Type` header of `application/x-www-form-urlencoded` and SHALL use the following parameters in its body, formatted accordingly:

Field | Optionality | Type | Description
---------- | ----- | -------- | --------------
`hub.callback` | Required | *string* | The Subscriber's callback URL where notifications should be delivered. The callback URL SHOULD be an unguessable URL that is unique per subscription.
`hub.mode` | Required | *string* | The literal string "subscribe" or "unsubscribe", depending on the goal of the request.
`hub.topic` | Required | *string* | The uri of the user's session that the subscriber wishes to subscribe to or unsubscribe from. 
`hub.secret` | Required | *string* | A subscriber-provided cryptographically random unique secret string that SHALL be used to compute an [HMAC digest](https://www.w3.org/TR/websub/#bib-RFC6151) delivered in each notification. This parameter SHALL be less than 200 bytes in length.
`hub.events` | Required | *string* | Comma-separated list of event types from the Event Catalog for which the Subscriber wants notifications.
`hub.lease_seconds` | Optional | *number* | Number of seconds for which the subscriber would like to have the subscription active, given as a positive decimal integer. Hubs MAY choose to respect this value or not, depending on their own policies, and MAY set a default value if the subscriber omits the parameter. 

If OAuth2 authentication is used, this POST request SHALL contain the Bearer access token in the HTTP Authorization header.

Hubs SHALL allow subscribers to re-request subscriptions that are already activated. Each subsequent and verified request to a Hub to subscribe or unsubscribe SHALL override the previous subscription state for a specific topic / callback URL combination.

The callback URL MAY contain arbitrary query string parameters (e.g., `?foo=bar&red=fish`). Hubs SHALL preserve the query string during subscription verification by appending new, Hub-defined, parameters to the end of the list using the `&` (ampersand) character to join. When sending the event notifications, the Hub SHALL make a POST request to the callback URL including any query string parameters in the URL portion of the request, not as POST body parameters.

The client that creates the subscription may not be the same system as the server hosting the callback url. (For example, some type of federated authorization model could possibly exist between these two systems.) However, in FHIRcast, the Hub assumes that the same authorization and access rights apply to both the subscribing client and the callback url.

#### Subscription Request Example
In this example, the app asks to be notified of the `open-patient-chart` and `close-patient-chart` events.
```
POST https://hub.example.com
Host: hub.example.com
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.callback=https%3A%2F%2Fapp.example.com%2Fsession%2Fcallback%2Fv7tfwuk17a&hub.mode=subscribe&hub.topic=https%3A%2F%2Fhub.example.com%2F7jaa86kgdudewiaq0wtu&hub.secret=shhh-this-is-a-secret&hub.events=patient-open-chart,patient-close-chart
```

### Subscription Response
If the Hub URL supports FHIRcast and is able to handle the subscription or unsubscription request, the Hub MUST respond to a subscription request with an HTTP 202 "Accepted" response to indicate that the request was received and will now be verified by the Hub. The Hub SHOULD perform the verification of intent as soon as possible.

If a Hub finds any errors in the subscription request, an appropriate HTTP error response code (4xx or 5xx) MUST be returned. In the event of an error, the Hub SHOULD return a description of the error in the response body as plain text, used to assist the client developer in understanding the error. This is not meant to be shown to the end user. Hubs MAY decide to reject some callback URLs or topic URIs based on their own policies.

#### Subscription Response Example
```
HTTP/1.1 202 Accepted
```

### Subscription Denial

If (and when) the subscription is denied, the Hub SHALL inform the subscriber by sending an HTTP GET request to the subscriber's callback URL as given in the subscription request. This request has the following query string arguments appended, to which the subscriber SHALL respond with an HTTP success (2xx) code.

Field | Optionality | Type | Description
--- | --- | --- | ---
`hub.mode` | Required | *string* | The literal string "denied".
`hub.topic` | Required | *string* | The topic uri given in the corresponding subscription request.
`hub.events` | Required | *string* | A comma-separated list of events from the Event Catalog corresponding to the events string given in the corresponding subscription request. 
`hub.reason` | Optional | *string* | The Hub may include a reason for which the subscription has been denied. The subscription MAY be denied by the Hub at any point (even if it was previously accepted). The Subscriber SHOULD then consider that the subscription is not possible anymore.

#### Subscription Denial Example
```
GET https://app.example.com/session/callback/v7tfwuk17a?hub.mode=denied&hub.topic=https%3A%2F%2Fhub.example.com%2F7jaa86kgdudewiaq0wtu&hub.events=open-patient-chart,close-patient-chart&hub.reason=session+unexpectedly+stopped HTTP 1.1
Host: subscriber
```

### Intent Verification
If the subscription is not denied, the Hub SHALL perform the verification of intent of the subscriber. The `hub.callback` url verification process ensures that the subscriber actually controls the callback url.

#### Intent Verification Request
In order to prevent an attacker from creating unwanted subscriptions on behalf of a subscriber (or unsubscribing desired ones), a hub must ensure that the subscriber did indeed send the subscription request. The hub SHALL verify a subscription request by sending an HTTPS GET request to the subscriber's callback URL as given in the subscription request. This request SHALL have the following query string arguments appended

Field | Optionality | Type | Description
---  | --- | --- | --- 
`hub.mode` | Required | *string* | The literal string "subscribe" or "unsubscribe", which matches the original request to the hub from the subscriber.
`hub.topic` | Required | *string* | The topic session uri given in the corresponding subscription request.
`hub.events` | Required | *string* | A comma-separated list of events from the Event Catalog corresponding to the events string given in the corresponding subscription request. 
`hub.challenge` | Required | *string* | A Hub-generated, random string that SHALL be echoed by the subscriber to verify the subscription.
`hub.lease_seconds` | Required | *number* | The Hub-determined number of seconds that the subscription will stay active before expiring, measured from the time the verification request was made from the Hub to the subscriber. If provided to the client, the Hub SHALL unsubscribe the client once lease_seconds has expired. If the subscriber wishes to continue the subscription it MAY resubscribe.

##### Intent Verification Request Example
```
GET https://app.example.com/session/callback/v7tfwuk17a?hub.mode=subscribe&hub.topic=7jaa86kgdudewiaq0wtu&hub.events=open-patient-chart,close-patient-chart&hub.challenge=meu3we944ix80ox&hub.lease_seconds=7200 HTTP 1.1
Host: subscriber
```

#### Intent Verification Response
If the `hub.topic` of the Intent Verification Request corresponds to a pending subscription or unsubscription that the subscriber wishes to carry out it SHALL respond with an HTTP success (2xx) code, a header of `Content-Type: text/html`, and a response body equal to the `hub.challenge` parameter. If the subscriber does not agree with the action, the subscriber SHALL respond with a 404 "Not Found" response.

The Hub SHALL consider other server response codes (3xx, 4xx, 5xx) to mean that the verification request has failed. If the subscriber returns an HTTP success (2xx) but the content body does not match the `hub.challenge` parameter, the Hub SHALL also consider verification to have failed.


##### Intent Verification Response Example
```
HTTP/1.1 200 OK
Content-Type: text/html

meu3we944ix80ox
```

### Unsubscribe

Once a subscribing app no longer wants to receive event notifications, it MUST unsubscribe from the session. The unsubscribe request message mirrors the subscribe request message with only a single difference: the `hub.mode` MUST be equal to the string _unsubscribe_.

#### Unsubscribe Request Example

```
POST https://hub.example.com
Host: hub
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.callback=https%3A%2F%2Fapp.example.com%2Fsession%2Fcallback%2Fv7tfwuk17a&hub.mode=unsubscribe&hub.topic=https%3A%2F%2Fhub.example.com%2F7jaa86kgdudewiaq0wtu&hub.secret=shhh-this-is-a-secret&hub.events=open-patient-chart,close-patient-chart

```


## Event Notification

The Hub SHALL notify subscribed apps of workflow events to which the app is subscribed, as the event occurs. The notification is an HTTPS POST containing a JSON object in the request body.

### Event Notification Request

Using the `hub.secret` from the subscription request, the hub SHALL generate an HMAC signature of the payload and include that signature in the request headers of the notification. The `X-Hub-Signature` header's value SHALL be in the form _method=signature_ where method is one of the recognized algorithm names and signature is the hexadecimal representation of the signature. The signature SHALL be computed using the HMAC algorithm ([RFC6151](https://www.w3.org/TR/websub/#bib-RFC6151)) with the request body as the data and the `hub.secret` as the key.

The notification to the subscriber SHALL include a description of the subscribed event that just occurred, an ISO 8601-2 formatted timestamp in UTC and an event identifier that is universally unique for the Hub. The timestamp MAY be used by subscribers to establish message affinity (message ordering) through the use of a message queue. The event identifier MAY be used to differentiate retried messages from user actions.

#### Event Notification Request Details

The notification's `hub.event` and `context` fields inform the subscriber of the current state of the user's session. The `hub.event` is a user workflow event, from the Event Catalog. The `context` is an array of named FHIR resources (similar to [CDS Hooks's context](https://cds-hooks.org/specification/1.0/#http-request_1) field) that describe the current content of the user's session. Each event in the [Event Catalog](#event-catalog) defines what context is expected in the notification. Hubs MAY use the [FHIR _elements parameter](https://www.hl7.org/fhir/search.html#elements) to limit the size of the data being passed while also including additional, local identifiers that are likely already in use in production implementations. Subscribers SHALL accept a full FHIR resource or the [_elements](https://www.hl7.org/fhir/search.html#elements)-limited resource as defined in the Event Catalog.

Field | Optionality | Type | Description
--- | --- | --- | ---
`timestamp` | Required | *string* | ISO 8601-2 timestamp in UTC describing the time at which the event occurred with subsecond accuracy. 
`id` | Required | *string* | Event identifier used to recognize retried notifications. This id SHALL be unique for the Hub, for example a GUID.
`event` | Required | *object* | A json object describing the event. See below.


Field | Optionality | Type | Description
--- | --- | --- | ---
`hub.topic` | Required | string | The topic session uri given in the subscription request. 
`hub.event`| Required | string | The event that triggered this notification, taken from the list of events from the subscription request.
`context` | Required | array | An array of named FHIR objects corresponding to the user's context after the given event has occurred. Common FHIR resources are: Patient, Encounter, ImagingStudy and List. The Hub SHALL only return FHIR resources that are authorized to be accessed with the existing OAuth2 access_token.

#### Event Notification Request Example

```
POST https://app.example.com/session/callback/v7tfwuk17a HTTP/1.1
Host: subscriber
X-Hub-Signature: sha256=dce85dc8dfde2426079063ad413268ac72dcf845f9f923193285e693be6ff3ae

{
  "timestamp": "2018-01-08T01:37:05.14",
  "id": "q9v3jubddqt63n1",
  "event": {
    "hub.topic": "https://hub.example.com/7jaa86kgdudewiaq0wtu",
    "hub.event": "open-patient-chart",
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

The subscriber MUST respond to the notification with an appropriate HTTP status code. In the case of a successful notification, the subscriber MUST respond with an HTTP [RFC7231] 2xx response code to indicate a success; otherwise, the subscriber MUST respond with an HTTP error status code. The Hub MAY use these statuses to track synchronization state.

#### Event Notification Response Example

```
HTTP/1.1 200 OK
```

## Event Notification Errors

All standard events are defined outside of the base FHIRcast specification in the [Event Catalog](../../events) with the single exception of the infrastructural `syncerror` event. 

If the subscriber cannot follow the context of the event, for instance due to an error or a deliberate choice to not follow a context, the subscriber SHALL respond with an HTTP error status code as described in [Event Notification Response](#event-notification-response). If the Hub does not receive a successful HTTP status from a event notification, it SHOULD generate a `syncerror` event to the other subscribers of that topic.

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
    "hub.topic": "https://hub.example.com/7jaa86kgdudewiaq0wtu",
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
              "diagnostics": "AppId3456 failed to follow context"
            }
          ]
        }
      }
    ]
  }
}
```

## Request Context Change

Similar to the Hub's notifications to the subscriber, the subscriber MAY request context changes with an HTTP POST to the `hub.topic` url. The Hub SHALL either accept this context change by responding with any successful HTTP status or reject it by responding with any 4xx or 5xx HTTP status. The subscriber SHALL be capable of gracefully handling a rejected context request. 

Once a requested context change is accepted, the Hub SHALL broadcast the context notification to all subscribers, including the original requestor. 

### Request Context Change Request
###### Request Context Change Parameters
Field | Optionality | Type | Description
--- | --- | --- | ---
`timestamp` | Required | *string* | ISO 8601-2 timestamp in UTC describing the time at which the event occurred with subsecond accuracy. 
`id` | Required | *string* | Event identifier used to recognize retried notifications. This id SHALL be uniquely generated by the subscriber and could be a GUID. Following an accepted context change request, the hub MAY re-use this value in the broadcasted event notifications.
`event` | Required | *object* | A json object describing the event. See [below](#request-context-change-event-object-parameters).

###### Request Context Change Event Object Parameters
Field | Optionality | Type | Description
--- | --- | --- | ---
`hub.topic` | Required | string | The topic session URI given in the subscription request. 
`hub.event`| Required | string | The event that triggered this request for the subscriber, taken from the list of events from the subscription request.
`context` | Required | array | An array of named FHIR objects corresponding to the user's context after the given event has occurred. Common FHIR resources are: Patient, Encounter, ImagingStudy and List. The subscriber SHALL only include FHIR resources that are authorized to be accessed with the existing OAuth2 `access_token`.

```
POST https://hub.example.com/7jaa86kgdudewiaq0wtu HTTP/1.1
Host: hub
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/json

{
  "timestamp": "2018-01-08T01:40:05.14",
  "id": "wYXStHqxFQyHFELh",
  "event": {
    "hub.topic": "https://hub.example.com/7jaa86kgdudewiaq0wtu",
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

## Events

FHIRcast describes an workflow event subscription and notification scheme towards the goal of improving a clinician's workflow across multiple disparate applications. The set of events defined here are not a closed set; anyone is able to define new events to fit their use cases and propose those events to the community. 

New events are proposed in a prescribed format using the [documentation template](../events/template) by submitting a [pull request](https://github.com/fhircast/docs/tree/master/docs/events). FHIRcast events are versioned, and mature according to the [Event Maturity Model](#event-maturity-model).

FHIRcast events are stateless. Context changes are a complete replacement of any previously communicated context, not "deltas". Understanding an event SHALL not require receiving a previous or future event. 

### Event Definition Format

Each event definition, specifies a single event name, a description of the workflow in which the event occurs, and contextual information associated with the event. FHIR is the interoperable data model used by FHIRcast. The context information associated with an event is communicated as subsets of FHIR resources. Event notifications SHALL include the elements of the FHIR resources defined in the context from the event definition. Event notification MAY include other elements of these resources. The source of these resources is the application's context or the FHIR server. The hub SHALL return FHIR resources from the application's context. If the resource is not part of the application's context, it SHALL read them from the FHIR server.

For example, when the [`ImagingStudy-open`](../../events/imagingstudy.open) event occurs, the notification sent to a subscriber SHALL include the ImagingStudy FHIR resource. Hubs SHOULD send the results of an ImagingStudy FHIR read using the *_elements* query parameter, like so:  `ImagingStudy/{id}?_elements=identifier,accession` and in accordance with the [FHIR specification](https://www.hl7.org/fhir/search.html#elements). 

A FHIR server may not support the *_elements* query parameter; a subscriber SHALL gracefully handle receiving a full FHIR resource in the context of a notification.

Each defined event in the standard event catalog SHALL be defined in the following format.

#### Event Definition Format: hook-name

Most FHIRcast events conform to an extensible syntax based upon FHIR resources. In the rare case where the FHIR data model doesn't describe content in the session, FHIRcast events MAY be statically named. For example, FHIR doesn't cleanly contain the concept of a user or user's session.  

FHIRcast events SHOULD conform to this extensible syntax, patterned after the SMART on FHIR scope syntax. Expressed in EBNF notation, the FHIRcast syntax for workflow related events is:

`hub.events ::= ( fhir-resource ) '-' ( 'open' | 'close' )`

![syntax for new events](../img/events-railroad.png)

Event names are unique and case-insensitive. Statically named events, specific to an organization, SHALL be named with reverse domain notation (e.g. `org.example.patient-transmogrify`). Reverse domain notation SHALL not be used by a standard event catalog. Statically named events SHALL not contain a dash ("-").

#### Event Definition Format: Workflow

Describe the workflow in which the event occurs. Event creators SHOULD include as much detail and clarity as possible to minimize any ambiguity or confusion amongst implementors.

#### Event Definition Format: Context

Describe the set of contextual data associated with this event. Only data logically and necessarily associated with the purpose of this workflow related event should be represented in context. An event SHALL contain all required data fields, MAY contain optional data fields and SHALL not contain any additional fields.
 
All fields available within an event's context SHALL be defined in a table where each field is described by the following attributes:

- **Key**: The name of the field in the context JSON object. Event authors SHOULD name their context fields to be consistent with other existing events when referring to the same context field.
- **Optionality**: A string value of either `REQUIRED`, `OPTIONAL` or `Required, if exists`
- **FHIR operation to generate context**: A FHIR read or search string illustrating the intended content of the event. 
- **Description**: A functional description of the context value. If this value can change according to the FHIR version in use, the description SHOULD describe the value for each supported FHIR version.

#### Event Maturity Model

The intent of the FHIRcast Event Maturity Model is to attain broad community engagement and consensus, before an event is labeled as mature, and to ensure that the event is necessary, implementable, and worthwhile to the systems that would reasonably be expected to use it. Implementer feedback should drive the maturity of new events. Diverse participation in open developer forums and events, such as HL7 FHIR Connectathons, is necessary to achieve significant implementer feedback. The below criteria will be evaluated with these goals in mind. 

Maturity Level | Maturity title | Requirements
--- | --- | ---
0 | Draft | Event is correctly [named](#event-naming) and [defined](#event-proposal-and-maturity). 
1 | Submitted  | _The above, and …_ Event definition is written up as a [github pull request](https://github.com/fhircast/docs/tree/master/docs/events) using the [Event template](../../events/template/) and community feedback is solicited on the [zulip FHIRcast stream](https://chat.fhir.org/#narrow/stream/179271-FHIRcast).
2 | Tested | _The above, and …_ The event has been tested and successfully supports interoperability among at least one hub and two independent subscribing apps using semi-realistic data and scenarios (e.g. at a FHIR Connectathon). The github pull request defining the event is approved and published.
3 | Considered |  _The above, and …_ At least 3 distinct organizations recorded ten distinct implementer comments (including a github issue, tracker item, or comment on the event definition page), including at least two hubs and three subscribing apps. The event has been tested at two connectathons.
4 | Documented | _The above, and …_ The author agrees that the artifact is sufficiently stable to require implementer consultation for subsequent non-backward compatible changes.  The event is implemented in the standard FHIRcast reference implementation and multiple prototype projects. The Event specification SHALL: <ul><ol>Identify a broad set of example contexts in which the event may be used with a minimum of three, but as many as 8-10.</ol><ol>Clearly differentiate the event from similar events or other standards to help an implementer determine if the event is correct for their scenario.</ol><ol>Explicitly document example scenarios when the event should not be used.</ol></ul>
5 | Mature | _The above, and ..._ The event has been implemented in production in at least two hubs and three independent subscribing apps. An HL7 working group ballots the event and the event has passed HL7 STU ballot.
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


