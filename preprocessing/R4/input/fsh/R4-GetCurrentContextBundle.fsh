Profile: FHIRcastR4GetCurrentContentBundle
Parent: Bundle
Id: fhircast-r4-get-current-content-bundle
Title: "R4 FHIRcast Get Current Content Bundle"
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