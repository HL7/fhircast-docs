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

