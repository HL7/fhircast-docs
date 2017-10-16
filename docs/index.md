# FHIRcast - _modern, simple application context synchronization_

## Overview

FHIRcast synchronizes healthcare applications in real time to show the same clinical content to a common user. For example, a radiologist often works in three disparate applications at the same time (a radiology information system, a PACS and a dictation system), she wants each of these three systems to display the same study or patient at the same time. 

FHIRcast isn't limited to radiology use-cases. Using [FHIR Subscriptions](https://www.hl7.org/fhir/subscription.html), FHIRcast naturally extends the SMART on FHIR launch protocol to achieve tight integration between disparate, full-featured applications. FHIRcast builds on the [CCOW](https://en.wikipedia.org/wiki/CCOW) abstract model to specify an http-based, simple and decentralized context synchronization specification. For simplicity, the below describes an app synchronizing with an EHR, but any user-facing application can synchronize with FHIRcast. While less common,  bidirectional communication between multiple application is also possible.


### Why?

The large number of vendor-specific or proprietary context synchronization methods in production use limit the industry's ability to enhance the large number of integrations currently in production. In practice, these integrations are decentralized and simple. 


## Synchronize

An app creates a subscription to the EHR's UserSession and is then notified when the focus of the session changes, for example, by the clinician opening a patient's chart. The app deletes its subscription when it no longer wants to receive notifications.



[TODO: Simple, attractive image illustrating actors and key interactions]

### EHR launches SMART on FHIR App

The EHR launches the app following the standard (SMART on FHIR EHR launch)[http://www.hl7.org/fhir/smart-app-launch#ehr-launch-sequence]  flow, including identifying the current EHR user using OpenID Connect. As part of the app launch, alongside the acess_token the EHR's authorization server identifies the current user's [UserSession](usersession/):

```
{
  "access_token": "i8hweunweunweofiwweoijewiwe",
  "token_type": "bearer",
  "expires_in": 3600,
  "patient":  "123",
  "encounter": "456",
  "usersession" : "789"
}
```

Although FHIRcast works best with the SMART on FHIR launch and authorization process, it can also be used with implementation-specific launch and authz protocols.

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

[TODO - ask Bryn for correct syntax for multiple common workflow events]

### The app creates a Subscription on the EHR's FHIR server for the given EventDefinition:

In this example, the app asks to be notified of new events via a _rest-hook_ with the modified resource in the http body. FHIR Subscriptions also describes other possible channels. Note that the bearer access_token used to authenticate to the FHIR server was initially granted during the SMART launch.

```
POST <fhir base url>/Subscription
Authorization: Bearer i8hweunweunweofiwweoijewiwe
```

```
{
  "resourceType": "Subscription",
  "criteria": "UserSession?_id=123",
  "topic": "<fhir base url>/EventDefinition/abc",
  "channel": {
    "type": "rest-hook",
    "endpoint": "<app notification endpoint>/on-patientchartopen",
    "payload": "application/fhir+json"
  }
}
```
  
### EHR responds with successful creation

```
201 Created
Location: <fhir base url>/Subscription/sub00001
```

### EHR notifies app of change

```
PUT <app notification endpoint>/on-patientchartopen/UserSession
```

```
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
```


### App unsubscribes to UserSession changes

```
DELETE <fhir base url>/Subscription/sub00001
```

## Event Catalog

1. open-patient-chart
1. switch-patient-chart
1. close-patient-chart
1. open-imaging-study
1. switch-imaging-study
1. close-imaging-study
1. user-login
1. user-logout
1. user-hibernates

[TODO - define fhirpath / Event definitions with names for common workflow events]

## Get involved

https://chat.fhir.org/#narrow/stream/subscriptions
https://github.com/fhircast