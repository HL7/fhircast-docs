Profile: FHIRcastEncounter
Parent: Encounter
Id: fhircast-encounter
Title: "FHIRcast Encounter"
Description: "Provides guidance as to which attributes should be present and considerations as to how each attribute should be valued in an Encounter open request."
* id 1..1 
* id ^definition = "This is a test"

Instance: FHIRcastEncounter-Example
InstanceOf: FHIRcastEncounter
Usage: #example
Description: "Example of an encounter which could be used in an encounter-open event"
* id = "8cc652ba-770e-4ae1-b688-6e8e7c737438"
* status = http://terminology.hl7.org/fhir/ValueSet/encounter-status#unknown
* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#AMB