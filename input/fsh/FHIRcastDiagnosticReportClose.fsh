Profile: FHIRcastDiagnosticReportClose
Parent: DiagnosticReport
Id: fhircast-diagnostic-report-close
Title: "FHIRcast DiagnosticReport for Close Events"
Description: "Provides guidance as to which DiagnosticReport attributes should be present and considerations as to how each attribute should be valued in all [FHIR resource]-close events."
* id 1..1 
* id ^short = "A logical id of the resource must be provided."
* id ^definition =
"""
A logical id of the resource must be provided. The provided `id` SHALL be the same DiagnosticReport id which was provided in the [FHIR resource]-open event (see also [FHIRcast DiagnosticReport for Open Events](StructureDefinition-fhircast-diagnostic-report-open.html)).
"""
* identifier 0..* MS
* identifier ^short = "At least one identifier of the DiagnosticReport SHOULD be provided in an [FHIR resource]-close request."
* identifier ^definition = 
"""
At least one `identifier` of the DiagnosticReport SHOULD be provided in a [FHIR resource]-close request. This could be a business identifier provided in the DiagnosticReport-open event or a business identifier provided subsequently in a [DiagnosticReport-update](3-6-3-diagnosticreport-update.html) event.
"""
* basedOn 0..*
* basedOn ^short = "At least one business identifier of the DiagnosticReport SHALL be provided in a [FHIR resource]-open request (see detailed description)."
* basedOn ^definition =
"""
The accession number of the order which directly or in directly triggered the report to be created SHALL be included as a business identifier if it is known.  The accession number is stored as Reference.identifier using the ServiceRequest Reference type and the “ACSN” identifier type.
"""
* imagingStudy ^short = "Imaging study (or studies) which are the subject of this report"
* imagingStudy ^definition =
"""
If the report is created as part of an imaging scenario, at least one imaging study would likely be the subject of the report and included in the event's context.  In this case a reference to the ImagingStudy (or references to the ImagingStudy's) in the event's context SHALL be present in the `imagingStudy` array if known.
"""
* subject 1..1
* subject only Reference(FHIRcastPatientClose)
* subject ^short = "Reference to the patient associated with the report"
* subject ^definition = 
"SHALL be valued with a reference to the Patient resource which is present in the [FHIR resource]-close event."

Instance: FHIRcastDiagnosticReportClose-Example
InstanceOf: FHIRcastDiagnosticReportClose
Usage: #example
Description: "Example of a DiagnosticReport which could be used in a [FHIR resource]-close event.  Note that due to limitation of tools used to publishing the specification the below
resource `id` is appended with '-close'.  The specification requires that the resource `id` in the [FHIR resource]-close be identical to the resource `id` provided in the corresponding
[FHIR resource]-open; hence in the real world the '-close' suffix would not be present."
* id = "2402d3bd-e988-414b-b7f2-4322e86c9327-close"
* status = http://terminology.hl7.org/fhir/ValueSet/diagnostic-report-status#final
* subject = Reference(FHIRcastPatientOpen-Example)
* code = http://loinc.org#19005-8 "Radiology Imaging study [Impression] (narrative)"
* identifier.use = http://terminology.hl7.org/fhir/ValueSet/identifier-use#official
* identifier.value = "GH339884.RPT.0001"
* identifier.system = "http://myhealthcare.com/reporting-system"
* subject = Reference(FHIRcastPatientClose-Example)
* conclusionCode = http://snomed.info/sct#368009 "Heart valve disorder"