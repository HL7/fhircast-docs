Profile: FHIRcastSyncSuccessParameters
Parent: Parameters
Id: fhircast-parameters-syncsuccess
Title: "FHIRcast Parameters profile for syncSuccess events."
Description: "Contains the FHIRcast event id of the event that was successfully synchronized to."
* insert SetWorkgroupFmmAndStatusRule( #inm, 1, #active)
* ^experimental = false
* parameter 1..* MS
* parameter ^slicing.discriminator.type = #value
* parameter ^slicing.discriminator.path = "name"
* parameter ^slicing.rules = #open
* parameter ^slicing.ordered = false   // can be omitted, since false is the default
* parameter ^slicing.description = "The related, successfully synchronized event."
* parameter contains relatedEvent 1..1 MS
* parameter[relatedEvent].name = "relatedEvent"
* parameter[relatedEvent] ^short = "The successfully synchronized event."
* parameter[relatedEvent] ^definition = "The FHIRcast event id of the event that was successfully synchronized to."
* parameter[relatedEvent].value[x] 1..1
* parameter[relatedEvent].value[x] Identifier
* parameter[relatedEvent].value[x] ^short = "The FHIRcast event id of the related event."
* parameter[relatedEvent].valueIdentifier.system 1..1 MS
* parameter[relatedEvent].valueIdentifier.system = "http://hl7.org/fhir/uv/fhircast/eventid" (exactly)
* parameter[relatedEvent].valueIdentifier.system ^short = "The FHIRcast eventid identifier system."
* parameter[relatedEvent].valueIdentifier.value 1..1 MS

Instance: FHIRcastSyncSuccessContext-Example
InstanceOf: FHIRcastSyncSuccessContext
Description: "Example FHIRcast syncSuccess event context."
Usage: #example
* parameter[relatedEvent]
  * name = "relatedEvent"
  * valueIdentifier.system = "http://hl7.org/fhir/uv/fhircast/eventid"
  * valueIdentifier.value = "b9a4b2e1-3f4c-4d6a-8e7f-1a2b3c4d5e6f"
