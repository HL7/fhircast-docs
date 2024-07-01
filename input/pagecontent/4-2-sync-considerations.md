{% include infonote.html text='This page contains guidance to implementers and is not part of the <a href="2_Specification.html">normative-track</a>; however, implementers are strongly encouraged to read and understand its content towards successful synchronization.' %}

FHIRcast describes a mechanism for synchronizing distinct applications. Sometimes things go wrong, and applications fail to synchronize or become out of sync. For example, the user within the EHR opens a new patient's record, but a Subscriber fails to process the update and continues displaying the initial patient.

### Scenarios

Depending upon the expectations of the user and the error handling of the applications in use, this scenario is potentially risky. Identified below are several distinct synchronization scenarios, ranging from lowest level of expected synchronization to highest. Each scenario suggests a level of risk resulting from potential context synchronization failure, based upon the user's ability to distinguish between disparate applications. Implementers must assess and determine the appropriate response to potential synchronization failure given their application's workflows and users.

Also note that synchronization failure is a worst-case scenario and should rarely occur in production.

#### Machine-to-machine-to-machine: Different machines, different times

**Scenario**: Clinician walks away from her desktop EHR and accesses an app on her mobile device which synchronizes to the EHR's hibernated session.

{:.grid}
| Consideration | Risk |
|---------------|------|
|Synchronization failure significance | low |
|Performance expectations|negligible|
|User inability to distinguish between synchronized applications| n/a|

**Summary**: This serial or sequential use-case is a convenience synchronization and the clinical risk for synchronization failure is low.

#### Cross device: Different machines, same time

**Scenario**: Clinician accesses her desktop EHR as well as an app on her mobile device at the same time. Mobile device synchronizes with the EHR desktop session.

{:.grid}
|Consideration|Risk|
|--|--|
|Synchronization failure significance|medium|
|Performance expectations|low|
|User inability to distinguish between synchronized applications|low|

**Summary**: The user clearly distinguishes between the applications synchronized on multiple devices and therefore clinical risk for a synchronization failure depends upon the workflow and implementer's goals. User manual action may be appropriate when synchronization fails.

#### Same machine, same time

**Scenario**: Clinician is accessing two or more applications on the same machine in a single workflow.  

{:.grid}
|Consideration|Risk|
|--|--|
|Synchronization failure significance| medium|
|Performance expectations|high|
|User inability to distinguish between synchronized applications| medium|

**Summary**: Although, the applications are distinguishable from one another, the workflow requires rapidly accessing one then another application. Application responsivity to synchronization is particularly important. Synchronization failure may introduce clinical risk and therefore user notification of synchronization failure is suggested.

#### Embedded apps: Same machine, same time, same UI

**Scenario**: Clinician accesses multiple applications within a single user interface.

{:.grid}
|Consideration|Risk|
|--|--|
|Synchronization failure significance|very high|
|Performance expectations|high|
|User inability to distinguish between synchronized applications|very high|

**Summary**: Disparate applications indistinguishable from one another require the greatest amount of context synchronization. Clinical risk of synchronization failure is critical. Application responsivity to synchronization should be high. Synchronization failure may introduce clinical risk and therefore user notification of synchronization failure is suggested.

#### Multiple machines, multiple synchronized applications, same time

**Scenario**: Clinician accesses multiple applications on different monitors and machines at the same time. Each application fulfills a specific role. A typical example of such set-up is a radiology workstation.

{:.grid}
|Consideration | Risk |
|--|--|
| Synchronization failure significance | very high |
| Performance expectations | high |
| User inability to distinguish between synchronized applications | very high |

**Summary**: Different applications that work together require the greatest amount of context synchronization. Clinical risk of synchronization failure is critical. Application responsivity to synchronization should be high. Synchronization failure may introduce clinical risk and therefore user notification of synchronization failure is likely required.

### Synchronization error situations

FHIRcast is based on a subscription model where each Subscriber receives notifications of the updated state of the topic to which the Subscriber is subscribed. There is no explicit requirement for a Subscriber to follow the context of another Subscriber. The subscription model also implies that it is the Subsribers' responsibility to maintain a contextual synchronization or to notify end users whenever the contextual synchronization is lost.
However, as noted in above scenarios, there may be risk associated with the end user expectation of having two tightly synchronized applications if they fall out of sync.

There are in some cases good reasons for a Subscriber not to follow the subscribed context and this section will outline some of the recommended approaches.

#### Blocking action on Subscriber preventing context synchronization

Many applications go into edit mode or start a modal dialog that locks the system from changing context without user intervention. Examples can be when modifying texts, reports, annotating images or performing administrative tasks. The application may then decline to follow the context of the topic to which the Subscriber is subscribed to prevent loss of end user data.

{:.grid}
|System|Failure mode|Possible actions|
|--|--|--|
| Subscriber | Modal dialog open in UI, unable to change case without losing end user data | Present end user with clear indication that contextual synchronization is lost. Respond with a http status code of 409 conflict. |
| Subscriber | Unable to change context | Client responds with a http status code of 409 conflict. If client is unable to determine inability to follow context, it responds with a 202 Accepted and sends a `SyncError` when the context change is refused, stating the source and reason for change. |
| Subscriber | Ask user whether context can be changed, user refuses. | The Subscriber responds to the initial event with a 202 Accepted and sends a `SyncError` when the context change is refused, stating the source and reason for change. |
| Subscriber | Ask user whether context can be changed, user does not react in time. | The Subscriber responds to the initial event with a 202 Accepted. When the user does not respond within 10 second,  it sends a `SyncError`. Context change is refused, stating the source and reason for change. |
| Hub | One of the Subscribers cannot follow context | Update all Subscribers with a SyncError event |

#### Failure of Subscriber preventing context synchronization

Although not intended, applications do fail. In this case the event is received by the Subscriber, but some internal error prevents the Subscriber from processing the event.

{:.grid}
|System|Failure mode|Possible actions|
|--|--|--|
| Subscriber | Internal error state prevents processing of the event. | If possible, present end user with clear indication that contextual synchronization is lost. Respond with a http status code of 50X. |
| Hub | One of the Subscribers cannot follow context | Update all Subscribers with SyncError event using information from the subscriber.name field from the original subscription of the Subscriber which failed to follow the context change. |

#### Connection is lost

This error scenario is the Hub losing contact with a Subscriber. This may be due to a Subscriber crash or a network failure. In these cases, the Subscriber would not be aware of the fact that the context has changed or that the context change events are not received.

{:.grid}
|System|Failure mode|Possible actions|
|--|--|--|
| Subscriber | Websocket connection is closed and cannot be reopened. | Present a clear indication to the end-user that the connection has been lost. Resubscribe to the topic. If supported by the Hub, receive [current context upon resubscription](2-4-Subscribing.html#current-context-notification-upon-successful-subscription) or retrieve the context using [Get Current Context](2-9-GetCurrentContext.html). |
| Hub | Subscriber failed to respond to an event | Update all Subscribers with a SyncError event using information from the `subscriber.name` field from the original subscription of the Subscriber which failed to respond to an event |

#### Race condition during launch

Once an application is launched with initial context, for example, the currently in context patient, the application must subscribe before it receives notifications of updated context. Between the instant of launch and the instant of a confirmed subscription, it is technically possible for context to change, such that the newly launched application joins a session with stale contextual information. In most scenarios, this problem is likely noticeable by the end user. This error situation is mitigated by the Hub sending the last relevant event(s) when a Subscriber (re)subscribes.

#### `SyncError` event received from Hub

In the scenarios where the Hub is aware of a synchronization error, it is advisable for the Hub to signal this to all Subscribers to minimize any patient risk associated with having one or more Subscribers out of sync.

{:.grid}
| System | Failure mode | Possible actions |
|--|--|--|
| Subscriber | SyncError event received from Hub | Present end user with clear indication that contextual synchronization is lost |

#### Subscription has expired

The Subscriber's subscription has expired causing it no longer receive event. The Subscriber can prevent this situation by resubscribing before the subscription expires.

{:.grid}
| System | Failure mode | Possible actions |
|--|--|--|
| Subscriber | Subscription has expired | Present a clear indication to the end-user that the subscription has expired. Resubscribe to the topic. If supported by the Hub, receive [current context upon resubscription](2-4-Subscribing.html#current-context-notification-upon-successful-subscription) or retrieve the context using [Get Current Context](2-9-GetCurrentContext.html). |
| Hub | None | The hub cannot distinguish between an intentional and unintentional subscription expiration. So the Hub cannot mitigate this situation. |

#### Race condition between context changes

Two or more Subscribers are sending context change events shortly after each other causing the events to cross.

{:.grid}
| System | Failure mode | Possible actions |
|--|--|--|
| Subscriber | Receive older events | Ensure that the timestamp is checked and that events older than the event that triggered the current context state are ignored. |
| Subscriber | Conflicting events | When a Subscriber detects an event with a suggested context change that is sent shortly after its own event, it should compare the timestamp of these events and treat the most recent event as current. It should also not respond with a resend of its context change without querying the user to prevent triggering an endless context switch waterfall. |
| Hub | None | The Hub cannot and should not be involved in distinguishing between an intentional and unintentional event expiration. So the Hub cannot mitigate this situation. |

#### Synchronization considerations for UserLogout

When the user decides end the user-session and logout, it can broadcast this information to other Subscribers.

{:.grid}
| System | Failure mode | Possible actions |
|--|--|--|
| Subscriber | The user initiates log-out | Send `userLogout` event, wait time out period for a possible `SyncError` and log out. If no `SyncError` is received, ensure that data that needs to be persisted is stored. Unsubscribe and logout. If a `SyncError` is received, do not log out. |
| Subscriber | Receive `userLogout` event, auto agree | Present to the user that a log-out will occur, persist all information, unsubscribe and log-out. |
| Subscriber | Receive `userLogout` event, storage fails | Present to the user that a log-out is in progress, indicate that information cannot be persisted. Send a `SyncError` on the `userLogout` event. |
| Subscriber | Receive `userLogout` event, present choice | Present to the user that a log-out is requested, to be sure persist all information. Present choice to the user, if the user agrees logout, unsubscribe and logout. If not keep application open. |
| Hub | Receive `userLogout` event | Forward event to all applications. Track subscriptions as usual, no implicit hub behavior. |

#### Synchronization considerations for UserHibernate

The system where the Hub and/or one or more of the Subscribers run enters hibernate. FHIRcast allows this information to be send to other Subscribers. The main risk here is that the applications that hibernate will not receive the events. As the user is aware of this, the risk is minimal.

{:.grid}
| System | Failure mode | Possible actions |
|--|--|--|
| Hub | Hub detects the system hibernates | Send `UserHibernate` event (system-initiated), ensure current context and content state is stored. If possible  |
| Subscriber | Subscriber detects the system hibernates | Send `UserHibernate` event (system-initiated), ensure current state is shared and stored. Optionally unsubscribe application to prevent `SyncError` events. |
| Subscriber | Subscriber detects the user requests hibernation | Send `UserHibernate` event (user-initiated), ensure current state is shared and stored. Optionally unsubscribe application to prevent `SyncError` events. |
| Hub | Subscriber receives `UserHibernate` event | Forward the event. No special implicit behavior. |
| Subscriber | Subscriber receives `UserHibernate` event | Expect that the Subscriber that send the event will be unlikely to respond. Possibly inform the user that some applications will not be in sync. |

### Re-establishing sync

The situations in which a sync error can occur are indicated in the previous section. Once a sync error situation occurs, applications need to be able to recover from it.

#### Subscribers that initiate a context change

A Subscriber that initiates a context change and receives a `SyncError` related to a context change event it sent, SHOULD resend this event at regular intervals until sync is reestablished or another, newer, event has been received. It is recommended to wait at least 10 seconds before resending the event. Note that such resend will use the timestamp of the original event to prevent race conditions.

#### Subscriber that follow context change

A Subscriber that follows context change should monitor new events or re-sends of the old event. When an event is received with a timestamp equal or newer than the event that caused the `SyncError`, it assumes sync is restored unless a new `SyncError` is received.

#### Subscriber that lose the connection to the Hub

Subscriber that lose the connection to the Hub should resubscribe to the topic. Once resubscribed and the most recent relevant event has been received, the Subscriber can assume that sync is restored.

#### Hubs

A Hub that sends a `SyncError` event (e.g. after it is not able to deliver an event) may resend this event regularly until the sync has been reestablished or a newer event has been received.

### Open topics

* Should a Subscriber get all SyncError's or only those related to events to which it subscribed?
* Does a Hub send an `SyncError` for each Subscriber that cannot be reached or refused, or is the Hub allowed to combine them in one.

