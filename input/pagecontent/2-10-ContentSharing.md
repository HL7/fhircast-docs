Beyond sharing context, Subscribers subscribed to a topic require to share and update content. This section indicates the different mechanisms in FHIRcast that support content exchange.

Content exchange within a FHIRcast session can be supported in three different ways. Each is discussed in the following subsections:

[2-10-1 FHIR server based content sharing](2-10-1-ContentSharingFHIR.html) |
[2-10-2 FHIRcast messaging based content sharing](2-10-2-ContentSharingFHIRcastMessaging.html) |
[2-10-3 Hybrid approach supporting both FHIR server and FHIRcast messaging.](2-10-3-ContentSharingHybrid.html) |

When to use which mechanism (FHIR restfull vs FHIRcast update)?

**FHIRcast content exchange should be used:**

* When starting with FHIRcast.
* When aligning on *transient* content that will only be stored when reaching a certain level of maturity.
* When communicating resources that may or may not be stored in the end and are used to communicate e.g. selections. E.g. selecting a measurement in an image viewer, the Observation representing this measurement may only be stored when included in the report.
* When the final result may or may not be stored in a FHIR store.
* Imaging related (worklist driven) or proprietary applications.

**FHIR content should be used:**

* When you start from FHIR and add FHIRcast.
* When all data (versions) needs to be persisted, e.g. to be robust against crashes.
* When you already use a common FHIR server, e.g. when the applications are launched using SMART on FHIR; EHR driven/ SMART apps that are extended to support context synchronzitions applications.
