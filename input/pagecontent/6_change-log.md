# Revision History
All changes to the FHIRcast specification are tracked in the [specification's HL7 github repository](https://github.com/HL7/fhircast-docs/commits/master). Further, issues may be submitted and are tracked in [jira](https://jira.hl7.org/browse/FHIR-25651?filter=12642) or (historically as) [github issues](https://github.com/HL7/fhircast-docs/issues).   For the reader's convenience, the below table additionally lists significant changes to the specification.

## xxxx Significant changes as part of the STU2 publication included: 
* removal of the Heartbeat event

## 20200715 Significant changes as part of the STU2 publication included: 

* Introduction of WebSockets as the preferred communication mechanism over webhooks.
* Creation of a FHIR CapabilityStatement extension to support Hub capability discovery. 
* Additional, required information on `SyncError` OperationOutcome (namely communication of the error'd event's id and event name). 
* Websocket WSS URL communicated in HTTP body, instead of `Content-Location` HTTP header.
* Subscribers should differentiate between immediately applied context changes and mere successfully received notifications with HTTP code responses of 200 and 202, respectively.

## 20240401 Change Log STU2 to STU3

### Spec format moved to FHIR Implementation Guide
[FHIRcast STU2](https://fhircast.hl7.org/specification/STU2/) was the last version of FHIRcast published with our bespoke mkdocs publication pipeline. STU3 and beyond will be published as proper FHIR IGs, including the use of FHIR profiles.

#### New events added to event library
* home-open
* heartbeat
* encounter-open
* encounter-close
* imagingstudy-open
* imagingstudy-close
* diagnosticreport-open
* diagnosticreport-close
* diagnosticreport-update
* diagnosticreport-select

#### Get Current Context RESTful API is added as optional

The [Get Current Context API](2-9-GetCurrentContext.html) was added to the specification.

#### FHIRcast starts to become a "base specification"

With the addition of update and select events, the scope of the FHIRcast specification significantly increases beyond context synchronization. In part this has lead to this FHIRcast publication specifying capabilities which require additional specification to be applied to specific interoperability use-cases. 

### Changes to Context Synchronization
#### Remove `webhook` channel
In STU1 and STU2, FHIRcast supported a `webhook` channel (URL callbacks). As part of FHIRcast STU3, support for `webhooks` was removed in favor of `websockets` as the single communication method. The field `hub.channel.type` was used to indicate the channel type to use for event notification. This field has been retained in order to support backward compatibility as well as facilitate potentially adding new channels in the future. Similarly, the conformance statement related to WebSocketsupport was retained.

#### New context synchronization events
* home-open
* encounter-open
* encounter-close
* heartbeat

#### Hub Generated `open` events

Significant complexity is created if/when subscribers support subsets of the FHIRcast context synchronization events used during a context synchronization session. If a hub permits subscribers to subscribe to subsets of one another's events, the hub is required to "generate" or "derive open events. This is required in the specification of [Event Notifications](2-5-EventNotification.html#hub-generated-open-events) and discussed in [Multi-anchor considerations](4-2-3-multi-anchor-considerations.html)

### `update` events (aka Content Sharing)

STU3 introduces the concept of content sharing.
### `select` events

STU3 introduces the (experimental) concept of _selection_.

## Questions to implementers
Scattered throughout the FHIRcast specification are the  questions to implementers, the following hyperlink directly to them:
* [2-4-Subscribing.html#current-context-notification-upon-successful-subscription](2-4-Subscribing.html#current-context-notification-upon-successful-subscription)
* [2-5-EventNotification.html#hub-generated-syncerror-events](2-5-EventNotification.html#hub-generated-syncerror-events)
* [2-9-GetCurrentContext.html#get-current-context](2-9-GetCurrentContext.html#get-current-context)
* [4-1-launch-scenarios.html#dynamic-registration-for-native-apps-following-smart-launch-parent-application-registers-dynamic-application-which-participates-in-fhircast-session](4-1-launch-scenarios.html#dynamic-registration-for-native-apps-following-smart-launch-parent-application-registers-dynamic-application-which-participates-in-fhircast-session)
* [4-2-3-multi-anchor-considerations.html#hub-derives-open-events](4-2-3-multi-anchor-considerations.html#hub-derives-open-events)
* [4-2-3-multi-anchor-considerations.html#hub-may-or-may-not-derive-close-events](4-2-3-multi-anchor-considerations.html#hub-may-or-may-not-derive-close-events)


# FHIR Publication Details

## Intellectual Property Statements

{% include ip-statements.xhtml %}

## Cross Version Analysis

{% include cross-version-analysis.xhtml %}

## Package Dependencies

{% include dependency-table.xhtml %}

## Global Profile Definitions

{% include globals-table.xhtml %}
