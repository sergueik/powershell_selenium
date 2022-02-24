using System;
using System.Collections.Generic;
using System.Threading;
using CircularBuffer;
using NUnit.Framework;


namespace CircularBuffer.UnitTests
{
	[TestFixture]
	public class CircularBufferUnitTest
	{
		[Test]
		public void AddLast()
		{
			try {
				var buffer = new CircularBuffer<Int32>(5);
				for (Int32 i = 0; i < 10; i++) {
					buffer.AddLast(i);
				}
			} catch {
				Assert.Fail();
			}
		}

		[Test]
		// Throws "Array is Full"
		public void AddFirst()
		{
			try {
				var buffer = new CircularBuffer<Int32>(5);
				for (Int32 i = 0; i < 10; i++) {
					buffer.AddFirst(i);
				}
			} catch(Exception e) {
				Console.WriteLine(e.ToString());
				Assert.Fail();
			}
		}

		[Test]
		public void AddDynamicFirst()
		{
			try {
				var buffer = new CircularBuffer<Int32>(5);
				buffer.IsDynamic = true;
				for (Int32 i = 0; i < 10; i++) {
					buffer.AddFirst(i);
				}
			} catch(Exception e) {
				Console.WriteLine(e.ToString());
				Assert.Fail();
			}
		}
		
		[Test]
		public void Clear()
		{
			try {
				var buffer = new CircularBuffer<Int32>(10);
				for (Int32 i = 0; i < 10; i++) {
					buffer.AddFirst(i);
				}
				buffer.Reset();
         		Assert.IsNotNull(buffer);
				Assert.IsTrue(0 == buffer.Size);
				if (buffer.Size != 0) {
					Assert.Fail();
				}
			} catch {
				Assert.Fail();
			}
		}

		[Test]
		public void ToList()
		{
			try {
				var buffer = new CircularBuffer<Int32>(5);
				for (Int32 i = 0; i < 10; i++) {
					buffer.AddLast(i);
				}
				List<Int32> bufferToList = buffer.ToList();
				if (bufferToList.Count != 5) {
					Assert.Fail();
				}
			} catch {
				Assert.Fail();
			}
		}

		[Test]
		public void ToArray()
		{
			try {
				var buffer = new CircularBuffer<Int32>(5);
				for (Int32 i = 0; i < 10; i++) {
					buffer.AddLast(i);
				}
				Int32[] bufferToArray = buffer.ToArray();
				Assert.IsTrue(5 == bufferToArray.Length);
				if (bufferToArray.Length != 5) {
					Assert.Fail();
				}
			} catch {
				Assert.Fail();
			}
		}

		[Test]
		public void Index()
		{
			try {
				var buffer = new CircularBuffer<Int32>(5);
				for (Int32 i = 0; i < 10; i++) {
					buffer.AddLast(i);
				}
				Int32 item = buffer[2];
				if (item != buffer[2]) {
					Assert.Fail();
				}
			} catch {
				Assert.Fail();
			}
		}

		[Test]
		public void Enumerator()
		{
			try {
				var buffer = new CircularBuffer<Int32>(5);
				for (Int32 i = 0; i < 10; i++) {
					buffer.AddLast(i);
				}
				foreach (var item in buffer) {
					Console.WriteLine(item);
				}
			} catch {
				Assert.Fail();
			}
		}

		[Test]
		public void Dynamic()
		{
			try {
				var buffer = new CircularBuffer<Int32>(5);
				buffer.IsDynamic = true;
				buffer.IsInfinite = false;
				Int32 i;
				for ( i = 0; i != buffer.Capacity; i++) {
					Console.WriteLine("Adding: " + i );
					buffer.AddLast(i);
				}
				i = 42;
				Console.WriteLine("Adding one more element: " + i );
				buffer.AddLast(i);
				Console.WriteLine(String.Format("New Size: {0}", buffer.Size));
				Console.WriteLine(String.Format("New Capacity: {0}", buffer.Capacity));
				Assert.IsTrue(6 == buffer.Size);
				Assert.AreEqual(10, buffer.Capacity);
			} catch (Exception e) {
				Console.WriteLine(e.ToString());
				Assert.Fail();
			}
		}

        		
		public void Infinite()
		{
			try {
				var buffer = new CircularBuffer<Int32>(12);
				buffer.IsInfinite = true;
				for (Int32 i = 0; buffer.Size != buffer.Capacity; i++) {
					buffer.AddLast(i);
				}
				buffer.AddLast(12);
			} catch {
				Assert.Fail();
			}
		}
		private static Int32 GetRandomNumber()
		{
			return GetRandomNumber(0, 100);
		}

		private static Int32 GetRandomNumber(Int32 minValue, Int32 maxValue)
		{
			Thread.Sleep(100);
			var random = new Random();
			return random.Next(minValue, maxValue);
		}
	}
}