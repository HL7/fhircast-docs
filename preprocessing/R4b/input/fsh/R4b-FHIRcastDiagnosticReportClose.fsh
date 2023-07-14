Profile: FHIRcastR4bDiagnosticReportClose
Parent: DiagnosticReport
Id: fhircast-r4b-diagnostic-report-close
Title: "FHIRcast R4b DiagnosticReport for Close Events"
Description: "Provides guidance as to which DiagnosticReport attributes should be present and considerations as to how each attribute should be valued in all [FHIR resource]-close events."
* id 1..1 
* id ^short = "A logical id of the resource must be provided."
* id ^definition =
"""
A logical id of the resource must be provided. The provided `id` SHALL be the same DiagnosticReport id which was provided in the [FHIR resource]-open event (see also
[FHIRcast DiagnosticReport for Open Events](StructureDefinition-fhircast-diagnostic-report-open.html)).
"""
* identifier 0..* MS
* identifier ^short = "At least one identifier of the DiagnosticReport SHOULD be provided in an [FHIR resource]-close request."
* identifier ^definition = 
"""
At least one `identifier` of the DiagnosticReport SHOULD be provided in a [FHIR resource]-close request. This could be a business identifier provided in the DiagnosticReport-open event
or provided subsequently in a [DiagnosticReport-update](3-6-3-diagnosticreport-update.html) event
"""
* subject 1..1
* subject only Reference(FHIRcastR4bPatientClose)
* subject ^short = "Reference to the patient associated with the report"
* subject ^definition = 
"SHALL be valued with a reference to the Patient resource which is present in the [FHIR resource]-close event."

Instance: FHIRcastR4bDiagnosticReportClose-Example
InstanceOf: FHIRcastR4bDiagnosticReportClose
Usage: #example
Description: "Example of a DiagnosticReport which could be used in a [FHIR resource]-close event.  Note that due to limitation of tools used to publishing the specification the below
resource `id` is appended with '-close'.  The specification requires that the resource `id` in the [FHIR resource]-close be identical to the resource `id` provided in the corresponding
[FHIR resource]-open; hence in the real world the '-close' suffix would not be present."
* id = "r4b-2402d3bd-e988-414b-b7f2-4322e86c9327-close"
* status = http://terminology.hl7.org/fhir/ValueSet/diagnostic-report-status#unknown
* subject = Reference(FHIRcastR4bPatientOpen-Example)
* code = http://loinc.org#19005-8 "Radiology Imaging study [Impression] (narrative)"
* identifier.use = http://terminology.hl7.org/fhir/ValueSet/identifier-use#official
* identifier.value = "GH339884.RPT.0001"
* identifier.system = "http://myhealthcare.com/reporting-system"
* subject = Reference(FHIRcastR4bPatientClose-Example)
