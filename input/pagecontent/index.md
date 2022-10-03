### Overview

FHIRcast synchronizes healthcare applications in real time to show the same clinical context to a common user. For example, a radiologist often works in three disparate applications at the same time (a radiology information system, a PACS and a dictation system), in this case, each of these three systems needs to display the same study or patient at the same time.

FHIRcast isn't limited to radiology use-cases. Modeled after the common webhook design pattern and specifically [WebSub](https://www.w3.org/TR/websub/), FHIRcast naturally extends the SMART on FHIR launch protocol to achieve tight integration between disparate, full-featured applications.

FHIRcast builds on the [CCOW](https://www.hl7.org/implement/standards/product_brief.cfm?product_id=1) abstract model to specify an http-based and simple context synchronization specification that doesn't require a separate context manager. FHIRcast is intended to be both less sophisticated, and more implementer-friendly than CCOW and therefore is not a one-to-one replacement of CCOW, although it solves many of the same problems.

Adopting the WebSub terminology, FHIRcast describes an app as a Subscriber synchronizing with a Hub (which may be an EHR or other system).  Any user-facing application can synchronize with FHIRcast. While less common, bidirectional communication between multiple applications is also possible.

#### Why?

The large number of vendor-specific or proprietary context synchronization methods in production limit the industry's ability to enhance the very large number of integrations currently in production. In practice, these integrations are decentralized and simple.

### How it works and an example scenario

A radiologist working in the reporting system clicks a button to open the dictation system. The dictation app is authorized and subscribes to the radiologist's session. Each time the radiologist opens a patient's chart in the reporting system, the dictation app will be notified of the current patient and therefore presents the corresponding patient information on its own UI. The reporting system and dictation app share the same session's context.

{% include img.html img="colorful overview diagram.png" caption="Figure: FHIRcast Overview" %}

By convention a driving application is the application which opens a context.  The driving application could be an EHR, a PACS, a worklist, or any other clinical workflow system.  A driving application may or may not launch other applications; to launch other applications the driving application may use the [SMART App Launch](https://hl7.org/fhir/smart-app-launch) mechanism.  As part of a [SMART App Launch](https://hl7.org/fhir/smart-app-launch), an application requests appropriate [FHIRcast OAuth 2.0 scopes](2-2-FhircastScopes.html) and receives the location of the Hub and a unique `hub.topic` session identifier.

 An application subscribes to specific workflow events for the topic during its subscription request.  The Hub verifies the subscription then notifies the subscribed application when the requested workflow events occur; for example, by the clinician opening a patient’s chart a `Patient-open` event would be sent. An application unsubscribes from a topic when it no longer wants to receive notifications.  Note that subscribed applications other than the driving application could send a close event for an open context; however, such a scenario may not desirable in many workflows.

Note that:

* Event notifications are thin json wrappers around FHIR resources.
* The app can request context changes by sending an event notification to the Hub's `hub.topic` session identifier. The HTTP response status indicates success or failure. 	
* The [Event Catalog](3_Events.html) documents the workflow events that can be communicated in FHIRcast. Each event will always carry the same type of FHIR resources.

### Get involved

* Check out our [awesome community contributions on github](https://github.com/fhircast)
* [Log issues](https://jira.hl7.org/secure/CreateIssue.jspa), [submit a PR!](https://github.com/fhircast/docs)
* [Converse at chat.fhir.org](https://chat.fhir.org/#narrow/stream/179271-FHIRcast)
