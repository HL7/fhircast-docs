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

Profile: FhircastContextChangeOpenEvent
Parent: FhircastContextChangeEvent
Id: fhircast-contextchange-open-event
Title: "FhircastContextChangeOpenEvent"
Description: "A Description"
* obeys fhircast-1 
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

Profile: PatientContextEventPatientClose
Parent:  Patient
* id MS

Profile: PatientOpenEvent
Parent: FhircastContextChangeOpenEvent
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

Profile: EncounterOpenEvent
Parent: FhircastContextChangeOpenEvent
Id: encounter-open
Title: "encounter-open"
Description: "TBD."
* obeys fhircast-1
* hubevent = "encounter-open"
* context 2..2 MS
* context ^slicing.discriminator.type = #value
* context ^slicing.discriminator.path = "key"
* context ^slicing.rules = #open
* context ^slicing.ordered = false   // can be omitted, since false is the default
* context ^slicing.description = "Slice defining each method"
* context contains patient 1..1 MS and encounter 1..1 
* context[patient]
  * key = "patient"
  * resource only PatientContextEventPatient
* context[encounter]
  * key = "encounter"
  * resource only Encounter


// Instance: EveAnyperson   // this is the id of the example instance
// InstanceOf: Patient
// Description: "Eve Anyperson"
// Usage: #example
// * name.given = "Eve"
// * name.family = "Anyperson"

// Instance: PatientOpenExample1
// InstanceOf: PatientOpenEvent
// * hubtopic = "fdb2f928-5546-4f52-87a0-0648e9ded065"
// * hubevent = "patient-open"
// * context
//   * key = "patient"
//   * resource = EveAnyperson 

// Instance: PatientCloseExample2
// InstanceOf: PatientCloseEvent
// * hubtopic = "fdb2f928-5546-other-87a0-0648e9ded065"
// * hubevent = "patient-open"
// * context
//   * key = "patient"
//   * resource
//     * id = "askjdaksjdlk"