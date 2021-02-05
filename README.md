# Batch Apex Error Handling

In Spring '21 Salesforce released the BatchApexErrorEvent to allow developers to get information on failing batch classes. Get your errors by email or store them in a custom object. Customize your error handling by class.

## Features
- Email batch errors to an admin or support team for evaluation and processing
- Store batch errors in a custom object including the class that failed, full stack trace, and the records that were in the batch.

## Setup Instructions
1. Deploy the contents of this repo into your org.
2. Implement Database.RaisesPlatformEvents on any batch class where you want to add error handling.
3. Customize your error handling from the Batch Errors tab.

    