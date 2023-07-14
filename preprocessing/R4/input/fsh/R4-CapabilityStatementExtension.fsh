Extension: FHIRcastR4ConfigurationExtension
Id: fhircast-r4-configuration-extensions
Title: "R4 FHIRcast configuration extension"
Description: """
Extension in CapabilityStatement stating the location of the FHIRcast hub to be used with this FHIR server.
"""
* value[x] 0..0
* extension 1..*
* extension.url = "hub.url"
* extension.url 1..1 MS
* extension.value[x] only url 
