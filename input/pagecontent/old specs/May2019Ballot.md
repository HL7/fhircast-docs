<img style="float: left;padding-right: 5px;" src="/img/hl7-logo-header.png" width=90px" />
# FHIRcast

> "1.0 Draft" This is the draft of the 1.0 release of the FHIRcast specification. We are currently working towards a 1.0 release and would love your feedback and proposed changes. Look at our [current issue list](https://github.com/fhircast/docs/issues) and get involved!

## Overview
The FHIRcast specification describes the APIs and interactions to synchronize healthcare applications in real time to show the same clinical content to a user. All data exchanged through the HTTP APIs MUST be sent and received as [JSON](https://tools.ietf.org/html/rfc8259) structures, and MUST be transmitted over channels secured using the Hypertext Transfer Protocol (HTTP) over Transport Layer Security (TLS), also known as HTTPS and defined in [RFC2818](https://tools.ietf.org/html/rfc2818). FHIRcast is modeled on the webhook design pattern and specifically the [W3C WebSub RFC](https://www.w3.org/TR/websub/) and builds on the [HL7 SMART on FHIR launch protocol](http://www.hl7.org/fhir/smart-app-launch). 

An app subscribes to specific workflow events for a given session, the subscription is verified and the app is notified when those workflow events occur; for example, by the clinician opening a patient's chart. The subscring app may query a session's current context and initiate context changes by accessing APIs exposed by the Hub. The app deletes its subscription when it no longer wants to receive notifications. In all cases the app authenticates to the Hub with an OAuth 2.0 bearer token. 

## Session Discovery
Before establishing a subscription, an app must know the `hub.topic` which is an unique url identifying the session, and the `cast-hub` which is the base url of the Hub. The app discovers these two urls as part of a SMART on FHIR launch. 

The app MUST either be launched from the driving application following the [SMART on FHIR EHR launch](http://www.hl7.org/fhir/smart-app-launch#ehr-launch-sequence) flow or the app may initiate the launch following the [SMART on FHIR standalone launch](http://www.hl7.org/fhir/smart-app-launch/#standalone-launch-sequence). In either case, the app MUST request and be granted the `fhircast` OAuth2.0 scope. Accompanying this scope grant, the authorization server MUST supply the `cast-hub` and `hub.topic` SMART launch parameters alongside the access token. These parameters identify the Hub's base url, and a unique, opaque identifier of the current user's session, respectivly. Per SMART, when scopes of `openid` and `fhirUser` are granted, the app will additionally receive the current user's identity in an `id_token`.

### SMART Launch Example
Note that the SMART launch parameters include the Hub's base url and and the session identifier in the `cast-hub` and `hub.topic` fields.

```
{
  "access_token": "i8hweunweunweofiwweoijewiwe",
  "token_type": "bearer",
  "expires_in": 3600,
  "patient":  "123",
  "encounter": "456",
  "imagingstudy": "789",
  "cast-hub" : "https://hub.example.com",
  "hub.topic": "https://hub.example.com/7jaa86kgdudewiaq0wtu",
}
```
Although FHIRcast works best with the SMART on FHIR launch and authorization process, implementation-specific launch, authentication, and authorization  protocols may be possible. See [other launch scenarios](/launch-scenarios) for guidance.

## Subscribing and Unsubscribing

Subscribing consists of two exchanges:

* Subscriber requests a subscription at the `cast-hub` url.
* Hub confirms the subscription was actually requested by the subscriber by contacting the `hub.callback` url. 

Unsubscribing works in the same way, except with a single parameter changed to indicate the desire to unsubscribe.

### Subscription Request
To create a subscription, the subscribing app performs an HTTP POST ([RFC7231](https://www.w3.org/TR/websub/#bib-RFC7231)) to the Hub's base url (as specified in `cast-hub`) with the following parameters, authenticating with the Bearer access token.

This request MUST have a Content-Type header of _application/x-www-form-urlencoded_  and MUST use the following parameters in its body, formatted accordingly:

###### Subscription Request Parameters
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

Within FHIRcast, the client that creates a subscription and the server that hosts the callback url are the same entity. If these roles are split, the Hub assumes that the same authorization and access rights apply to both systems. 

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

If (and when) the subscription is denied, the Hub MUST inform the subscriber by sending an HTTP GET request to the subscriber's callback URL as given in the subscription request. This request has the following query string arguments appended.

###### Subscription Denial Parameters
Field | Optionality | Type | Description
--- | --- | --- | ---
`hub.mode` | Required | *string* | The literal string "denied".
`hub.topic` | Required | *string* | The topic uri given in the corresponding subscription request.
`hub.events` | Required | *string* | A comma-separated list of events from the Event Catalog corresponding to the events string given in the corresponding subscription request. 
`hub.reason` | Optional | *string* | The Hub may include a reason for which the subscription has been denied. The subscription MAY be denied by the Hub at any point (even if it was previously accepted). The Subscriber SHOULD then consider that the subscription is not possible anymore.

#### Subscription Denial Example
```
GET https://app.example.com/session/callback/v7tfwuk17a?hub.mode=denied&hub.topic=https%3A%2F%2Fhub.example.com%2F7jaa86kgdudewiaq0wtu&hub.events=open-patient-chart,close-patient-chart&hub.challenge=meu3we944ix80ox&hub.reason=session+unexpectedly+stopped HTTP 1.1
Host: subscriber
```

### Intent Verification
If (and when) the subscription is accepted, the Hub MUST perform the verification of intent of the subscriber. The `hub.callback` url verification process ensures that the subscriber actually controls the callback url.

#### Intent Verification Request
In order to prevent an attacker from creating unwanted subscriptions on behalf of a subscriber (or unsubscribing desired ones), a Hub must ensure that the subscriber did indeed send the subscription request. The Hub verifies a subscription request by sending an HTTPS GET ([RFC2818](https://www.w3.org/TR/websub/#bib-RFC2818)) request to the subscriber's callback URL as given in the subscription request. This request has the following query string arguments appended:

###### Verification Parameters
Field | Optionality | Type | Description
---  | --- | --- | --- 
`hub.mode` | Required | *string* | The literal string "subscribe" or "unsubscribe", which matches the original request to the hub from the subscriber.
`hub.topic` | Required | *string* | The topic session uri given in the corresponding subscription request.
`hub.events` | Required | *string* | A comma-separated list of events from the Event Catalog corresponding to the events string given in the corresponding subscription request. 
`hub.challenge` | Required | *string* | A Hub-generated, random string that MUST be echoed by the subscriber to verify the subscription.
`hub.lease_seconds` | Required | *number* | The Hub-determined number of seconds that the subscription will stay active before expiring, measured from the time the verification request was made from the Hub to the subscriber. Subscribers must renew their subscription before the lease seconds period is over to avoid interruption. 

##### Intent Verification Request Example
```
GET https://app.example.com/session/callback/v7tfwuk17a?hub.mode=subscribe&hub.topic=7jaa86kgdudewiaq0wtu&hub.events=open-patient-chart,close-patient-chart&hub.challenge=meu3we944ix80ox HTTP 1.1
Host: subscriber
```

#### Intent Verification Response
The subscriber MUST confirm that the `hub.topic` corresponds to a pending subscription or unsubscription that it wishes to carry out. If so, the subscriber MUST respond with an HTTP success (2xx) code with a response body equal to the `hub.challenge` parameter. If the subscriber does not agree with the action, the subscriber MUST respond with a 404 "Not Found" response.

The Hub MUST consider other server response codes (3xx, 4xx, 5xx) to mean that the verification request has failed. If the subscriber returns an HTTP success (2xx) but the content body does not match the `hub.challenge` parameter, the Hub MUST also consider verification to have failed.


##### Intent Verification Response Example
```
HTTP/1.1 200 Success
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

The Hub MUST notify subscribed apps of workflow events to which the app is subscribed, as the event occurs. The notification is an HTTPS POST containing a JSON object in the request body.

### Event Notification Request

Using the hub.secret from the subscription request, the hub MUST generate an HMAC signature of the payload and include that signature in the request headers of the notification. The `X-Hub-Signature` header's value MUST be in the form _method=signature_ where method is one of the recognized algorithm names and signature is the hexadecimal representation of the signature. The signature MUST be computed using the HMAC algorithm ([RFC6151](https://www.w3.org/TR/websub/#bib-RFC6151)) with the request body as the data and the `hub.secret` as the key.

In addition to a description of the subscribed event that just occurred, the notification to the subscriber MUST include an [ISO 8601-2](https://www.iso.org/iso-8601-date-and-time-format.html) formatted timestamp in UTC and an event identifer that is universally unique for the Hub. See the [notification parameters table](#notification-parameters) for details. The timestamp should be used by subscribers to establish message affinity through the use of a message queue. The event identifier should be used to differentiate retried messages from user actions. 


#### Event Notification Request Details

The notification's `hub.event` and `context` fields inform the subscriber of the current state of the user's session. The `hub.event` is a user workflow event, from the Event Catalog. The `context` is an array of named FHIR objects (similar to [CDS Hooks's context](https://cds-hooks.org/specification/1.0/#http-request_1) field) that describe the current content of the user's session. Each event in the [Event Catalog](#event-catalog) defines what context is expected in the notification. Hubs MAY use the [FHIR _elements parameter](https://www.hl7.org/fhir/search.html#elements) to limit the size of the data being passed while also including additional, local identifiers that are likely already in use in production implementations. Subscribers MUST accept a full FHIR resource or the [_elements](https://www.hl7.org/fhir/search.html#elements)-limited resource as defined in the Event Catalog.

###### Notification Parameters
Field | Optionality | Type | Description
--- | --- | --- | ---
`timestamp` | Required | *string* | ISO 8601-2 timestamp in UTC describing the time at which the event occurred with subsecond accuracy. 
`id` | Required | *string* | Event identifier used to recognize retried notifications. This id MUST be globally unique for the Hub, SHOULD be opaque to the subscriber and MAY be a GUID.
`event` | Required | *object* | A json object describing the event. See [below](#event-object-parameters).

###### Event Object Parameters
Field | Optionality | Type | Description
--- | --- | --- | ---
`hub.topic` | Required | string | The topic session uri given in the subscription request. 
`hub.event`| Required | string | The event that triggered this notification, taken from the list of events from the subscription request.
`context` | Required | array | An array of named FHIR objects corresponding to the user's context after the given event has occurred. Common FHIR resources are: Patient, Encounter, ImagingStudy and List. The Hub MUST only return FHIR resources that are authorized to be accessed with the existing OAuth2 access_token.

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

The subscriber MUST respond to the notification with an appropriate HTTP status code. In the case of a successful notification, the subscriber MUST respond with an HTTP 200; otherwise, the subscriber MUST respond with an HTTP error status code. The Hub MAY use these statuses to track synchronization state.

#### Event Notification Response Example

```
HTTP/1.1 200 Accepted
```

## Query for Current Context

In addition to receiving notification of events as they occur, a subscribing app may request the current context of a given session. The client queries the Hub's `hub.topic` url to receive the current context for the session. Event-driven context notifications should take precedence. Note that no `hub.event` is present in the response.

### Query for Current Context Example

```
GET https://hub.example.com/7jaa86kgdudewiaq0wtu 
Host: hub
Authorization: Bearer i8hweunweunweofiwweoijewiwe
```

```
{
   "timestamp":"2018-01-08T01:40:05.14",
   "id":"wYXStHqxFQyHFELh",
   "event":{
      "hub.topic":"https://hub.example.com/7jaa86kgdudewiaq0wtu",
      "context":[
         {
            "key":"patient",
            "resource":{
               "resourceType":"Patient",
               "id":"798E4MyMcpCWHab9",
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
         },
         {
            "key":"encounter",
            "resource":{
               "resourceType":"Encounter",
               "id":"ecgXt3jVqNNpsXnNXZ3KljA3",
               "identifier":[
                  {
                     "use":"usual",
                     "system":"http://healthcare.example.org/identifiers/encounter",
                     "value":"1853"
                  }
               ]
            }
         },
         {
            "key":"study",
            "resource":{
               "resourceType":"ImagingStudy",
               "id":"8i7tbu6fby5ftfbku6fniuf",
               "uid":"urn:oid:2.16.124.113543.6003.1154777499.30246.19789.3503430045",
               "accession":{
                  "use":"usual",
                  "type":{
                     "coding":[
                        {
                           "system":"http://hl7.org/fhir/v2/0203",
                           "code":"ACSN"
                        }
                     ]
                  }
               },
               "identifier":[
                  {
                     "system":"7678",
                     "value":"185444"
                  }
               ]
            }
         }
      ]
   }
}
```


## Request Context Change

Similar to the Hub's notifications to the subscriber, the subscriber MAY request context changes with an HTTP POST to the `hub.topic` url. The Hub MUST either accept this context change by responding with any successful HTTP status or reject it by responding with any 4xx or 5xx HTTP status. The subscriber MUST be capable of gracefully handling a rejected context request. 

Once a requested context change is accepted, the Hub MUST broadcast the context notification to all subscribers, including the original requestor. 

### Request Context Change Request

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

## Event Notification Errors

If the subscriber cannot follow the context of the event, for instance due to an error or a deliberate choice to not follow a context, the subscriber MAY respond with a 'sync-error' event. The Hub MAY use these events to track synchronization state and MAY also forward these events to other subscribers of the same topic.

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
    "hub.event": "sync-error",
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

## Event Catalog
Each event definition in the catalog, below, specifies a single event name, a description of the event, and the  required or optional contextual information associated with the event. Alongside the event name, the contextual information is used by the subscriber.

FHIR is the interoperable data model used by FHIRcast. The fields within `context` are subsets of FHIR resources. Hubs MUST send the results of FHIR reads in the context, as specified below. For example, when the `open-image-study` event occurs, the notification sent to a subscriber MUST include the ImagingStudy FHIR resource. Hubs SHOULD send the results of an ImagingStudy FHIR read using the *_elements* query parameter, like so:  `ImagingStudy/{id}?_elements=identifier,accession` and in accordance with the [FHIR specification](https://www.hl7.org/fhir/search.html#elements). 

A FHIR server may not support the *_elements* query parameter; a subscriber MUST gracefully handle receiving a full FHIR resource in the context of a notification.

The name of the event SHOULD succinctly and clearly describe the activity or event. Event names are unique so event creators SHOULD take care to ensure newly proposed events do not conflict with an existing event name. Event creators SHALL name their event with reverse domain notation (e.g. `org.example.patient-transmogrify`) if the event is specific to an organization. Reverse domain notation SHALL not be used by a standard event catalog.

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
```

Context | Optionality | FHIR operation to generate context|  Description
--- | --- | --- | ---
`patient` | Required| `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose chart is currently in context.
`encounter` | Optional | `Encounter/{id}?_elements=identifier` | FHIR Encounter resource in context in the newly opened patient's chart.


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
```

Context | Optionality | FHIR operation to generate context|  Description
--- | --- | --- | ---
`patient` | Required |  `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose chart is currently in context..
`encounter` | Optional | `Encounter/{id}?_elements=identifier` | FHIR Encounter resource in context in the newly opened patient's chart.


### close-patient-chart

#### Description: User closed patient's medical record. 

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
```

Context | Optionality | FHIR operation to generate context|  Description
--- | --- | --- | ---
`patient` | Required |  `Patient/{id}?_elements=identifier` | FHIR Patient resource describing the patient whose chart is currently in context..
`encounter` | Optional | `Encounter/{id}?_elements=identifier` | FHIR Encounter resource in context in the newly opened patient's chart.

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

### sync-error
#### Description: A syncronization error has been detected. Inform subscribed clients.
#### Example: 
```
{
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
```

Context | Optionality | FHIR operation to generate context|  Description
--- | --- | --- | ---
`operationoutcome` | Optional |  `OperationOutcome` | FHIR resource describing an outcome of an unsuccessful system action..
