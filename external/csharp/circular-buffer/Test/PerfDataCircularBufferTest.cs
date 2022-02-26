using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Timers;

using NUnit.Framework;

using CircularBuffer;

namespace CircularBuffer.UnitTests {
	[TestFixture]
	public class PerfDataCircularBufferTest
	{
		[Test]
		public void AddLast() {
			try {
				const int numberSamples = 10;
				var buffer = new CircularBuffer<Int32>(numberSamples);
				var performanceCounter = new PerformanceCounter();
				performanceCounter.CategoryName = "System";
				performanceCounter.CounterName = "Processor Queue Length";
				performanceCounter.InstanceName = null;
				

				for (Int32 i = 0; i < numberSamples; i++) {
					buffer.AddLast((Int32)performanceCounter.RawValue);
					Thread.Sleep(1000);
				}
				Action<Int32> print = o => Console.WriteLine(o);
				Console.Error.WriteLine("Sample: "); 
				buffer.ToList().ForEach(print);
			} catch {
				Assert.Fail();
			}
		}
		[Test]
		public void AddDataLast() {
			try {
				const int numberSamples = 10;
				var buffer = new CircularBuffer<Data>(numberSamples);
				var performanceCounter = new PerformanceCounter();
				performanceCounter.CategoryName = "System";
				performanceCounter.CounterName = "Processor Queue Length";
				performanceCounter.InstanceName = null;

				for (int i = 0; i < numberSamples; i++) {

					var value = (Int32)performanceCounter.RawValue;
					var row = new Data();
					row.TimeStamp = DateTime.Now;
					row.Value = value;
					buffer.AddLast(row);
					Thread.Sleep(1000);
				}
				Action<Data> print = o => Console.WriteLine(o.ToString());
				Console.Error.WriteLine("Sample: "); 
				buffer.ToList().ForEach(print);
			} catch {
				Assert.Fail();
			}
		}
		
		[Test]
		public void AverageData() {
			var values = new int[] {0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,0,0,1,3,1,0,0,0,0,0,1,0,19,0,0,0,0,5,32,18,1,0,0,0,0,0,0,30,34,1,0,0,0,0,0,0,0,0,0,0,0,14,0,0 };

			try {
				var buffer = new CircularBuffer<Data>(60);
				for (Int32 i = 0; i < values.Length; i++) {
					var row = new Data();
					row.Value = values[i];
					row.TimeStamp = DateTime.Now;
					buffer.AddLast(row);
				}
				var rows = buffer.ToList();
				var results = (from row in rows
				              select row.Value);
				var result = results.Average();
				Console.Error.WriteLine("Average: " + result);
			} catch {
				Assert.Fail();
			}
		}

		[Test]
		public void AverageFilterData() {
			var values = new int[] {0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,0,0,1,3,1,0,0,0,0,0,1,0,19,0,0,0,0,5,32,18,1,0,0,0,0,0,0,30,34,1,0,0,0,0,0,0,0,0,0,0,0,14,0,0 };
			
			try {
				var buffer = new CircularBuffer<Data>(values.Length);
				var now = DateTime.Now;
				for (int i = 0; i < values.Length; i++) {
					var row = new Data();
					row.Value = values[i];
					row.TimeStamp = now.AddSeconds(i * 5);
					buffer.AddLast(row);
				}
				const float interval = 1F ;
				var rows = buffer.ToList();
				var results = (from row in rows
				               where ((row.TimeStamp - now).TotalMinutes) <= interval
				              select row.Value);
				var result = results.Average();
				Console.Error.WriteLine(String.Format("Average over {0, 2:f0} minute: {1, 4:f2}" , interval, result));
			} catch (Exception e){
				Console.Error.WriteLine("Exception: " + e.ToString());
				Assert.Fail();
			}
		}

		[Test]
		public void AverageFilterListData() {
			var values = new int[] {0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,0,0,1,3,1,0,0,0,0,0,1,0,19,0,0,0,0,5,32,18,1,0,0,0,0,0,0,30,34,1,0,0,0,0,0,0,0,0,0,0,0,14,0,0 };
			var listValues = new List<int>();
			
			 Console.WriteLine("Adding " + values.Length + " elements");  

    
			for (int i = 0; i < values.Length; i++) {
				listValues.Add(values[i]); 		
			}
			Console.WriteLine("Adding 10 more elements");
			for (int i = 0; i < 10; i++) {
				listValues.Add(i); 		
			}
			 			 
			Console.Error.WriteLine("Number of elements: " +  
                       listValues.Count);
			
			try {
				var buffer = new CircularBuffer<Data>(listValues.Count);
				var now = DateTime.Now;
				for (int i = 0; i < listValues.Count; i++) {
					var row = new Data();
					row.Value = listValues.ElementAt(i);
					row.TimeStamp = now.AddSeconds(i * 5);
					buffer.AddLast(row);
				}
				const float interval = 1F ;
				var rows = buffer.ToList();
				var results = (from row in rows
				               where ((row.TimeStamp - now).TotalMinutes) <= interval
				              select row.Value);
				var result = results.Average();
				Console.Error.WriteLine(String.Format("Average over {0, 2:f0} minute: {1, 4:f2}" , interval, result));
			} catch (Exception e){
				Console.Error.WriteLine("Exception: " + e.ToString());
				Assert.Fail();
			}
		}

	}
}
