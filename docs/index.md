# FHIRcast - _modern, simple application context synchronization_

## Overview

FHIRcast synchronizes healthcare applications in real time to show the same clinical content to a common user. For example, a radiologist often works in three disparate applications at the same time (a radiology information system, a PACS and a dictation system), she wants each of these three systems to display the same study or patient at the same time. 

FHIRcast isn't limited to radiology use-cases. Using [FHIR Subscriptions](https://www.hl7.org/fhir/subscription.html), FHIRcast naturally extends the SMART on FHIR launch protocol to achieve tight integration between disparate, full-featured applications. FHIRcast builds on the [CCOW](https://en.wikipedia.org/wiki/CCOW) abstract model to specify an http-based, simple and decentralized context synchronization specification.


### Why?

The large number of vendor-specific or proprietary context synchronization methods in production use limit the industry's ability to enhance the large number of integrations currently in production. In practice, these integrations are decentralized and simple. 


## Synchronize

An app creates a subscription to the EHR's UserSession and is then notified when the focus of the session changes, for example, by the clinician opening a patient's chart. The app deletes it's subscription when it no longer wants to receive notifications.

[TODO: Simple, attractive image illustrating actors and key interactions]


### App subscribes to UserSession changes

The app finds or creates an EventDefinition that describes the change it wants to be notified of.
```
GET <fhir base url>/EventDefinition?name=patient-chart-open
```
```
{
  "resourceType": "EventDefinition",
  "id": "abc",
  "status": "active",
  "name": "patient-chart-open",
  "description": "Patient in focus changes in UserSession",
  "trigger": {
    "type": "named-event",
    "data": {
      "type": "UserSession"
    },
    "condition": {
      "description": "Current UserSession.focus contains a Patient not in previous UserSession.focus",
      "language": "text/fhirpath",
      "expression": "this.focus.ofType(Patient) and this.focus != %previous.focus"
    }
  }
}
```


### The app creates a Subscription on the EHR's FHIR server for the given EventDefinition:

In this example, the app asks to be notified of new events via a _rest-hook_ with the modified resource in the http body. FHIR Subscriptions also describes other possible channels.

'''
POST <fhir base url>/Subscription
'''
'''
{
  "resourceType": "Subscription",
  "criteria": "Patient/123",
  "topic": "<fhir base url>/EventDefinition/abc",
  "channel": {
    "type": "rest-hook",
    "endpoint": "<app notification endpoint>/on-patientchartopen",
    "payload": "application/fhir+json"
  }
}
'''
  
### EHR responds with successful creation
'''
201 Created
Location: <fhir base url>/Subscription/sub00001
'''
### EHR notifies app of change

'''
PUT <app notification endpoint>/on-patientchartopen/UserSession
'''
'''
{
  "resourceType": "UserSession",
  "id" : "xyz",
  "user": "Practitioner/prov123",
  "status" : {
    "value" : "activating",
    "source" : "user"
  }
  "workstation" : "Location/readingworkstation456",
  "focus" : [
    "Patient/789",
    "Encounter/100009181"
  ],
  "created" : "2017-12-11T09:57:34.2112Z",
 }
'''


### App unsubscribes to UserSession changes

'''
DELETE <fhir base url>/Subscription/sub00001
'''

## Get involved!

https://chat.fhir.org/#narrow/stream/subscriptions
