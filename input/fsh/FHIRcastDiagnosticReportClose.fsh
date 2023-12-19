Profile: FHIRcastDiagnosticReportClose
Parent: DiagnosticReport
Id: fhircast-diagnostic-report-close
Title: "FHIRcast DiagnosticReport for Close Events"
Description:
"""
Provides guidance as to which DiagnosticReport attributes should be present and considerations as to how each attribute should be valued in all [FHIR resource]-close events.

**FHIR R4 versus FHIR R5**
In the FHIR R4 DiagnosticReport resource image study references would be placed in the `imagingStudy` attribute.  In a FHIR R5 (or above) DiagnosticReport this attribute has been renamed `study` since the allowed reference types has been expanded to include references to GenomicStudy resources.  This is obviously a breaking change.

In FHIRcast deployments based on FHIR R5, the attribute `study` SHALL be used rather than the `imagingStudy` attribute.

Additionally FHIR R5 includes a `supportingInfo` attribute. While not yet formally provided for in FHIR R5, it has been recommended that the next release of FHIR allow an ImagingStudy reference be included in this attribute so that the DiagnosticReport could indicate one or more image studies were consulted during the creation of the report. As such in FHIR R5 deployments, this field is considered labeled as must support.
"""
* id 1..1 
* id ^short = "A logical id of the resource SHALL be provided."
* id ^definition =
"""
A logical id of the resource SHALL be provided. The provided `id` SHALL be the same DiagnosticReport id which was provided in the [FHIR resource]-open event (see also [FHIRcast DiagnosticReport for Open Events](StructureDefinition-fhircast-diagnostic-report-open.html)).
"""
* identifier 0..* MS
* identifier ^short = "At least one identifier of the DiagnosticReport SHOULD be provided in an [FHIR resource]-close request."
* identifier ^definition = 
"""
At least one `identifier` of the DiagnosticReport SHOULD be provided in a [FHIR resource]-close request. This could be a business identifier provided in the [DiagnosticReport-open](3-6-1-DiagnosticReport-open.html) event or a business identifier provided subsequently in a [DiagnosticReport-update](3-6-3-DiagnosticReport-update.html) event.
"""
* basedOn 0..* MS
* basedOn ^short = "At least one business identifier of the DiagnosticReport SHOULD be provided in a [FHIR resource]-open request (see detailed description)."
* basedOn ^definition =
"""
The accession number of the order which directly or in directly triggered the report to be created SHOULD be included as a business identifier if it is known.  The accession number is stored as Reference.identifier using the ServiceRequest Reference type and the “ACSN” identifier type.
"""
* imagingStudy ^short = "Imaging study (or studies) which are the subject of this report"
* imagingStudy ^definition =
"""
If the report is created as part of an imaging scenario, at least one imaging study would likely be the subject of the report and included in the event's context.  In this case a reference to the ImagingStudy (or references to the ImagingStudy's) in the event's context SHOULD be present in the `imagingStudy` array if known.
"""
* subject 1..1
* subject only Reference(FHIRcastPatientClose)
* subject ^short = "Reference to the patient associated with the report"
* subject ^definition = 
"SHALL be valued with a reference to the Patient resource which is present in the [FHIR resource]-close event."

Instance: FHIRcastDiagnosticReportClose-Example
InstanceOf: FHIRcastDiagnosticReportClose
Usage: #example
Description: "Example of a DiagnosticReport which could be used in a [FHIR resource]-close event.  Note that due to limitation of tools used to publishing the specification the below resource `id` is appended with '-close'.  The specification requires that the resource `id` in the [FHIR resource]-close be identical to the resource `id` provided in the corresponding [FHIR resource]-open; hence in the real world the '-close' suffix would not be present."
* id = "2402d3bd-e988-414b-b7f2-4322e86c9327-close"
* status = http://terminology.hl7.org/fhir/ValueSet/diagnostic-report-status#final
* code = http://loinc.org#19005-8 "Radiology Imaging study [Impression] (narrative)"
* identifier.use = http://terminology.hl7.org/fhir/ValueSet/identifier-use#official
* identifier.value = "GH339884.RPT.0001"
* identifier.system = "http://myhealthcare.com/reporting-system"
* subject = Reference(FHIRcastPatientClose-Example)
* conclusionCode = http://snomed.info/sct#368009 "Heart valve disorder"
