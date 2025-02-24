{% include infonote.html text='This page contains guidance to implementers and is not part of the <a href="2_Specification.html">normative-track.</a>' %}


### Apples & oranges: considerations for synchronizing applications that talk past one another

Some healthcare applications know about apples, some oranges. When the orange application doesn't understand what the apple application is saying: the Hub should help translate.

### Applications understand each other
For many context synchronization scenarios, all participating applications are subscribed to and understand all of the events used in the session. For example all of the applications in a session understand [`Patient-open`](3-3-1-Patient-open.html) and [`Patient-close`](3-3-2-Patient-close.html) events and those are the only events used in the session.

### Applications don't understand each other
However, it may make sense to synchronize applications that don't subscribe to and understand the same FHIRcast events. For example, some specialized healthcare applications deal exclusively with billing charges or imaging studies and don't have the concept of a patient outside of a charge or study. A PACS may not send or even understand a [`Patient-open`](3-3-1-Patient-open.html), only [`ImagingStudy-open`](3-5-1-ImagingStudy-open.html). Similarly, a generalized healthcare application may understand [`Patient-open`](3-3-1-Patient-open.html) events, but not more specialized events, such as [`DiagnosticReport-open`](3-6-1-DiagnosticReport-open.html) events. 

### Implied events

FHIRcast event definitions specify the related FHIR resources that are contextually relevant to the event. An *-open event implies additional open events, one for each of the resource types referenced in the context. 

For example, an [`Encounter-open`](3-4-1-Encounter-open.html) implies a [`Patient-open`](3-3-1-Patient-open.html), because the `Encounter-open`'s context includes not just an encounter resource, but also a patient resource. Similarly, [`DiagnosticReport-open`](3-6-1-DiagnosticReport-open.html) implies [`Patient-open`](3-3-1-Patient-open.html) and possibly an [`ImagingStudy-open`](3-5-1-ImagingStudy-open.html) (if an ImagingStudy is supplied in the [`DiagnosticReport-open`](3-6-1-DiagnosticReport-open.html) event).

### Hub derives open events

The Hub is responsible for identifying and sending these implied *-open events. When distributing a received event, the Hub is responsible for generating and communicating open events for the resource types referenced by the received event. It is important that Hubs do not generate and send duplicative events. 


See details in the specification about:
* Hubs can [reject subscriptions](2-4-Subscribing.html#subscription-response) according to their own internal business logic.
* Hubs are [required](2-5-ReceiveEventNotification.html#hub-generated-open-events) to derive and send open events. 

### Hub may or may not derive close events

{% include questionnote.html text='Implementer input is solicited. Is the absence of guidance from the specification problematic? If so, why? and how would you recommend we solve this?' %}

A close event may or may not imply the closure of referenced resource types (see [multi-tab considerations](4-2-2-multitab-considerations.html)). FHIRcast does not currently prescribe this behavior. 

