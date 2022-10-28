This section contains various design decisions that might be relevant to understand the FHIRcast specification.

### Remove `webhook` channel

Originally, FHIRcast supported a `webhook` channel (URL callbacks). As part of the STU3 ballot reconciliation, it was decided to remove support for `webhooks` as `websockets` provide all required functionality.

The field `hub.channel.type` was used to indicate the channel type to use for event notification. This field has been retained in order to facilitate adding new channels in the future.

Similarly, the conformance statement related to websocket support was retained.