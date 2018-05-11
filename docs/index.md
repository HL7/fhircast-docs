<img style="float: left;padding-right: 5px;" src="img/hl7logo.gif" width=40px" />
# FHIRcast - _modern, simple application context synchronization_

## Overview
FHIRcast synchronizes healthcare applications in real time to show the same clinical content to a common user. For example, a radiologist often works in three disparate applications at the same time (a radiology information system, a PACS and a dictation system), she wants each of these three systems to display the same study or patient at the same time. FHIRcast isn't limited to radiology use-cases. Modeled after the common webhook design pattern and specifically the [W3C WebSub RFC](https://www.w3.org/TR/websub/), FHIRcast naturally extends the SMART on FHIR launch protocol to achieve tight integration between disparate, full-featured applications. FHIRcast builds on the [CCOW](https://en.wikipedia.org/wiki/CCOW) abstract model to specify an http-based and simple context synchronization specification that doesn't require a separate context manager. 

Adopting the WebSub terminology, the below describes an app as a subscriber synchronizing with an EHR in the role of a hub, but any user-facing application can synchronize with FHIRcast. While less common,  bidirectional communication between multiple applications is also possible.

### Why?
The large number of vendor-specific or proprietary context synchronization methods in production limit the industry's ability to enhance the very large number of integrations currently in production. In practice, these integrations are decentralized and simple. 

## Synchronize
An app subscribes to specific workflow events for a given user's session, the subscription is verified and the app is then notified when those workflow events occur; for example, by the clinician opening a patient's chart. The app deletes its subscription when it no longer wants to receive notifications.
[TODO: Simple, attractive image illustrating actors and key interactions]

### EHR launches SMART on FHIR App
The EHR launches the app following the standard [SMART on FHIR EHR launch](http://www.hl7.org/fhir/smart-app-launch#ehr-launch-sequence) flow, including identifying the current EHR user using OpenID Connect. As part of the app launch, alongside the acess_token the EHR's authorization server identifies the base url to the hub, a unique, opaque identifier to the current user's session, 

#### SMART launch parameters include hub base url and session identifier
```
{
  "access_token": "i8hweunweunweofiwweoijewiwe",
  "token_type": "bearer",
  "expires_in": 3600,
  "patient":  "123",
  "encounter": "456",
  "imagingstudy": "789",
  "cast-hub" : "https://hub.example.com",
  "cast-session": "https://hub.example.com/7jaa86kgdudewiaq0wtu",
}
```
Although FHIRcast works best with the SMART on FHIR launch and authorization process, it can also be used with implementation-specific launch and authz protocols. See [other launch scenarios]().

### App subscribes to session
In this example, the app asks to be notified of the patient-chart-open and patient-chart-close events.  Note that the bearer access_token used to authenticate to the Hub was initially granted during the SMART launch.

Subscriber performs an HTTP POST to the hub base url with the following parameters.

Field | Optionality | Type | Description
---------- | ----- | -------- | --------------
`hub.callback` | Required | *string* | The Subscriber's callback URL where notifications should be delivered. The callback URL SHOULD be an unguessable URL that is unique per subscription.
`hub.mode` | Required | *string* | The literal string "subscribe" or "unsubscribe", depending on the goal of the request.
`hub.topic` | Required | *string* | The uri of the user's session that the subscriber wishes to subscribe to or unsubscribe from. 
`hub.secret` | Required | *string* | A subscriber-provided cryptographically random unique secret string that will be used to compute an HMAC digest delivered in each notification. This parameter MUST be less than 200 bytes in length.
`hub.events` | Required | *string* | Comma-separated list of event types from the Event Catalog for which the Subscriber wants notifications.
`hub.lease_seconds` | Optional | *number* | Number of seconds for which the subscriber would like to have the subscription active, given as a positive decimal integer. Hubs MAY choose to respect this value or not, depending on their own policies, and MAY set a default value if the subscriber omits the parameter. 

Hubs MUST allow subscribers to re-request subscriptions that are already activated. Each subsequent request to a hub to subscribe or unsubscribe MUST override the previous subscription state for a specific topic, and callback URL combination once the action is verified. 

The callback URL MAY contain arbitrary query string parameters (e.g., ?foo=bar&red=fish). Hubs MUST preserve the query string during subscription verification by appending new parameters to the end of the list using the & (ampersand) character to join. When sending the content distribution request, the hub will make a POST request to the callback URL including any query string parameters in the URL portion of the request, not as POST body parameters.

```
POST https://hub.example.com
Host: hub.example.com
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.callback=https%3A%2F%2Fapp.example.com%2Fsession%2Fcallback%2Fv7tfwuk17a&hub.mode=subscribe&hub.topic=https%3A%2F%2Fhub.example.com%2F7jaa86kgdudewiaq0wtu&hub.secret=shhh-this-is-a-secret&hub.events=patient-open-chart,patient-close-chart
```

#### Hub responds with successful creation
If the hub URL supports FHIRcast and is able to handle the subscription or unsubscription request, it MUST respond to a subscription request with an HTTP 202 "Accepted" response to indicate that the request was received and will now be verified by the hub. The hub SHOULD perform the verification of intent as soon as possible.

If a hub finds any errors in the subscription request, an appropriate HTTP error response code (4xx or 5xx) MUST be returned. In the event of an error, hubs SHOULD return a description of the error in the response body as plain text, used to assist the client developer in understanding the error. This is not meant to be shown to the end user. Hubs MAY decide to reject some callback URLs or topic URIs based on their own policies.

```
HTTP/1.1 202 Accepted
```

### Hub may cancel subscription

If (and when) the subscription is denied, the hub MUST inform the subscriber by sending an HTTP GET request to the subscriber's callback URL as given in the subscription request. This request has the following query string arguments appended.

Field | Optionality | Type | Description
--- | --- | --- | ---
`hub.mode` | Required | *string* | The literal string "denied".
`hub.topic` | Required | *string* | The topic uri given in the corresponding subscription request.
`hub.events` | Required | *string* | A comma-separated list of events from the Event Catalog corresponding to the events string given in the corresponding subscription request. 
`hub.reason` | Optional | *string* | The hub may include a reason for which the subscription has been denied. The subscription MAY be denied by the hub at any point (even if it was previously accepted). The Subscriber SHOULD then consider that the subscription is not possible anymore.

```
GET https://app.example.com/session/callback/v7tfwuk17a?hub.mode=denied&hub.topic=https%3A%2F%2Fhub.example.com%2F7jaa86kgdudewiaq0wtu&hub.events=patient-open-chart,patient-close-chart&hub.challenge=meu3we944ix80ox&hub.reason=session+unexpectedly+stopped HTTP 1.1
Host: subscriber
```


#### Hub verifies callback url
If (and when) the subscription is accepted, the hub MUST perform the verification of intent of the subscriber. The hub.callback url verification process ensures that the subscriber actually controls the callback url.

In order to prevent an attacker from creating unwanted subscriptions on behalf of a subscriber (or unsubscribing desired ones), a hub must ensure that the subscriber did indeed send the subscription request. The hub verifies a subscription request by sending an HTTPS GET request to the subscriber's callback URL as given in the subscription request. This request has the following query string arguments appended:

Field | Optionality | Type | Description
---  | --- | --- | --- 
`hub.mode` | Required | *string* | The literal string "subscribe" or "unsubscribe", which matches the original request to the hub from the subscriber.
`hub.topic` | Required | *string* | The topic session uri given in the corresponding subscription request.
`hub.events` | Required | *string* | A comma-separated list of events from the Event Catalog corresponding to the events string given in the corresponding subscription request. 
`hub.challenge` | Required | *string* | A hub-generated, random string that MUST be echoed by the subscriber to verify the subscription.
`hub.lease_seconds` | Required | *number* | The hub-determined number of seconds that the subscription will stay active before expiring, measured from the time the verification request was made from the hub to the subscriber. Subscribers must renew their subscription before the lease seconds period is over to avoid interruption. 

```
GET https://app.example.com/session/callback/v7tfwuk17a?hub.mode=subscribe&hub.topic=7jaa86kgdudewiaq0wtu&hub.events=patient-open-chart,patient-close-chart&hub.challenge=meu3we944ix80ox HTTP 1.1
Host: subscriber
```

The subscriber MUST confirm that the hub.topic corresponds to a pending subscription or unsubscription that it wishes to carry out. If so, the subscriber MUST respond with an HTTP success (2xx) code with a response body equal to the hub.challenge parameter. If the subscriber does not agree with the action, the subscriber MUST respond with a 404 "Not Found" response.

```
HTTP/1.1 200 Success
Content-Type: text/html

meu3we944ix80ox
```

The hub MUST consider other server response codes (3xx, 4xx, 5xx) to mean that the verification request has failed. If the subscriber returns an HTTP success (2xx) but the content body does not match the hub.challenge parameter, the hub MUST also consider verification to have failed.

### Workflow event occurs and subscriber is notified

In addition to a description of the subscribed event that just occurred, the notification to the subscriber also includes an ISO 8601 formatted timestamp in UTC and an event identifer that is universally unique for the hub. The timestamp should be used by subscribers to establish message affinity through the use of a message queue. The event identifier should be used to differentiate retried messages from user actions. 

Using the hub.secret from the subscription request, the hub MUST generate an HMAC signature of the payload and include that signature in the request headers of the notification. The X-Hub-Signature header's value MUST be in the form method=signature where method is one of the recognized algorithm names and signature is the hexadecimal representation of the signature. The signature MUST be computed using the HMAC algorithm [RFC6151](https://www.w3.org/TR/websub/#bib-RFC6151)  with the request body as the data and the hub.secret as the key.

Field | Optionality | Type | Description
--- | --- | --- | ---
`timestamp` | Required | *string* | ISO 8601 timestamp in UTC describing the time at which the event occurred with subsecond accuracy. 
`id` | Required | *string* | Event identifier used to recognize retried notifications. This id MUST be globally unique for the hub, SHOULD be opaque to the subscriber and MAY be a GUID.
`event` | Required | *object* | A json object describing the event. See below.


Field | Optionality | Type | Description
--- | --- | --- | ---
hub.topic | Required | string | The topic session uri given in the subscription request. 
hub.event| Required | string | The event that triggered this notification, taken from the list of events from the subscription request.
context | Required | array | An array of named FHIR objects corresponding to the user's context after the given event has occurred. Common FHIR resources are: Patient, Encounter, ImagingStudy and List. The hub MUST only return FHIR resources that can be accessed with the existing OAuth2 access_token.

#### What just happened in the user's session?
The notification's hub.event and context fields inform the subscriber of the current state of the user's session. The hub.event is a user workflow event, from the Event Catalog. The context is an array of named FHIR objects (similar to [CDS Hooks's context](https://cds-hooks.org/specification/1.0/#http-request_1) field) that describe the current content of the user's session. Each event in the Event Catalog defines what context is expected in the notification. The context makes heavy use of the [FHIR _elements parameter](https://www.hl7.org/fhir/search.html#elements) to limit the size of the data being passed while also including additional, local identifiers that are likely already in use in production implementations. 


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
              "system": "urn:oid:1.2.840.114350",
              "value": "185444"
            },
            {
              "system": "urn:oid:1.2.840.114350.1.13.861.1.7.5.737384.27000",
              "value": "2667"
            }
          ]
        }
      }
    ]
  }
}
```

### App requests context change

Similar to the Hub's notifications to the subscriber, the subscriber can request context changes by POSTing to the `hub.topic` url. The Hub accepts this context change by responding with any successful HTTP status and rejects it by responding with any 4xx or 5xx HTTP status. The subscriber MUST be capable of gracefully handling a rejected context request. 

Once a requested context change is accepted, the Hub will broadcast the context notification to all subscribers, including the original requestor. 

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
              "system": "urn:oid:1.2.840.114350",
              "value": "1345687"
            },
            {
              "system": "urn:oid:1.2.840.114350.1.13.861.1.7.5.737384.27000",
              "value": "7539"
            }
          ]
        }
      }
    ]
  }
}
```

### App unsubscribes from session

Note that this is the same as the subscription request with the single difference that the hub.mode MUST be equal to the string _unsubscribe_.
```
POST https://hub.example.com
Host: hub
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/x-www-form-urlencoded

hub.callback=https%3A%2F%2Fapp.example.com%2Fsession%2Fcallback%2Fv7tfwuk17a&hub.mode=unsubscribe&hub.topic=https%3A%2F%2Fhub.example.com%2F7jaa86kgdudewiaq0wtu&hub.secret=shhh-this-is-a-secret&hub.events=patient-open-chart,patient-close-chart

```
## Event Catalog
Each  event definition in the catalog, below, specifies a single event name, a description of the event, and the  required or optional contextual information associated with the event. Alongside the event name, the contextual information is used by the subscriber.

FHIR is the interoperable data model used by FHIRcast. The fields within `context` are subsets of FHIR resources. Hubs MUST send the results of FHIR reads in the context, as specified below. For example, when the open-image-study event occurs, the notification sent to a subscriber MUST include the ImagingStudy FHIR resource. Hubs SHOULD send the results of an ImagingStudy FHIR read using the _\_elements\_ query parameter, like so:  `ImagingStudy/{id}?_elements=identifier,accession` and in accordance with the [FHIR specification](https://www.hl7.org/fhir/search.html#elements). 

A FHIR server may not support the *\_elements* query parameter; a subscriber MUST gracefully handle receiving a full FHIR resource in the context of a notification.

### open-patient-chart
#### Description: 
User opened patient's medical record. 
#### Example: 
```
{
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
    }
  ]
}
```

Context | Optionality | FHIR operation to generate context|  Description
--- | --- | --- | ---
`patient` | Required| `Patient/{id}?\_elements=identifier` | FHIR Patient resource describing the patient whose chart is currently in context.
`encounter` | Optional | `Encounter/{id}?\_elements=identifier` | FHIR Encounter resource in context in the newly opened patient's chart.


### switch-patient-chart

#### Description: 
User changed from one open patient's medical record to another previously opened patient's medical record. The context documents the patient whose record is currently open.
#### Example: 
```
{
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
    }
  ]
}
```

Context | Optionality | FHIR operation to generate context|  Description
--- | --- | --- | ---
`patient` | Required |  `Patient/{id}?\_elements=identifier` | FHIR Patient resource describing the patient whose chart is currently in context..
`encounter` | Optional | `Encounter/{id}?\_elements=identifier` | FHIR Encounter resource in context in the newly opened patient's chart.


### close-patient-chart

#### Description: User closed patient's medical record. 

#### Example: 
```
{ }
```

No context.

### open-imaging-study
#### Description: User opened record of imaging study.
#### Example: 
```
{
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
```

Context | Optionality | FHIR operation to generate context|  Description
--- | --- | --- | ---
`patient` | Optional| `Patient/{id}?_elements=identifier`| FHIR Patient resource describing the patient whose chart is currently in context.
`study` | Required | `ImagingStudy/{id}?_elements=identifier,accession` | FHIR ImagingStudy resource in context. Note that in addition to the request identifier and accession elements, the DICOM uid and FHIR patient reference are included because they're required by the FHIR specification. 

### switch-imaging-study
#### Description: User changed from one open imaging study to another previously opened imaging study. The context documents the study, and optionally patient, for the currently open record.
#### Example: 
```
{
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
```

Context | Optionality | FHIR operation to generate context|  Description
--- | --- | --- | ---
`patient` | Optional| `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose chart is currently in context.
`study` | Required | `ImagingStudy/{id}?_elements=identifier,accession` | FHIR ImagingStudy resource in context. Note that in addition to the request identifier and accession elements, the DICOM uid and FHIR patient reference are included because they're required by the FHIR specification. 

### close-imaging-study

#### Description: User closed imaging study.

#### Example: 
```
{
 }
```

No context.

### user-logout
#### Description: User gracefully exited the application.
#### Example: 
{
}


No Context 

### user-hibernate
#### Description: User temporarily suspended her session. The user's session will eventually resume.
#### Example: 
{
}

No Context 


## Get involved
* [Log issues, contribute via github](https://github.com/fhircast)
* [Converse at chat.fhir.org](https://chat.fhir.org/#narrow/stream/subscriptions)

