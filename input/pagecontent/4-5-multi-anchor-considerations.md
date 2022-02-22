### Multi-anchor considerations

#### Single anchor
For many context synchronization scenarios, all participating applications are subscribed to and understand all of the events used in the session. For example all of the applications in a session understand `patient-open` and `patient-close` and those are the only events used in the session. The Patient resource _anchors_ the sessions.

#### Multi-anchor
However, it may make sense to synchronize applications that don't subscribe to and understand the same FHIRcast events. For example, some specialized healthcare applications deal exclusively with billing charges or imaging studies and don't have the concept of a patient outside of a charge or study. A PACS may not send or even understand a `patient-open`, only `imagingstudy-open`. Similarly, a generalized healthcare application may understand patient-open, but not more specialized events, such as `imagingstudy-open`. 

##### Implied events

FHIRcast event definitions specify the related FHIR resources that are contextully relevent to the event. An open event implies additional open events, one for each of the resource types referenced in the context. 

For example, an [`encounter-open`](3-4-encounter-open.html) implies a `patient-open`, because the `encounter-open`'s context includes not just an encounter resource, but also a patient resource. Similarly, [`diagnosticreport-open`](3-12-diagnosticreport-open.html) implies `patient-open` and `imagingstudy-open`. 

##### Hub derives open events

The hub is responsible for identifying and sending these implied open events. When distributing a received event, a hub SHALL ensure open events are also sent to subscribers, for the referenced resource types of the received event. Hubs SHOULD NOT generate and send duplicative events. 

##### Hub may or may not derive close events

> Implementer input is solicited. Is the absence of guidance from the spec problematic? If so, why? and how would you recommend we solve this?

A close event may or may not imply the closure of referenced resource types (see [multi-tab considerations](4-4-multitab-considerations.html)). FHIRcast does not currently prescribe this behavior. 

