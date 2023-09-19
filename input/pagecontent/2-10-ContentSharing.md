Beyond sharing context, Subscribers subscribed to a topic require to share and update content. This section indicates the different mechanisms in FHIRcast that support content exchange. Content is exchanged using FHIR resources associated with the most recently opened context which serves as the anchor context of the exchanged information (see [Anchor Context](5_glossary.html) and [Container](5_glossary.html)).


Content exchange within a FHIRcast session can be supported in different ways. Each is discussed in the following subsections:

[2-10-1 FHIRcast Event-based Content Sharing](2-10-1-ContentSharingFHIRcastMessaging.html) |
[2-10-2 FHIR Server-based Content Sharing](2-10-2-ContentSharingFHIR.html) |

**FHIRcast Event-based Content Sharing should be used:**

* when exchanging transient content that will only be stored when reaching a certain level of maturity.
* when communicating resources that may or may not be stored in the end and may be used to communicate resource selections; for example, an Observation representing a measurement may only be stored when included in the report and a reporting solution could indicate when a measurement is selected by the user during an interactive reporting session
* the final content may or may not be stored in a FHIR store

**FHIR-based Content Sharing should be used:**

* when you already use a common FHIR server
* when all data (versions) needs to be persisted, for example to be robust against crashes.
* when the application is launched using [SMART on FHIR](https://hl7.org/fhir/smart-app-launch/index.html) and the EHR and application support context synchronization
