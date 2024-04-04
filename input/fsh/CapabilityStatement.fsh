Profile: FHIRcastCapabilityStatement
Parent: CapabilityStatement
Id: fhircast-capabilitystatement
Description: "CapabilityStatment stating support for FHIRcast."
* ^extension[0].url = "http://hl7.org/fhir/StructureDefinition/structuredefinition-wg"
* ^extension[0].valueCode = #inm
* implementationGuide ^slicing.rules = #open
* implementationGuide 1..*
* implementationGuide contains fhircast 1..1
* implementationGuide[fhircast] = "http://hl7.org/fhir/uv/fhircast/ImplementationGuide/hl7.fhir.uv.fhircast|3.0.0-ballot"
* rest ^slicing.rules = #open
* rest ^slicing.discriminator.type = #value
* rest ^slicing.discriminator.path = "mode"
* rest ^slicing.description = "Slice stating support for FHIRcast extension"
* rest contains client 0..1 and server 0..1
* rest[client].mode = #client
* rest[server].mode = #server
* rest[server].extension contains FHIRcastConfigurationExtension named fhircast 0..1 MS

Extension: FHIRcastConfigurationExtension
Id: fhircast-configuration-extensions
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
  * ^fixedUri = "hub.url"
  * url 1..1 MS
  * value[x] only url 


Instance: FHIRcastCapabilityStatementExample
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
* implementationGuide[fhircast] = "http://hl7.org/fhir/uv/fhircast/ImplementationGuide/hl7.fhir.uv.fhircast|3.0.0-ballot"
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
    
