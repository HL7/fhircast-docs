Alias: HL7IdType = http://terminology.hl7.org/CodeSystem/v2-0203

Profile: FHIRcastPatient
Parent: Patient
Id: fhircast-patient
Title: "FHIRcast Patient"
Description: "Defines the minimum set of attributes which an application handling Patient contexts must support"
* identifier 1..* MS

Instance: FHIRcastPatient-Example
InstanceOf: FHIRcastPatient
Usage: #example
Description: "Example of a simple imaging study used to establish a FHIRcast context"
* id = "8i7tbu6fby5ftfbku6fniuf"
* identifier.type = HL7IdType#MR "Medical Record Number"
* identifier.system = "urn:oid:1.2.36.146.595.217.0.1"
* identifier.value = "213434"
