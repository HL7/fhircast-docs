This section contains various design decisions that might be relevant to understand the FHIRcast specification. [All substantive changes](https://jira.hl7.org/issues/?filter=12642&jql=project%20%3D%20FHIR%20AND%20Specification%20%3D%20%22FHIRCast%20(FHIR)%20%5BFHIR-fhircast%5D%22%20AND%20status%20%3DApplied%20%20and%20%22Change%20Impact%22%20%3D%20Non-compatible%20%20ORDER%20BY%20id) are represented in jia. 

## Change Log STU2 to STU3

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

Significant complexity is created if/when subscribers support subsets of the FHIRcast context synchronization events used during a context synchronization session. If a hub permits subscribers to subscribe to subsets of one another's events, the hub is required to "generate" or "derive open events. This is required in the specification of [Event Notifications](2-5-EventNotification.html#hub-generated-open-events) and discussed in [Multi-anchor considerations](4-5-multi-anchor-considerations.html)


### `update` events (aka Content Sharing)

STU3 introduces the concept of content sharing.

### `select` events

STU3 introduces the (experimental) concept of _selection_.
