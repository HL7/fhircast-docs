The Subscriber MAY request a context change, content change, or `select` event by sending the Hub a FHIRcast event notification.

### Request Context Change

The Subscriber MAY request context changes with an HTTP POST to the `hub.url`. The Hub SHALL either accept this context change by responding with any successful HTTP status or reject it by responding with any 4xx or 5xx HTTP status. Similar to event notifications, described above, the Hub MAY also respond with a 202 (Accepted) status, process the request, and then later, instead of broadcasting the context change, responds with a `SyncError` event in order to reject the request. In this specific case in which the context change is rejected by the Hub and not broadcasted, the `SyncError` would only be sent to the requesting Subscriber. The Subscriber SHALL be capable of gracefully handling a rejected context request. 

Once a requested context change is accepted, the Hub SHALL broadcast the context notification to all Subscribers, including the original requesting Subscriber. The requesting Subscriber can use the broadcasted notification as confirmation of their request. The Hub reusing the request's `id` is further confirmation to the requesting Subscriber that the event is a result of their request.

<figure>
  {% include EventNotificationSequence.svg %}
  <figcaption><b>Figure: Event Notification Sequence</b></figcaption>
  <p></p>
</figure>

### Request Context Change body

The format of the Request Context Change request is presented below.

{:.grid}
Field       | Optionality | Type     | Description
----------- | ----------- | -------- | ---
`timestamp` | Required    | *string* | ISO 8601-2 timestamp in UTC describing the time at which the event occurred.
`id`        | Required    | *string* | Event identifier, which MAY be used to recognize retried notifications. This id SHALL be uniquely generated by the Subscriber and could be a UUID. Following an accepted context change request, the Hub SHALL re-use this value in the broadcasted event notification.
`event`     | Required    | *object* | A JSON object describing the event as defined in [Event Definition](2-3-Events.html).

Hubs and Subscribers SHALL be case insensitive for event-names.

A Subscriber that initiates a context change and receives a `SyncError` related to a context change event it sent, SHOULD resend this event at regular intervals until sync is reestablished or another, newer, event has been received. It is recommended to wait at least 10 seconds before resending the event. Note that such resend will use the timestamp of the original event to prevent race conditions.

### Request Context Change example

#### Request

```http
POST https://hub.example.com HTTP/1.1
Host: hub
Authorization: Bearer i8hweunweunweofiwweoijewiwe
Content-Type: application/fhir+json

{
  "timestamp": "2018-01-08T01:40:05.14",
  "id": "wYXStHqxFQyHFELh",
  "event": {
    "hub.topic": "fdb2f928-5546-4f52-87a0-0648e9ded065",
    "hub.event": "Patient-close",
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
                            "display": "Medical Record Number"
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

#### Response

```text
HTTP/1.1 202 Accepted
```
