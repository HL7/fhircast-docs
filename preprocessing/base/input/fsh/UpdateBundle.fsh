Profile: FHIRcast{{fhirNoUc}}ContentUpdateBundle
Parent: Bundle
Id: fhircast-{{fhirNoLc}}-content-update-bundle
Title: "{{fhirNoUc}} FHIRcast Content Update Bundle"
Description: """
    Defines the structure of a Bundle that carries content updates that are
    communicated in FHIRcast `-update` messages. The bundle can only contain
    requests of type PUT and DELETE.  
    POST is not allowed as the content sharing mechanism cannot indicate the 
    id of the created resource.
"""
* type MS
* type = #transaction
* link 0..0
* entry MS
* entry ^slicing.discriminator.type = #value
* entry ^slicing.discriminator.path = "request.method"
* entry ^slicing.rules = #open
* entry ^slicing.ordered = false   // can be omitted, since false is the default
* entry ^slicing.description = "Slice defining each method"
* entry contains put 0..* MS and post 0..0 and get 0..0 and delete 0..*
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
