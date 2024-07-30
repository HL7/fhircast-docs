Profile: FHIRcastDiagnosticReportOpen
Parent: DiagnosticReport
Id: fhircast-diagnostic-report-open
Title: "FHIRcast Diagnostic Report for Open Events"
Description:
"""
Provides guidance as to which DiagnosticReport attributes should be present and considerations as to how each attribute should be valued in all [FHIR resource]-open events.

At least one business identifier of the DiagnosticReport SHALL be provided in a [FHIR resource]-open request.

Typically the report is associated with an order from an information system.  In this case the accession number of the order is provided in the DiagnosticReport's `basedOn` array attribute as a reference using a ServiceRequest reference type and the “ACSN” identifier type.  The accession number SHALL be included as a business identifier if it is known.

A reporting system may also include its own identifier and should use an appropriate identifier type and system when supplying such a business identifier.

In radiology reports or other image related uses of FHIRcast, at least one imaging study would likely be the subject of the report and included in the event's context.  In this case, the reference to one or more ImagingStudy resources would be provided.

**FHIR R4 versus FHIR R5**
In the FHIR R4 DiagnosticReport resource image study references would be placed in the `imagingStudy` attribute.  In a FHIR R5 (or above) DiagnosticReport this attribute has been renamed `study` since the allowed reference types has been expanded to include references to GenomicStudy resources.  This is obviously a breaking change.

In FHIRcast deployments based on FHIR R5, the attribute `study` SHALL be used rather than the `imagingStudy` attribute.

Additionally FHIR R5 includes a `supportingInfo` attribute. While not yet formally provided for in FHIR R5 (R6 formalizes this support), it has been recommended that the next release of FHIR allow an ImagingStudy reference be included in this attribute so that the DiagnosticReport could indicate one or more image studies were consulted during the creation of the report. As such in FHIR R5 deployments, this field should be considered labeled as must support.
"""
* ^extension[0].url = "http://hl7.org/fhir/StructureDefinition/structuredefinition-wg"
* ^extension[0].valueCode = #inm
* id 1..1 
* id ^short = "A logical id of the resource SHALL be provided."
* id ^definition =
"""
A logical id of the resource SHALL be provided. It may be the `id` associated with the resource as persisted in a FHIR server.  If the resource is not stored in a FHIR server, the Subscriber requesting the context change SHOULD use a mechanism to generate the `id` such that it will be globally unique (e.g., a [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier)).  When a [FHIR resource]-close event including this report is requested, the Subscriber requesting the context be closed SHALL use the same DiagnosticReport `id` which was provided in the [FHIR resource]-open event (see also [FHIRcast DiagnosticReport for Close Events](StructureDefinition-fhircast-diagnostic-report-close.html)).
"""
* identifier 0..* MS
* identifier ^short = "A business identifier of the DiagnosticReport may be provided as part of the [FHIR resource]-open request (see detailed description)."
* identifier ^definition = 
"""
The Study Instance UID SHALL be included as a business identifier if it is known.  In FHIR, the Study Instance UID of an ImagingStudy is stored in the `identifier` array using the Identifier system of `urn:dicom:uid` and prefix the UID value with `urn:oid:`.
"""
* status 1..1
* status ^short = "Status of the DiagnosticReport, note this may not be known and hence have a value of `unknown`; however, is included since it is required by FHIR"
* status ^definition = 
"""
While initially the `status` of the report may begin as `unknown` or `preliminary` (or something else), throughout the lifecycle of the context the report's status may transition.  For example, a reporting application may enable a clinician to sign the report.  In such a situation this change in status could become final and would be communicated through a [`DiagnosticReport-update`](3-6-3-DiagnosticReport-update.html)
event prior to the DiagnosticReport context being closed by a DiagnosticReport-close event.  
"""
* subject 1..1
* subject only Reference(FHIRcastPatientOpen)
* subject ^short = "Reference to the Patient resource associated with the DiagnosticReport"
* subject ^definition =
"""
A reference to the FHIR Patient resource describing the patient whose report is currently in context SHALL be present.
"""
* basedOn 0..* MS
* basedOn ^short = "At least one business identifier of the DiagnosticReport SHALL be provided in a [FHIR resource]-open request (see detailed description)."
* basedOn ^definition =
"""
The accession number of the order which directly or in directly triggered the report to be created SHALL be included as a business identifier if it is known.  The accession number is stored as Reference.identifier using the ServiceRequest Reference type and the “ACSN” identifier type.
"""
* imagingStudy only Reference(FHIRcastImagingStudyOpen)
* imagingStudy ^short = "Imaging study (or studies) which are the subject of this report"
* imagingStudy ^definition =
"""
If the report is created as part of an imaging scenario, at least one imaging study would likely be the subject of the report and included in the event's context.  In this case a reference to the ImagingStudy (or references to the ImagingStudy's) in the event's context SHALL be present in the `imagingStudy` array if known.
"""
* obeys business-identifier

Invariant:   business-identifier
Description: "identifier array or basedOn array SHALL contain at least one element"
Expression:  "identifier.exists() or basedOn.exists()"
Severity:    #error
XPath:       "f:identifier or f:basedOn"

Instance: FHIRcastDiagnosticReportOpen-Example
InstanceOf: FHIRcastDiagnosticReportOpen
Usage: #example
Description: "Example of a DiagnosticReport which could be used in a [FHIR resource]-open event"
* id = "2402d3bd-e988-414b-b7f2-4322e86c9327"
* status = http://terminology.hl7.org/fhir/ValueSet/diagnostic-report-status#unknown
* subject = Reference(FHIRcastPatientOpen-Example)
* code = http://loinc.org#19005-8 "Radiology Imaging study [Impression] (narrative)"
* basedOn[0].type = "ServiceRequest"
* basedOn[=].identifier.type.coding = http://terminology.hl7.org/CodeSystem/v2-0203#ACSN
* basedOn[=].identifier.system = "urn:oid:2.16.840.1.113883.19.5"
* basedOn[=].identifier.value = "GH339884"
* basedOn[=].identifier.assigner.reference = "Organization/a92ac1be-fb34-49c1-be58-10928bd271cc"
* basedOn[=].identifier.assigner.display = "My Healthcare Provider"
* imagingStudy = Reference(FHIRcastImagingStudyOpen-Example)