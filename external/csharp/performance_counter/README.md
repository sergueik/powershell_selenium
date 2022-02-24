### Info

This directory contains code from the __Monitoring network speed__ [article](https://www.codeproject.com/Articles/6259/Monitoring-network-speed)  converted to later Visual Studio project with the intent to use it as skeleton for  `\\System\\Processor Queue Length` performance counter value collection for custom Load Average metric 


### See Also
  * [Manually rebuild performance counter library values](https://docs.microsoft.com/en-US/troubleshoot/windows-server/performance/rebuild-performance-counter-library-values)
  * `\\System\\Processor Queue Length` performance counter 
  not working [post](https://docs.microsoft.com/en-us/answers/questions/702384/systemprocessor-queue-length-performance-counter-n.html)
  * `typeperf.exe` [documentation](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/typeperf)
  * [Set up Performance Counters in Windows Performance Monitor](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/set-up-performance-counters-performance-monitor)
  * https://serverfault.com/questions/339282/how-can-i-save-the-counters-setup-in-windows-performance-monitor


https://www.codeproject.com/Articles/17683/A-simple-PerformanceCounter-StatusStripItem
https://www.codeproject.com/Articles/38438/Monitoring-Process-Statistics-in-C-WPF
https://www.codeproject.com/Articles/13825/Using-Custom-Attributes-to-Create-Performance-Coun
https://www.codeproject.com/Articles/6259/Monitoring-network-speed
https://www.codeproject.com/Articles/29986/A-Simple-Performance-Counter-Application
https://www.codeproject.com/Articles/10258/How-to-Get-CPU-Usage-of-Processes-and-Threads
https://www.codeproject.com/Articles/16903/Monitor-and-Display-CPU-State-Information
https://www.codeproject.com/Articles/8590/An-Introduction-To-Performance-Counters
https://www.codeproject.com/Articles/20380/An-Implementation-of-System-Monitor
https://www.codeproject.com/Articles/29242/Performance-Monitor-Made-Easy (VB.net)

https://www.codeproject.com/Articles/383774/Process-Dump-Triggered-on-Custom-Performance-Count (produce data)
# service -  refresher
https://www.codeproject.com/Articles/401584/Easy-to-learn-Window-Service

https://michaelscodingspot.com/performance-counters/
Simplified exampe (no containing class, just raw data:
```csharp
var currentProcess = Process.GetCurrentProcess().ProcessName;
PerformanceCounter privateBytes = 
    new PerformanceCounter(categoryName:"Process", counterName:"Private Bytes", instanceName:currentProcess);
PerformanceCounter gen2Collections = 
    new PerformanceCounter(categoryName:".NET CLR Memory", counterName:"# Gen 2 Collections", instanceName:currentProcess);
Debug.WriteLine("private bytes = " + privateBytes.NextValue());
Debug.WriteLine("gen 2 collections = " + gen2Collections.NextValue());
```

```csharp
 
bool exists = PerformanceCounterCategory.Exists("MyTimeCategory");
if (!exists)
{
    PerformanceCounterCategory.Create("MyTimeCategory", "My category help",
        PerformanceCounterCategoryType.SingleInstance, "Current Seconds",
        "My counter help");
}
PerformanceCounter pc = new PerformanceCounter("MyTimeCategory", "Current Seconds", false);
while (true)
{
    Thread.Sleep(1000);
    pc.RawValue = DateTime.Now.Second;

}
```
https://www.infoworld.com/article/3008626/how-to-work-with-performance-counters-in-c.html
https://www.infoworld.com/article/3008626/how-to-work-with-performance-counters-in-c.html
```
static void Main()

    {
     var performanceCounterCategories = PerformanceCounterCategory.GetCategories();

        foreach(PerformanceCounterCategory performanceCounterCategory in performanceCounterCategories)


{

         Console.WriteLine(performanceCounterCategory.CategoryName);

        }

        Console.Read();

var performanceCounterCategories = PerformanceCounterCategory.GetCategories()

     .FirstOrDefault(category => category.CategoryName == "Processor");
     var performanceCounters = performanceCounterCategories.GetCounters("_Total");
             Console.WriteLine("Displaying performance counters for Processor category:--\n");
              foreach (PerformanceCounter performanceCounter in performanceCounters)

        {
        
            Console.WriteLine(performanceCounter.CounterName);

        }
            Console.Read();

    }


    }
```
https://sourcedaddy.com/windows-7/performance-monitoring.html



