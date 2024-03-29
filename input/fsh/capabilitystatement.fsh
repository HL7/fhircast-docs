Profile: FHIRcastCapabilityStatement
Parent: CapabilityStatement
Id: fhircast-capabilitystatement
Description: "CapabilityStatment stating support for FHIRcast."
* ^extension[0].url = "http://hl7.org/fhir/StructureDefinition/structuredefinition-wg"
* ^extension[0].valueCode = #inm
* implementationGuide 1..*
* rest ^slicing.rules = #open
* rest ^slicing.discriminator.type = #value
* rest ^slicing.discriminator.path = "mode"
* rest ^slicing.description = "Slice stating support for FHIRcast extension"
* rest contains client 0..1 and server 0..1
* rest[client].mode = #client
* rest[server].mode = #server
* rest[server].extension contains FHIRcastConfigurationExtension named fhircast 0..1 MS

