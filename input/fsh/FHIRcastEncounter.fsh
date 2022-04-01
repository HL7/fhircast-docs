Alias: HL7ActCode = http://terminology.hl7.org/CodeSystem/v3-ActCode

Profile: FHIRcastEncounter
Parent: Encounter
Id: fhircast-encounter
Title: "FHIRcast Encounter"
Description: "Defines the minimum set of attributes which an application handling Encounter contexts must support"
* identifier 1..* MS

Instance: FHIRcastEncounter-Example
InstanceOf: FHIRcastEncounter
Usage: #example
Description: "Example of a simple encounter used to establish a FHIRcast context"
* id = "90235y2347t7nwer7gw7rnhgf"
* identifier.system = "http://healthcare.example.org/identifiers/encounter"
* identifier.value = "1234213.52345873"
* status = #in-progress
* class = HL7ActCode#IMP "inpatient encounter"
* subject.reference = "Patient/ewUbXT9RWEbSj5wPEdgRaBw3"
