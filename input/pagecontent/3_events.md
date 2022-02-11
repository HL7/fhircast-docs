<!-- ## Events -->

This section contains the definition of the event maturity model and the events defined in this specification. What events are supported by a hub is defined by the hub.

Changes made to an event's definition SHALL be documented in a change log to ensure event consumers can track what has been changed over the life of an event. The change log SHALL contain the following elements:

- Version: The version of the change
- Description: A description of the change and its impact

For example:

Version | Description
---- | ----
1.1 | Added new context FHIR object
1.0.1 | Clarified workflow description
1.0 | Initial Release


The sections in this chapter are:

* [Event Maturity Model](3-0-EventMaturityModel.html)
* [Event template](3-1-template.html)
* [Patient open event](3-2-patient-open.html)
* [Patient close event](3-3-patient-close.html)
* [Encounter open event](3-4-encounter-open.html)
* [Encounter close event](3-5-encounter-close.html)
* [ImagingStudy open event](3-6-imagingstudy-open.html)
* [ImagingStudy close event](3-7-imagingstudy-close.html)
* [Sync error event](3-8-syncerror.html)
* [User logout event](3-9-userlogout.html)
* [User hibernate event](3-10-userhibernate.html)
* [Heartbeat event](3-11-heartbeat.html)
* [DiagnosticReport-open Event](3-12-diagnosticreport-open.html)
* [DiagnosticReport-update Event](3-13-diagnosticreport-update.html)
* [DiagnosticReport-close Event](3-14-diagnosticreport-close.html)
* [DiagnosticReport-select Event](3-15-diagnosticreport-select.html)
* [Get Current Context Request](3-16-get-context.html)
