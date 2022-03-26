### Apples & oranges: considerations for synchronizing applications that talk past one another

Some healthcare applications know about apples, some oranges. When the orange app doesn't understand what the apple app is saying: the hub must help translate.

#### Apps understand each other
For many context synchronization scenarios, all participating applications are subscribed to and understand all of the events used in the session. For example all of the applications in a session understand [`patient-open`](3-3-1-patient-open.html) and [`patient-close`](3-3-2-patient-close.html) and those are the only events used in the session. The Patient resource _anchors_ the sessions.

#### Apps don't understand each other
However, it may make sense to synchronize applications that don't subscribe to and understand the same FHIRcast events. For example, some specialized healthcare applications deal exclusively with billing charges or imaging studies and don't have the concept of a patient outside of a charge or study. A PACS may not send or even understand a [`patient-open`](3-3-1-patient-open.html), only [`imagingstudy-open`](3-5-1-imagingstudy-open.html). Similarly, a generalized healthcare application may understand [`patient-open`](3-3-1-patient-open.html) events, but not more specialized events, such as [`diagnosticreport-open`](3-6-1-diagnosticreport-open.html) events. 

##### Implied events

FHIRcast event definitions specify the related FHIR resources that are contextully relevent to the event. An open event implies additional open events, one for each of the resource types referenced in the context. 

For example, an [`encounter-open`](3-4-1-encounter-open.html) implies a [`patient-open`](3-3-1-patient-open.html), because the `encounter-open`'s context includes not just an encounter resource, but also a patient resource. Similarly, [`diagnosticreport-open`](3-6-1-diagnosticreport-open.html) implies [`patient-open`](3-3-1-patient-open.html) and possibly an [`imagingstudy-open`](3-5-1-imagingstudy-open.html) (if an ImagingStudy is supplied in the [`diagnosticreport-open`](3-6-1-diagnosticreport-open.html) event).

##### Hub derives open events

The hub is responsible for identifying and sending these implied open events. When distributing a received event, a hub SHALL ensure open events are also sent to subscribers, for the referenced resource types of the received event. Hubs SHOULD NOT generate and send duplicative events. 

##### Hub may or may not derive close events

> Implementer input is solicited. Is the absence of guidance from the spec problematic? If so, why? and how would you recommend we solve this?

A close event may or may not imply the closure of referenced resource types (see [multi-tab considerations](4-4-multitab-considerations.html)). FHIRcast does not currently prescribe this behavior. 

