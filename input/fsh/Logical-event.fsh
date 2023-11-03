Logical: FHIRcastEvent
Id:      fhircast-eventdefinition
Title:   "FHIRcast event definition"
* hubtopic 1..1 SU string "topic" 
    "The topic of the FHIRcast session in which the event is send."
* hubevent 1..1 SU string "event-name" 
    "The name of the event as specified in http://130.145.227.203:8081/2-3-Events.html#event-format ."
* context 0..* BackboneElement  "event context"
    "The context of the event as specified in the event definition."
  * key 1..1 SU string "context key"
    "The key identifying this content element."
  * resource 1..1 SU Resource "FHIR resource"
    "A FHIR resource."

Profile: ImagingStudyOpenEvent
Parent:  FHIRcastEvent
Id:      imagingstudy-open-event
* hubevent = "imagingstudy-open"
* context ^slicing.discriminator.type = #pattern
* context ^slicing.discriminator.path = "key"
* context ^slicing.rules = #open
* context contains study 1..1
* context 1..*
* context[study]
  * key = "study"
  * resource only FHIRcastImagingStudyOpen



Instance:   ImagingStudyOpenEventEventExample
InstanceOf: ImagingStudyOpenEvent
* hubtopic = "4832479-3343432-24432432-234324324"
* context[study].resource = FHIRcastImagingStudyOpen-Example