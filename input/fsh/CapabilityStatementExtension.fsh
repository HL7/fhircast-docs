Extension: FHIRcastConfigurationExtension
Id: fhircast-configuration-extensions
Title: "FHIRcast extension"
Context: CapabilityStatement
Description: """
Extension in CapabilityStatement stating the location of the FHIRcast hub to be used with this FHIR server.
"""
* ^extension[0].url = "http://hl7.org/fhir/StructureDefinition/structuredefinition-wg"
* ^extension[0].valueCode = #inm
* value[x] 0..0
* extension 1..*
* extension.url = "hub.url"
* extension.url 1..1 MS
* extension.value[x] only url 
