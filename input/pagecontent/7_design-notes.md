This section contains various design decisions that might be relevant to understand the FHIRcast specification.

### Remove `webhook` channel

Originally, FHIRcast supported a `webhook` channel (URL callbacks). As part of FHIRcast STU3, support for `webhooks` was removed in favor of `websockets` as the single communication method.

The field `hub.channel.type` was used to indicate the channel type to use for event notification. This field has been retained in order to support backward compatibility as well as facilitate potentially adding new channels in the future.

Similarly, the conformance statement related to websocket support was retained.

### Content sharing approach

Two base use cases for content-exchange were emerged from the discussions: one with and without a FHIR server present.

When the Subscriber is launched using SMART on FHIR, a FHIR server is available that can and should be used for content exchange. Some Radiology spcecific uses of FHIRcast do not support a FHIR server. In these situations a distributed content exchange mechanism based on FHIRcast messages is required.

As both deployments were judged to be valid, the specification supports both options. To ensure compatibility of deployments, the specification also supports hybrid solutions where Subscribers of both types can exchange content.
Similarly, the conformance statement related to WebSocket support was retained.
