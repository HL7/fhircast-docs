Profile: FHIRcastR4bGetCurrentContentBundle
Parent: Bundle
Id: fhircast-r4b-get-current-content-bundle
Title: "FHIRcast R4b Get Current Content Bundle"
Description: """
    Defines the structure of a Bundle that carries current content state
    resulting from various FHIRcast `-update` messages. 
"""
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