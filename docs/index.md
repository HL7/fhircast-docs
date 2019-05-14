<img style="float: left;padding-right: 5px;" src="img/hl7-logo-header.png" width=90px" />
# FHIRcast <span style="font-size: medium;">- _modern, simple application context synchronization_</span>

## Overview

FHIRcast synchronizes healthcare applications in real time to show the same clinical content to a common user. For example, a radiologist often works in three disparate applications at the same time (a radiology information system, a PACS and a dictation system), she wants each of these three systems to display the same study or patient at the same time. 

FHIRcast isn't limited to radiology use-cases. Modeled after the common webhook design pattern and specifically [WebSub](https://www.w3.org/TR/websub/), FHIRcast naturally extends the SMART on FHIR launch protocol to achieve tight integration between disparate, full-featured applications. FHIRcast builds on the [CCOW](https://en.wikipedia.org/wiki/CCOW) abstract model to specify an http-based and simple context synchronization specification that doesn't require a separate context manager. 

Adopting the WebSub terminology, FHIRcast describes an app as a subscriber synchronizing with an EHR in the role of a hub, but any user-facing application can synchronize with FHIRcast. While less common,  bidirectional communication between multiple applications is also possible.


### Why?
The large number of vendor-specific or proprietary context synchronization methods in production limit the industry's ability to enhance the very large number of integrations currently in production. In practice, these integrations are decentralized and simple. 

## How it works
The _driving application_ could be an EHR, a PACS, a worklist or any other clinical workflow system (we use the term EHR as shorthand). The driving application integrates the Hub, the SMART authorization server and a FHIR server. As part of a SMART launch, the app requests the `fhircast` OAuth 2.0 scope and receives the location of the Hub and a unique `hub.topic` url, which serves as the identifier of the user's session.

The app subscribes to specific workflow events for the given user's session by contacting the Hub. The Hub verifies the subscription notifies the app when those workflow events occur; for example, by the clinician opening a patient's chart. The app deletes its subscription when it no longer wants to receive notifications.
![FHIRcast overview](img/colorful%20overview%20diagram.png)

* Event notifications are thin json wrappers around FHIR resources.	
* With the `hub.topic` the app can query the Hub for the current status of the session at any time. 	
* The app can request context changes by sending an event notification to the Hub's `hub.topic` url. The HTTP response status indicates success or failure. 	
* The [Event Catalog](/#event-catalog) documents the workflow events that can be communicated in FHIRcast. Each event will always carry the same type of FHIR resources.

## Get involved
* Check out our [awesome community contributions on github](https://github.com/fhircast)
* [Log issues, submit a PR!](https://github.com/fhircast/docs)
* [Converse at chat.fhir.org](https://chat.fhir.org/#narrow/stream/subscriptions)

