using C;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CircularDemo
{
	class Program
	{
		static void Main(string[] args)
		{
			var list = new CircularBuffer<int>(5);
			var ilist = list as IList<int>;
			Console.WriteLine("Adding 10 items");
			for (var i = 0; i < 10; ++i)
				list.PushBack(i + 1);
			Console.Write("Enumerating "+ list.Count+" items:");
			foreach (var item in list)
				Console.Write(" " + item.ToString());
			Console.WriteLine();
			Console.WriteLine("Removing 1 item");
			list.PopFront();
			Console.Write("Enumerating " + list.Count + " items:");
			foreach (var item in list)
				Console.Write(" " + item.ToString());
			Console.WriteLine();

			for(var i =7;i >=0;--i) {
				if(0==i%2)
				{
					Console.WriteLine("Removing 1 item");
					ilist.RemoveAt(i);
				}
			}
			Console.Write("Enumerating " + list.Count + " items:");
			foreach (var item in list)
				Console.Write(" " + item.ToString());
			Console.WriteLine();
			Console.WriteLine("Removing 1 item");
			list.PopBack();
			Console.Write("Enumerating " + list.Count + " items:");
			foreach (var item in list)
				Console.Write(" " + item.ToString());
			Console.WriteLine();
			Console.WriteLine("Adding 1 item");
			list.PushBack(11);
			Console.Write("Enumerating " + list.Count + " items:");
			foreach (var item in list)
				Console.Write(" " + item.ToString());
			Console.WriteLine();
			Console.WriteLine("Inserting 2 items");
			list.PushFront(2);
			list.PushFront(1);
			Console.Write("Enumerating " + list.Count + " items:");
			foreach (var item in list)
				Console.Write(" " + item.ToString());
			Console.WriteLine();
			Console.WriteLine("Removing 1 item");
			list.PopFront();
			Console.Write("Enumerating " + list.Count + " items:");
			foreach (var item in list)
				Console.Write(" " + item.ToString());
			Console.WriteLine();

			Console.WriteLine("Inserting 1 item");
			ilist.Insert(2,4);
			
			Console.Write("Enumerating " + list.Count + " items:");
			foreach (var item in list)
				Console.Write(" " + item.ToString());
			Console.WriteLine();
			Console.WriteLine("Removing 4 items");
			list.PopFront();
			list.PopFront();
			list.PopFront();
			list.PopFront();
			Console.Write("Enumerating " + list.Count + " items:");
			foreach (var item in list)
				Console.Write(" " + item.ToString());
			Console.WriteLine();
			Console.WriteLine("Adding 4 items");
			list.PushBack(12);
			list.PushBack(13);
			list.PushBack(15);
			list.PushBack(16);
			Console.Write("Enumerating " + list.Count + " items:");
			foreach (var item in list)
				Console.Write(" " + item.ToString());
			Console.WriteLine();
			Console.WriteLine("Inserting 1 item");
			ilist.Insert(5,14);
			Console.Write("Enumerating " + list.Count + " items:");
			foreach (var item in list)
				Console.Write(" " + item.ToString());
			Console.WriteLine();
			Console.WriteLine("Inserting 1 item");
			list.PushFront(8);
			Console.Write("Enumerating " + list.Count + " items:");
			foreach (var item in list)
				Console.Write(" " + item.ToString());
			Console.WriteLine();
			Console.WriteLine("Capacity is " + list.Capacity);
			Console.WriteLine("Trimming");
			list.Trim();
			Console.WriteLine("Capacity is " + list.Capacity);
			Console.Write("Enumerating " + list.Count + " items:");
			foreach (var item in list)
				Console.Write(" " + item.ToString());
			Console.WriteLine();


		}
	}
}
