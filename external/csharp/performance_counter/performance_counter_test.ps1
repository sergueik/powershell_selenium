# origin: https://www.thestudentroom.co.uk/showthread.php?t=303249
# see also: http://toncigrgin.blogspot.com/2015/11/windows-perf-counters-blog4.html

# Collecting PerformanceCounters C# .NET
# similar code was throwing
# System.InvalidOperationException: Category does not exist.
# at System.Diagnostics.PerformanceCounterLib.CounterExists(String machine, String category, String counter)
# at System.Diagnostics.PerformanceCounterCategory.CounterExists(String counterName, String categoryName, String machineName)
# at System.Diagnostics.PerformanceCounterCategory.CounterExists(String counterName, String categoryName)
# when running from Windows Form application (remains unresolved by now)

Add-Type -TypeDefinition @"

using System;
using System.Timers;
using System.Collections;
using System.Diagnostics;
using System.Threading;

namespace GetInfo
{
    public class Program
    {
        public static void Main(string[] args)
        {
            for (int x = 0; x < 50; x++)
            {
                PerformanceCounter myCounter = new PerformanceCounter();
                myCounter.CategoryName = "Processor";
                myCounter.CounterName = "% Processor Time";
                myCounter.InstanceName = "_Total";
                long raw = myCounter.RawValue;

                myCounter.CategoryName = "Processor";
                myCounter.CounterName = "% Privileged Time";
                myCounter.InstanceName = "_Total";
                long raw1 = myCounter.RawValue;

                myCounter.CategoryName = "Processor";
                myCounter.CounterName = "% Interrupt Time";
                myCounter.InstanceName = "_Total";
                long raw2 = myCounter.RawValue;

                myCounter.CategoryName = "System";
                myCounter.CounterName = "Processor Queue Length";
                myCounter.InstanceName = null;
                long raw3 = myCounter.RawValue;

                myCounter.CategoryName = "Memory";
                myCounter.CounterName = "Available Mbytes";
                myCounter.InstanceName = null;
                long raw4 = myCounter.RawValue;

                myCounter.CategoryName = "PhysicalDisk";
                myCounter.CounterName = "Avg. Disk Queue Length";
                myCounter.InstanceName ="_Total";
                long raw5 = myCounter.RawValue;

                /*Throws "Instance '_Total' does not exist in the specified Category."??

                myCounter.CategoryName = "Network Interface";
                myCounter.CounterName = "Bytes Total/sec";
                myCounter.InstanceName = "_Total";
                long raw6 = myCounter.RawValue;     
                */
                 
                Console.WriteLine("Raw proccesser value: {0} \n" +
                                  "Privldged Time: {1} \n" +
                                  "Interrupt Time: {2} \n" +
                                  "Queue Length: {3} \n" +
                                  "Availiable Memory: {4}MB \n" +
                                  "Avg. Disk Queue Length: {5} \n",
                                  raw, raw1, raw2, raw3, raw4, raw5);


                Thread.Sleep(1000);
                
            }
            Console.ReadLine();        
        }
    }
}


"@ -ReferencedAssemblies 'System.Windows.Forms.dll'

[GetInfo.Program]::main(@())