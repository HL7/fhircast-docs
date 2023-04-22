Profile: FHIRcastPatientClose
Parent: Patient
Id: fhircast-patient-close
Title: "FHIRcast Patient for Close Events"
Description: "Provides guidance as to which Patient attributes should be present and considerations as to how each attribute should be valued in all [FHIR resource]-close events."
* id 1..1 
* id ^short = "A logical id of the resource must be provided."
* id ^definition =
"""
A logical id of the resource must be provided. The provided `id` SHALL be the same Patient id which was provided in the [FHIR resource]-open event (see also
[FHIRcast Patient for Open Events](StructureDefinition-fhircast-patient-open.html)).
"""
* identifier 0..* MS
* identifier ^short = "At least one identifier of the Patient SHOULD be provided in an [FHIR resource]-close request."
* identifier ^definition = 
"""
At least one `identifier` of the Patient SHOULD be provided in a [FHIR resource]-close request. Providing one or more of the `indentifier` values for the Patient
which was provided in the corresponding [FHIR resource]-open event enables Subscribers to perform identity verification according to their requirements.
"""

/*
Instance: FHIRcastPatientClose-Example
InstanceOf: FHIRcastPatientClose
Usage: #example
Description: "Example of a patient which could be used in a [FHIR resource]-close event"
* id = "503824b8-fe8c-4227-b061-7181ba6c3926"
* identifier[0].use = http://terminology.hl7.org/fhir/ValueSet/identifier-use#official
* identifier[=].type = http://terminology.hl7.org/fhir/ValueSet/identifier-type#MR
* identifier[=].system = "urn:oid:2.16.840.1.113883.19.5"
* identifier[=].value = "4438001"
* identifier[=].assigner.reference = "Organization/a92ac1be-fb34-49c1-be58-10928bd271cc"
* identifier[=].assigner.display = "My Healthcare Provider"
*/
