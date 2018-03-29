using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using VSEngine;

namespace VisualSpider {
	class Program {
		public static Engine GOGO;

		static void Main(string[] args) {
			Console.Title = "Visual Spider";
			GOGO = new Engine();

			Console.ReadKey();
		}
	}
}
