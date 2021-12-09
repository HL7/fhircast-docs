
Profile: FHIRcastCapabilityStatement
Parent: CapabilityStatement
Description: "CapabilityStatment stating support for FHIRcast."
* implementationGuide 1..*
* rest ^slicing.discriminator.type = #value
* rest ^slicing.discriminator.path = "mode"
* rest ^slicing.description = "Slice stating support for FHIRcast extension"
* rest contains client 0..1 and server 0..1
* rest[client].mode = #client
* rest[server].mode = #server
* rest[server].extension contains FHIRcastConfigurationExtension named fhircast 0..1 MS

