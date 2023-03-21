### Revision History
All changes to the FHIRcast specification are tracked in the [specification's HL7 github repository](https://github.com/HL7/fhircast-docs/commits/master). Further, issues may be submitted and are tracked in [jira](https://jira.hl7.org/browse/FHIR-25651?filter=12642) or (historically as) [github issues](https://github.com/HL7/fhircast-docs/issues).   For the reader's convenience, the below table additionally lists significant changes to the specification.

#### 20200715 Significant changes as part of the STU2 publication included: 

* Introduction of WebSockets as the preferred communication mechanism over webhooks.
* Creation of a FHIR CapabilityStatement extension to support Hub capability discovery. 
* Additional, required information on `syncerror` OperationOutcome (namely communication of the error'd event's id and event name). 
* Websocket WSS URL communicated in HTTP body, instead of `Content-Location` HTTP header.
* Subscribers should differentiate between immediately applied context changes and mere successfully received notifications with HTTP code responses of 200 and 202, respectively.

### FHIR Publication Details

#### Intellectual Property Statements

{% include ip-statements.xhtml %}

#### Cross Version Analysis

{% include cross-version-analysis.xhtml %}

#### Package Dependencies

{% include dependency-table.xhtml %}

#### Global Profile Definitions

{% include globals-table.xhtml %}
