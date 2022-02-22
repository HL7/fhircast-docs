### Multi-anchor considerations

This section describes how FHIRcast can be used in a scenario where multiple applications subscribe to different anchor-types.

#### Implied events

For many context synchronization scenarios, all participating applications are subscribed to and understand all of the events used in the session; however, this may not always be the case. For example, some specialized healthcare applications deal exclusively with billing charges or imaging studies and don't have the concept of a patient outside of a charge or study. These specialized applications may not generate and send a patient-open, only ever an imagingstudy-open. Similarly, a generalized healthcare application may understand patient-open, but not more specialized events, such as imagingstudy-open which merely references a patient. 

FHIRcast event definitions specify the related FHIR resources that are contextully relevent to the event. An -open event implies an -open event for each of the resource-types referenced in the context. 

For example, an encounter-open implies a patient-open, because the encounter-open's context includes not just an encounter resource, but also a patient resources. Similarly, and imagingstudy-open 

If capable, the hub is responsible for bridging this gap. 


##### Hub derives open events


are implied by the references in their context. 

One -open event 

open events are clearly 



Hub are either capable of 

A hub SHOULD determine the events used in a session (for example, those granted to the first subscriber) and reject new subscriptions that differ from the events used by the session, **unless** the hub is capable of deriving, generating and sending implied events. A hub capable of deriving events SHALL generate and send -open events for the resource-types referenced in the original app-generated event. 

Hubs MAY generate and send duplicative events. 
Hubs SHOULD NOT generate and send duplicative events. 
##### Hub may or may not derive close events
A -close event may or may not imply the closure of referenced resource-types. FHIRcast does not currently prescribe this behavior. Implementer input is solicited. 

