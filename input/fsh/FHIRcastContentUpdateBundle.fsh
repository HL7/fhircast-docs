Profile: FHIRcastContentUpdateBundle
Parent: Bundle
Id: fhircast-content-update-bundle
Title: "FHIRcast Content Update Bundle"
Description: """
    Defines the structure of a Bundle that carries content updates that are
    communicated in FHIRcast `-update` messages. The bundle can only contain
    requests of type PUT and DELETE.  
    POST is not allowed as the content sharing mechanism cannot indicate the 
    id of the created resource using a POST operation.
"""
* insert SetWorkgroupFmmAndStatusRule( #inm, 3, #active)
* type MS
* type = #transaction
* link 0..0
* entry MS
* entry ^slicing.discriminator.type = #value
* entry ^slicing.discriminator.path = "request.method"
* entry ^slicing.rules = #open
* entry ^slicing.ordered = false   // can be omitted, since false is the default
* entry ^slicing.description = "Slice defining each method"
* entry contains put 0..* MS and delete 0..* MS
* entry[put]
  * fullUrl MS
  * fullUrl 0..1
  * resource 1..1
  * search 0..0
  * request 1..1
    * method = #PUT
    * url 1..1
  * response 0..0
* entry[delete]
  * fullUrl MS
  * fullUrl 1..1
  * resource 0..0
  * search 0..0
  * request 1..1
    * method = #DELETE
    * url 1..1
  * response 0..0

Instance:  ImaginStudyUpdateExample
InstanceOf: ImagingStudy
Usage: #inline
* id = "7e9deb91-0017-4690-aebd-951cef34aba4"
* description = "CHEST XRAY"
* started = "2010-02-14T01:10:00.000Z"
* status = #available
* subject = Reference( PatientExample )
* identifier[+]
  * type
    * coding = http://terminology.hl7.org/CodeSystem/v2-0203#ACSN
  * value = "3478116342"
* identifier[+]
  * system = "urn:dicom:uid"
  * value =  "urn:oid:2.16.124.113543.6003.1154777499.30276.83661.3632298176"

Instance: ObservationUpdateExample
InstanceOf: Observation
Usage: #inline
* id = "40afe766-3628-4ded-b5bd-925727c013b3"
* partOf = Reference(ImaginStudyUpdateExample)
* status = #preliminary
* category = http://terminology.hl7.org/CodeSystem/observation-category#imaging  "Imaging"
* code = http://radlex.org#RID49690 "simple cyst"
* effectiveDateTime = "2020-09-07T15:02:03.651Z"
* issued = "2020-09-07T15:02:03.651Z"
* subject = Reference(PatientExample)
* performer = Reference(PractitionerExample)
   

Instance: FHIRcastContentUpdateBundle-Example
InstanceOf: FHIRcastContentUpdateBundle
Usage: #example
Description: "Example of a content update bundle"
* type = #transaction
* entry[put][+]
  * fullUrl = "urn:7e9deb91-0017-4690-aebd-951cef34aba4"
  * request.method = #PUT
  * request.url = "http://example.com/huburl/topic/fhir"
  * resource = ImaginStudyUpdateExample
* entry[put][+]
  * fullUrl = "urn:40afe766-3628-4ded-b5bd-925727c013b3"
  * request.url = "http://example.com/huburl/topic/fhir"
  * request.method = #PUT
  * resource = ObservationUpdateExample
  
