# ContactsManager
A simple tool to help clean up contacts. 

# How it works
1. Scans the user's phone directory
2. For the time being, it categorizes the contacts into four sections namely
    * Contacts without phone numbers
    * Contacts missing names
    * Normal contacts; consisting of both names and a phone number at the minimum
    * Empty Contacts i.e. no name, phone number or email address
3. Prompt user to permanently delete desired category

# Test Case
## Before Use

_Total Contacts: 2991_

_No Phone Numbers: 800_

_No Names: 56_

_Normal Contacts: 430_

_Empty Contacts: 1705_

## After Use

_Total Contacts: 427_

_No Phone Numbers: 0_

_No Names: 0_

_Normal Contacts: 427_

_Empty Contacts: 0_

# Encountered Challenges
1. First time using the [Contacts](https://developer.apple.com/reference/contacts) API
2. Continously encountered the error

> Terminating app due to uncaught exception 'CNPropertyNotFetchedException', reason: 'A property was not requested when contact was fetched.'

which I resolved by changing my keys to `CNContactVCardSerialization.descriptorForRequiredKeys()` instead of listing them one after the next; credits to [S/O](http://stackoverflow.com/questions/32857466/how-to-use-method-datawithcontacts-in-cncontactvcardserialization/32900658#32900658).

# Disclaimer
This project does not fully demostrate my programming abilities. Obviously there is room for improvement but this was meant to be a tool that'll personally help me organize my contacts. I found it rather inefficient and a waste of time to manually go through my contacts and clean them up appropriately hence this simple tool came in handy :blush:
