Profile: FHIRcastContentUpdateBundle
Parent: Bundle
Id: fhircast-content-update-bundle
Title: "FHIRcast Content Update Bundle"
Description: """
    Defines the structure of a Bundle that carries content updates that are
    communicated in FHIRcast `-update` messages. The bundle can only contain
    requests of type PUT and DELETE.  
    POST is not allowed as the content sharing mechanism cannot indicate the 
    id of a resource created by a POST method.  Since the creator of the resource
    does wish to have control over the id of a resource it has created, as per the FHIR
    RESTful API it should use the update (i.e., PUT) interaction instead of the
    create (i.e., POST) interaction.
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
  * fullUrl 0..1
  * resource 1..1
  * search 0..0
  * request 1..1
    * method = #DELETE
    * url 1..1
  * response 0..0
