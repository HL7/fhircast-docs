Beyond sharing context, Subscribers subscribed to a topic require to share and update content. This section indicates the different mechanisms in FHIRcast that support content exchange. Content is exchanged using FHIR resources associated with the most recently opened context which serves as the anchor context of the exchanged information (see [Anchor Context](5_glossary.html) and [Container](5_glossary.html)).


Content exchange within a FHIRcast session can be supported in three different ways. Each is discussed in the following subsections:

[2-10-1 FHIRcast messaging based content sharing](2-10-1-ContentSharingFHIRcastMessaging.html) |
[2-10-2 FHIR server based content sharing](2-10-2-ContentSharingFHIR.html) |
[2-10-3 Hybrid approach supporting both FHIR server and FHIRcast messaging.](2-10-3-ContentSharingHybrid.html) |

**FHIRcast-event based content sharing should be used:**

* when exchanging transient content that will only be stored when reaching a certain level of maturity.
* when communicating resources that may or may not be stored in the end and are used to communicate e.g. selections. E.g. selecting a measurement in an image viewer, the Observation representing this measurement may only be stored when included in the report.
* the final content may or may not be stored in a FHIR store

**FHIR based content should be used:**

* when you already use a common FHIR server
* when all data (versions) needs to be persisted, for example to be robust against crashes.
* when the applications are launched using SMART on FHIR (EHR driven/ SMART apps that are extended to support context synchronzitions applications).

**The hybrid solution should be used:**

* in deployments where applications dependent on both approaches need to cooperate.
* when multiple aspects of both options are required.
