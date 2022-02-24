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
				var numberSamples = 10;
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
				var numberSamples = 10;
				var buffer = new CircularBuffer<Data>(numberSamples);
				var performanceCounter = new PerformanceCounter();
				performanceCounter.CategoryName = "System";
				performanceCounter.CounterName = "Processor Queue Length";
				performanceCounter.InstanceName = null;

				for (Int32 i = 0; i < numberSamples; i++) {

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
			int[] data = new int[] {0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,0,0,1,3,1,0,0,0,0,0,1,0,19,0,0,0,0,5,32,18,1,0,0,0,0,0,0,30,34,1,0,0,0,0,0,0,0,0,0,0,0,14,0,0 };

			try {
				var buffer = new CircularBuffer<Data>(60);
				for (Int32 i = 0; i < data.Length; i++) {
					var row = new Data();
					row.Value = data[i];
					row.TimeStamp = DateTime.Now;
					buffer.AddLast(row);
				}
				var rows = buffer.ToList();
				var values = (from row in rows
				              select row.Value);
				var result = values.Average();
				Console.Error.WriteLine("Average: " + result);
			} catch {
				Assert.Fail();
			}
		}

	}
}
