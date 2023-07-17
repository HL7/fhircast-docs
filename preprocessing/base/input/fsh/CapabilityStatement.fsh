
Profile: FHIRcast{{fhirNoUc}}CapabilityStatement
Parent: CapabilityStatement
Id: fhircast-{{fhirNoLc}}-capabilitystatement
Title: "{{fhirNoUc}} CapabilityStatment stating support for FHIRcast."
* implementationGuide 1..*
* rest ^slicing.rules = #open
* rest ^slicing.discriminator.type = #value
* rest ^slicing.discriminator.path = "mode"
* rest ^slicing.description = "Slice stating support for FHIRcast extension"
* rest contains client 0..1 and server 0..1
* rest[client].mode = #client
* rest[server].mode = #server
* rest[server].extension contains FHIRcast{{fhirNoUc}}ConfigurationExtension named fhircast 0..1 MS

