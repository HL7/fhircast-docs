Instance: FHIRcastSampleHealthcareProvider
InstanceOf: Organization
Title: "Example Healthcare Provider Organization"
Usage: #example
Description: """
Example of a Organization resource representing a Healthcare provider. This resource is not a formal part of FHIRcast 
and is only present as an endpoint for References.
"""
* identifier
  * system = "http://example.org"
  * value = "theAmavingHospital"
* active = true
* name = "Example Healthcare Provider"
* type = http://terminology.hl7.org/CodeSystem/organization-type#prov