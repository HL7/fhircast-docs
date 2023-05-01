Logical: FHIRcastEvent
Id:      fhircast-event
Title:   "FHIRcast base event definition"
Description: "Logical model for FHIRcast events."
* hubtopic 1..1 string          "FHIRcast topic" "The session topic given in the subscription request. MAY be a Universally Unique Identifier (UUID)."
* hubevent 1..1 string          "The name of the event." "The event that triggered this notification, taken from the list of events from the subscription request."
* context   0..* BackboneElement "The contexy of this event" "An array of named FHIR objects corresponding to the user’s context after the given event has occurred."
  * key      1..1 string   "The key for this context variable."
  * resource 1..1 Resource "The reosurce"

Profile: PatientOpenEvent
Parent: FHIRcastEvent
Id: patient-open
Title: "Patient-open"
Description: "User opened patient’s medical record. The indicated patient is the current patient in context."
* hubtopic MS
* hubevent MS
* context 1..1 MS
* context
  * key = "patient"
  * resource only Patient

Instance: EveAnyperson   // this is the id of the example instance
InstanceOf: Patient
Description: "Eve Anyperson"
Usage: #example
* name.given = "Eve"
* name.family = "Anyperson"

Instance: PatientOpenExample
InstanceOf: PatientOpenEvent
* hubtopic = "fdb2f928-5546-4f52-87a0-0648e9ded065"
* hubevent = "patient-open"
* context
  * key = "patient"
  * resource = EveAnyperson 
