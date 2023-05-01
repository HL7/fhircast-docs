Logical: FHIRcastEvent
Id:      fhircast-event
Title:   "FHIRcast base event definition"
Description: "Logical model for FHIRcast events."
* hubtopic 1..1 string          "FHIRcast topic" "The session topic given in the subscription request. MAY be a Universally Unique Identifier (UUID)."
* hubevent 1..1 string          "The name of the event." "The event that triggered this notification, taken from the list of events from the subscription request."
* context   0..* Base "The contexy of this event" "An array of named FHIR objects corresponding to the user’s context after the given event has occurred."
  * key      1..1 string   "The key for this context variable."
  * resource 1..1 Resource "The reosurce"

Profile: FhircastContextChangeEvent
Parent: FHIRcastEvent
Id: fhircast-contextchange-event
Title: "FhircastContextChangeEvent"
Description: "Description"
* hubtopic MS
* hubevent MS
* context MS
* context 1..*
  * resource MS
  * key MS

Invariant: fhircast-1
Description: "Description"
Expression: "hubevent.endsWith('-open')"
Severity: #error

Invariant: fhircast-2
Description: "Description"
Expression: "hubevent.endsWith('-close')"
Severity: #error

Profile: PatientContextEventPatient
Parent:  Patient
* id MS
* identifier MS

Profile: PatientOpenEvent
Parent: FhircastContextChangeEvent
Id: patient-open
Title: "patient-open"
Description: "User opened patient’s medical record. The indicated patient is the current patient in context."
* obeys fhircast-1
* hubevent = "patient-open"
* context 1..1 MS
* context
  * key = "patient"
  * resource only PatientContextEventPatient

Profile: PatientCloseEvent
Parent: FhircastContextChangeEvent
Id: patient-close
Title: "patient-close"
Description: "User close patient’s medical record. The indicated patient is the current patient in context."
* obeys fhircast-2
* hubevent = "patient-close"
* context 1..1 MS
* context
  * key = "patient"
  * resource only PatientContextEventPatient

