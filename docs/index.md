<img style="float: left;padding-right: 5px;" src="img/hl7-logo-header-good-resolution.png" width=20%" />
# FHIRcast <span style="font-size: medium;">- _modern, simple application context synchronization_</span>

## Overview

FHIRcast synchronizes healthcare applications in real time to show the same clinical content to a common user. For example, a radiologist often works in three disparate applications at the same time (a radiology information system, a PACS and a dictation system), she wants each of these three systems to display the same study or patient at the same time. 

FHIRcast isn't limited to radiology use-cases. Modeled after the common webhook design pattern and specifically [WebSub](https://www.w3.org/TR/websub/), FHIRcast naturally extends the SMART on FHIR launch protocol to achieve tight integration between disparate, full-featured applications. 

FHIRcast builds on the [CCOW](https://www.hl7.org/implement/standards/product_brief.cfm?product_id=1) abstract model to specify an http-based and simple context synchronization specification that doesn't require a separate context manager. FHIRcast is intended to be both less sophisticated, and more implementer-friendly than CCOW and therefore is not a one-to-one replacement of CCOW, although it solves many of the same problems.

Adopting the WebSub terminology, FHIRcast describes an app as a subscriber synchronizing with an EHR in the role of a Hub, but any user-facing application can synchronize with FHIRcast. While less common,  bidirectional communication between multiple applications is also possible.


### Why?
The large number of vendor-specific or proprietary context synchronization methods in production limit the industry's ability to enhance the very large number of integrations currently in production. In practice, these integrations are decentralized and simple. 

## How it works
The _driving application_ could be an EHR, a PACS, a worklist or any other clinical workflow system. The driving application integrates the Hub, the SMART authorization server and a FHIR server. As part of a SMART launch, the app requests appropriate [fhircast OAuth 2.0 scopes](specification/STU1/#fhircast-authorization-smart-scopes) and receives the initial shared context as well as the location of the Hub and a unique `hub.topic` session identifier.

The app subscribes to specific workflow events for the given user's session by contacting the Hub. The Hub verifies the subscription notifies the app when those workflow events occur; for example, by the clinician opening a patient's chart. The app deletes its subscription when it no longer wants to receive notifications.

### Example scenario

A radiologist working in their reporting system clicks a button to open their dictation system. The dictation app is authorized and subscribes to the radiologist's session. Each time the radiologist opens a patient's chart in the reporting system, the dictation app will be notified of the current patient and therefore presents the corresponding patient information on its own UI. The reporting system and dictation app share the same session's context.

![FHIRcast overview](/img/colorful%20overview%20diagram.png)


* Event notifications are thin json wrappers around FHIR resources.	
* The app can request context changes by sending an event notification to the Hub's `hub.topic` session identifier. The HTTP response status indicates success or failure. 	
* The Event Catalog documents the workflow events that can be communicated in FHIRcast. Each event will always carry the same type of FHIR resources.

## Get involved
* Check out our [awesome community contributions on github](https://github.com/fhircast)
* [Log issues, submit a PR!](https://github.com/fhircast/docs)
* [Converse at chat.fhir.org](https://chat.fhir.org/#narrow/stream/subscriptions)

