!!! info "Implementer guidance" 
    This page contains guidance to implementers and is not part of the normative-track [FHIRcast specification](../specification/STU2).
    
    
# Single and Multiple Tab Applications
Applications can have different capabilities and layouts, but with FHIRcast they should still be able to stay in sync. A potential situation that could cause confusion is when a single and a multi-tab application work together. 

Let's start with a simple case.

#### Opening and Closing a Patient
The diagrams below show that the apps will start without any context, then one will open a patient triggering a Patient-open event to the other app leading to that same patient being opened in the receiving app. When the patient is close, that triggers a Patient-close event leading to the patient being closed in the other app as well.

![Simple patient open and close example](/img/guide/PatientOpenCloseExampleSource.png)





