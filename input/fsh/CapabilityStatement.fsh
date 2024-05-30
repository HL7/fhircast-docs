Profile: FHIRcastCapabilityStatement
Parent: CapabilityStatement
Id: fhircast-capabilitystatement
Description: "CapabilityStatment stating support for FHIRcast. To supplement or optionally identify the location of a FHIRcast hub, a FHIR server MAY declare support for FHIRcast using the FHIRcast extension on its FHIR CapabilityStatement’s rest element."
* ^extension[0].url = "http://hl7.org/fhir/StructureDefinition/structuredefinition-wg"
* ^extension[0].valueCode = #inm
* implementationGuide ^slicing.rules = #open
* implementationGuide ^slicing.description = "Encourage FHIRcast IG to be listed"
* implementationGuide ^slicing.discriminator.type = #value
* implementationGuide ^slicing.discriminator.path = "$this"
* implementationGuide 0..*
* implementationGuide contains fhircast 0..1
* implementationGuide[fhircast] = "http://hl7.org/fhir/uv/fhircast/ImplementationGuide/hl7.fhir.uv.fhircast|3.0.0"
* rest ^slicing.rules = #open
* rest ^slicing.discriminator.type = #value
* rest ^slicing.discriminator.path = "mode"
* rest ^slicing.description = "Slice stating support for FHIRcast extension. Note that this extension might not be supportable by client-side Hubs."
* rest contains client 0..1 and server 0..1
* rest[client].mode = #client
* rest[server].mode = #server
* rest[server].extension contains FHIRcastConfigurationExtension named fhircast 0..1

Extension: FHIRcastConfigurationExtension
Id: fhircast-configuration-extension
Title: "FHIRcast extension"
Context: CapabilityStatement.rest
Description: """
Extension in CapabilityStatement stating the location of the FHIRcast hub to be used with this FHIR server.
"""
* ^extension[0].url = "http://hl7.org/fhir/StructureDefinition/structuredefinition-wg"
* ^extension[0].valueCode = #inm
* value[x] 0..0
* extension contains hubUrl 1..1 MS
* extension[hubUrl]
  * url 1..1 MS
    * ^fixedUri = "hub.url"
  * value[x] only url 


Instance: FHIRcastCapabilityStatement-Example
InstanceOf: FHIRcastCapabilityStatement
Description: "Example instance of a CapabilityStatement with FHIRcast extension."
Usage: #example
* id = "fhircast-capabilitystatement-example"
* status = #active
* date = "2024-04-04"
* kind = #instance
* fhirVersion = #4.0.1
* format[+] = #json
* format[+] = #xml
* software
  * name = "FHIR server software supporting FHIRcast"
* implementation
  * description = "Instance of FHIR server software supporting FHIRcast"
* implementationGuide[fhircast] = "http://hl7.org/fhir/uv/fhircast/ImplementationGuide/hl7.fhir.uv.fhircast|3.0.0"
* description = """
Example instance of a CapabilityStatement with FHIRcast extension.
"""
* rest[server]
  * extension[fhircast]
    * extension[hubUrl]
      * valueUrl = "http://my-fhircast-hub-url"
  * resource[+]
    * type = #Patient
    * interaction[+]
      * code = #read
    
