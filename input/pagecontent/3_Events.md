Section [2.3 Events](2-3-Events.html) defines the events and event types supported by FHIRcast. The events that are supported by a Hub are communicated using the conformance endpoint (see [Conformance](2-7-Conformance.html)).

Although [2.3 Events](2-3-Events.html) provides the base definition of the events, many commonly used events extend on this base definition. Such extension include the definition of profiles on the resourcese used in context elements and the definition of additional context elements. 

This chapter contains the definition of these events their event maturity model.  

The sections in this chapter are:

| **3.1 Definitions** |
| [3.1.1 Event template](3-1-1-template.html) |
| [3.1.2 Event maturity model](3-1-2-eventmaturitymodel.html) |

| **3.2 Infrastructure Events** |
| [3.2.1 Sync error event](3-2-1-syncerror.html) |
| [3.2.2 User logout event](3-2-3-userlogout.html) |
| [3.2.3 User hibernate event](3-2-4-userhibernate.html) |

| **3.3 Patient Events** |
| [3.3.1 Patient-open event](3-3-1-Patient-open.html) |
| [3.3.2 Patient-close event](3-3-2-Patient-close.html) |

| **3.4 Encounter Events** |
| [3.4.1 Encounter-open event](3-4-1-Encounter-open.html) |
| [3.4.2 Encounter-close event](3-4-2-Encounter-close.html) |

| **3.5 ImagingStudy Events** |
| [3.5.1 ImagingStudy-open event](3-5-1-ImagingStudy-open.html) |
| [3.5.2 ImagingStudy-close event](3-5-2-ImagingStudy-close.html) |

| **3.6 DiagnosticReport Events** |
| [3.6.1 DiagnosticReport-open Event](3-6-1-DiagnosticReport-open.html) |
| [3.6.2 DiagnosticReport-close Event](3-6-2-DiagnosticReport-close.html) |
| [3.6.3 DiagnosticReport-update Event](3-6-3-DiagnosticReport-update.html) |
| [3.6.4 DiagnosticReport-select Event](3-6-4-DiagnosticReport-select.html) |
