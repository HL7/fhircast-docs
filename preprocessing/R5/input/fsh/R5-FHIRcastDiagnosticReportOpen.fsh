Profile: FHIRcastR5DiagnosticReportOpen
Parent: DiagnosticReport
Id: fhircast-r5-diagnostic-report-open
Title: "R5 FHIRcast Diagnostic Report for Open Events"
Description:
"""
Provides guidance as to which DiagnosticReport attributes should be present and considerations as to how each attribute should be valued in all [FHIR resource]-open events.

At least one business identifier of the DiagnosticReport SHALL be provided in a [FHIR resource]-open request.

Typically the report is associated with an order from the information system.  In this case the accession number of the order is provided in the DiagnosticReport's `basedOn`
array attribute as a reference using a ServiceRequest reference type and the “ACSN” identifier type.  The accession number SHALL be included as a business identifier if it is known.

In radiology or other image related uses of FHIRcast, at least one imaging study would likely be the subject of the report and included in the event's context.  In this case
the reference to the ImagingStudy (or ImagingStudy's) in the event's context SHALL be included in the `study` array attribute.
"""
* ^fhirVersion = #5.0.0
* id 1..1 
* id ^short = "A logical id of the resource must be provided."
* id ^definition =
"""
A logical id of the resource SHALL be provided. It may be the `id` associated with the resource as persisted in a FHIR server.  If the resource is not stored in a FHIR server, the
Subscriber requesting the context change SHOULD use a mechanism to generate the `id` such that it will be globally unique
(e.g., a [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier)).  When a [FHIR resource]-close event including this report is requested, the Subscriber
requesting the context be closed SHALL use the same DiagnosticReport `id` which was provided in the [FHIR resource]-open event (see also
[FHIRcast DiagnosticReport for Close Events](StructureDefinition-fhircast-diagnostic-report-close.html)).
"""
* identifier 0..*
* identifier ^short = "A business identifier of the DiagnosticReport may be provided as part of the [FHIR resource]-open request (see detailed description)."
* identifier ^definition = 
"""
The Study Instance UID SHALL be included as a business identifier if it is known.  In FHIR, the Study Instance UID of an ImagingStudy is stored
in the `identifier` array using the Identifier system of `urn:dicom:uid` and prefix the UID value with `urn:oid:`.
"""
* status 1..1
* status ^short = "Status of the DiagnosticReport, note this may not be known and hence have a value of `unknown`; however, is included since it is required by FHIR"
* status ^definition = 
"""
While initially the `status` of the report may begin as `unknown` or `preliminary` (or something else), throughout the lifecycle of the context the report's status may transition.  For example,
a reporting application may enable a clinician to sign the report.  In such a situation this change in status could become final and would be communicated through a [`DiagnosticReport-update`](3-6-3-diagnosticreport-update.html)
event prior to the DiagnosticReport context being closed by a DiagnosticReport-close event.  
"""
* subject 1..1
* subject only Reference(FHIRcastR5PatientOpen)
* subject ^short = "Reference to the Patient resource associated with the DiagnosticReport"
* subject ^definition =
"""
A reference to the FHIR Patient resource describing the patient whose report is currently in context SHALL be present.
"""
* basedOn 1..*
* basedOn ^short = "At least one business identifier of the DiagnosticReport SHALL be provided in a [FHIR resource]-open request (see detailed description)."
* basedOn ^definition =
"""
The accession number of the order which directly or in directly triggered the report to be created SHALL be included as a business identifier if it is known.  The accession number is
stored as Reference.identifier using the ServiceRequest Reference type and the “ACSN” identifier type.
"""
* study ^short = "Imaging study (or studies) which are the subject of this report"
* study ^definition =
"""
If the report is created as part of an imaging scenario, at least one imaging study would likely be the subject of the report and included in the event's context.  In this case
a reference to the ImagingStudy (or references to the ImagingStudy's) in the event's context SHALL be present in the `study` array if known.
"""

Instance: FHIRcastR5DiagnosticReportOpen-Example
InstanceOf: FHIRcastR5DiagnosticReportOpen
Usage: #example
Description: "Example of an imaging study which could be used in a [FHIR resource]-open event"
* id = "r5-2402d3bd-e988-414b-b7f2-4322e86c9327"
* status = http://terminology.hl7.org/fhir/ValueSet/diagnostic-report-status#unknown
* subject = Reference(FHIRcastR5PatientOpen-Example)
* code = http://loinc.org#19005-8 "Radiology Imaging study [Impression] (narrative)"
* basedOn[0].type = "ServiceRequest"
* basedOn[=].identifier.type.coding = http://terminology.hl7.org/CodeSystem/v2-0203#ACSN
* basedOn[=].identifier.system = "urn:oid:2.16.840.1.113883.19.5"
* basedOn[=].identifier.value = "GH339884"
* basedOn[=].identifier.assigner.reference = "Organization/a92ac1be-fb34-49c1-be58-10928bd271cc"
* basedOn[=].identifier.assigner.display = "My Healthcare Provider"
* study = Reference(FHIRcastImagingStudyOpen-Example)
