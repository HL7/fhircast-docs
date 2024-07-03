Profile: FHIRcastGetCurrentContentBundle
Parent: Bundle
Id: fhircast-get-current-content-bundle
Title: "FHIRcast Get Current Content Bundle"
Description: """
    Defines the structure of a Bundle that carries current content state
    resulting from various FHIRcast `-update` messages. 
"""
* ^extension[0].url = "http://hl7.org/fhir/StructureDefinition/structuredefinition-wg"
* ^extension[0].valueCode = #inm
* type MS
* type = #collection
* link 0..0
* entry MS
* entry 0..*
  * link 0..0
  * fullUrl MS
  * fullUrl 0..1
  * resource MS
  * resource 0..1
  * search 0..0
  * request 0..0
  * response 0..0

Instance: FHIRcastGetCurrentContentBundleExampleObservation
InstanceOf: Observation
Usage: #inline
* id = "435098234"
* partOf = Reference( ImagingStudyExample )
* status = #preliminary
* subject = Reference( PatientExample )
* performer = Reference( PractitionerExample )
* effectiveDateTime = "2020-09-07T15:02:03.651Z"
* category = http://terminology.hl7.org/CodeSystem/observation-category#imaging "Imaging"
* code = http://radlex.org#RID49690 "simple cyst"
* issued = "2020-09-07T15:02:03.651Z"

Instance: FHIRcastGetCurrentContentBundle-Example
InstanceOf: FHIRcastGetCurrentContentBundle
Usage: #example
Description: "Example response to the get current context."
* id = "8i7tbu6fby5fuuey7133eh"
* type = #collection
* entry[+]
  * fullUrl = "urn:Observation/435098234"
  * resource =  FHIRcastGetCurrentContentBundleExampleObservation
  