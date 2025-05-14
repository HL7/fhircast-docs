Profile: FHIRcastEncounterClose
Parent: Encounter
Id: fhircast-encounter-close
Title: "FHIRcast Encounter for Close Events"
Description: "Provides guidance as to which Encounter attributes should be present and considerations as to how each attribute should be valued in all [FHIR resource]-close events."
* insert SetWorkgroupFmmAndStatusRule( #inm, 4, #active)
* id 1..1 
* id ^short = "A logical id of the resource SHALL be provided."
* id ^definition =
"""
A logical id of the resource SHALL be provided. The provided `id` SHALL be the same Encounter id which was provided in the corresponding [FHIR resource]-open event (see also [FHIRcast Encounter for Open Events](StructureDefinition-fhircast-encounter-open.html)).
"""
* identifier 0..* MS
* identifier ^short = "At least one identifier of the Encounter SHOULD be provided in a [FHIR resource]-close request."
* identifier ^definition = 
"At least one `identifier` of the Encounter SHOULD be provided in a [FHIR resource]-close request. Providing one or more of the `identifier` values for the Encounter which was provided in the corresponding [FHIR resource]-open event enables Subscribers to perform identity verification according to their requirements."
* status ^short = "Status of the encounter.  Note that the `status` attribute is required by the FHIR specification but may not be of significant interest when used in FHIRcast"
* status ^definition = 
"""
Status of the encounter.  Note that the `status` attribute is required by the FHIR specification; however, the actual status of an encounter may not be known nor of significant interest when closing an encounter context.  Hence, the `status` attribute may frequently have a value of `unknown`.
"""
* class ^short = "Classification of the encounter.  Note that the `class` attribute is required by the FHIR specification but may not be of significant interest when used in FHIRcast"
* class ^definition = 
"""
Class of the encounter.  Note that the `class` attribute is required by the FHIR specification; however, an encounter's class is generally not of significant interest when closing a context, hence the value of the `class` attribute should usually be ignored.  Starting with FHIR R5, the `class` attribute is optional and will be removed from this profile in a FHIRcast specification based on FHIR R5 or above.
"""
* subject 1..1
* subject only Reference(FHIRcastPatientClose)
* subject ^short = "Reference to the patient associated with the encounter"
* subject ^definition = 
"SHALL be valued with a reference to the Patient resource which is present in the [FHIR resource]-close event."

Instance: FHIRcastEncounterClose-Example
InstanceOf: FHIRcastEncounterClose
Usage: #example
Description: "Example of an encounter which could be used in a [FHIR resource]-close event.  Note that due to limitation of tools used to publishing the specification the below resource `id` is appended with '-close'.  The specification requires that the resource `id` in the -close be identical to the resource `id` provided in the corresponding -open; hence in the real world the '-close' suffix would not be present."
* id = "8cc652ba-770e-4ae1-b688-6e8e7c737438-close"
* status = http://terminology.hl7.org/fhir/ValueSet/encounter-status#unknown
* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#AMB
* identifier.use = http://terminology.hl7.org/fhir/ValueSet/identifier-use#official
* identifier.value = "r2r22345"
* identifier.system = "http://myhealthcare.example.com/visits"
* subject = Reference(FHIRcastPatientClose-Example)
