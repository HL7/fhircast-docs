Profile: FHIRcastR4EncounterClose
Parent: Encounter
Id: fhircast-r4-encounter-close
Title: "FHIRcast R4 Encounter for Close Events"
Description: "Provides guidance as to which Encounter attributes should be present and considerations as to how each attribute should be valued in all [FHIR resource]-close events."
* ^fhirVersion = #5.0.0
* id 1..1 
* id ^short = "A logical id of the resource must be provided."
* id ^definition =
"""
A logical id of the resource must be provided. The provided `id` SHALL be the same Encounter id which was provided in the corresponding [FHIR resource]-open event
(see also [FHIRcast Encounter for Open Events](StructureDefinition-fhircast-encounter-open.html)).
"""
* identifier 0..* MS
* identifier ^short = "At least one identifier of the Encounter SHOULD be provided in a [FHIR resource]-close request."
* identifier ^definition = 
"At least one `identifier` of the Encounter SHOULD be provided in a [FHIR resource]-close request. Providing one or more of the `indentifier` values for the Encounter
which was provided in the corresponding [FHIR resource]-open event enables Subscribers to perform identity verification according to their requirements."
* status ^short = "Status of the Encounter, note this may not be known and hence have a value of `unknown`; however, `status` is included since it is required by FHIR"
* subject 1..1
* subject only Reference(FHIRcastR4PatientClose)
* subject ^short = "Reference to the patient associated with the encounter"
* subject ^definition = 
"SHALL be valued with a reference to the Patient resource which is present in the [FHIR resource]-close event."

Instance: FHIRcastR4EncounterClose-Example
InstanceOf: FHIRcastR4EncounterClose
Usage: #example
Description: "Example of an Encounter which could be used in a [FHIR resource]-close event.  Note that due to limitation of tools used to publishing the specification the below
resource `id` is appended with '-close'.  The specification requires that the resource `id` in the -close be identical to the resource `id` provided in the corresponding -open;
hence in the real world the '-close' suffix would not be present."
* id = "r4-8cc652ba-770e-4ae1-b688-6e8e7c737438-r4-close"
* status = http://terminology.hl7.org/fhir/ValueSet/encounter-status#unknown
* identifier.use = http://terminology.hl7.org/fhir/ValueSet/identifier-use#official
* identifier.value = "r2r22345"
* identifier.system = "http://myhealthcare.com/visits"
* subject = Reference(FHIRcastR4PatientClose-Example)
* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#NONAC