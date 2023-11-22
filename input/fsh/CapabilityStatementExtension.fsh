Extension: FHIRcastConfigurationExtension
Id: fhircast-configuration-extensions
Title: "FHIRcast extension"
Context: CapabilityStatement
Description: """
Extension in CapabilityStatement stating the location of the FHIRcast hub to be used with this FHIR server.
"""
* value[x] 0..0
* extension 1..*
* extension.url = "hub.url"
* extension.url 1..1 MS
* extension.value[x] only url 
