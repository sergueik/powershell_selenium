### Info

directory contains standalone console app to test the FileHelper and the utility class itself

fixed and cleaned up code from [article](https://www.codeproject.com/Articles/8600/FileHelperTesterEx-C-s-WebClient-FileHelperTester-with-more-fu)

### Testing

* navigate to `Program\bin\Debug` and launch

```cmd
.\FileHelperTester.exe --datafile=c:\temp\data.txt --retries=10 --retryinterval=1000  --holdinterval=5000
```

this will print
```text
Datafile: c:\temp\data.txt
HoldInterval: 5000
RetryInterval: 1000
Retries: 5
Closing stream
Read text Line1: ONE
Line2: two
Line3: three
entry: value
UPTIME:  9hours 59 min
Version: 6.3.9600
Computer: SERGUEIK53
Line5: five
DATE: Monday, February 28, 2022
TIME: 7:02:12 PM
QUEUE_LENGTH: 0
Wait for 5.00 sec before closing  the file
```
  

run two of the same in sobling console windows
The one which starts later, will display:
```text
Datafile: c:\temp\data.txt
HoldInterval: 5000
RetryInterval: 1000
Retries: 10
Got Exception during Read: The process cannot access the file 'c:\temp\data.txt'
 because it is being used by another process.. Wait 1.00 sec and retry
Got Exception during Read: The process cannot access the file 'c:\temp\data.txt'
 because it is being used by another process.. Wait 1.00 sec and retry
Got Exception during Read: The process cannot access the file 'c:\temp\data.txt'
 because it is being used by another process.. Wait 1.00 sec and retry
Got Exception during Read: The process cannot access the file 'c:\temp\data.txt'
 because it is being used by another process.. Wait 1.00 sec and retry
Closing stream
Read text Line1: ONE
Line2: two
Line3: three
entry: value
UPTIME:  9hours 59 min
Version: 6.3.9600
Computer: SERGUEIK53
Line5: five
DATE: Monday, February 28, 2022
TIME: 7:02:12 PM
QUEUE_LENGTH: 0
Wait for 5.00 sec before closing  the file
Closing stream
```

if no settings are provided on the command line the values are read from `FileHelperTester.exe.config` (`Program\App.config`)

the broken revision of `FileHelper.cs` will throw the following error:
```text
Datafile: c:\temp\data.txt
HoldInterval: 5000
RetryInterval: 1000
Retries: 10
Got Exception during Read: The process cannot access the file 'c:\temp\data.txt'
 because it is being used by another process.. Wait 1.00 sec and retry
Closing stream

Unhandled Exception: System.NullReferenceException: Object reference not set to an instance of an object.
   at Utils\FileHelper.cs:line 98
   at Program\Program.cs:line 74

```
### See Also
### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
