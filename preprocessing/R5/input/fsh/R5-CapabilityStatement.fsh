
Profile: FHIRcastR5CapabilityStatement
Parent: CapabilityStatement
Id: fhircast-r5-capabilitystatement
Title: "R5 CapabilityStatment stating support for FHIRcast."
* implementationGuide 1..*
* rest ^slicing.rules = #open
* rest ^slicing.discriminator.type = #value
* rest ^slicing.discriminator.path = "mode"
* rest ^slicing.description = "Slice stating support for FHIRcast extension"
* rest contains client 0..1 and server 0..1
* rest[client].mode = #client
* rest[server].mode = #server
* rest[server].extension contains FHIRcastR5ConfigurationExtension named fhircast 0..1 MS

