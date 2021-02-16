using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Wait
{
    class Test
    {
        private const int intervalInMills = 20;
        static string[] numbers = {"One", "Two", "Three", "Four", "Five"};

        public static int number = 0;

        static void Main()
        {
            var t = new Thread(changeNumberPeriodically);
            t.Start();

            //Testing of Wait.Until()
            Func<bool> predicate1 = () =>
            {
                logTickAndNumber();
                return number >= 4;
            };
            startTick = Environment.TickCount;
            Wait.Until(predicate1);
            Console.WriteLine("\r\nAfter Wait.Until(predicate1), number={0}, {1} larger than 4\r\n",
                number, number >= 4 ? "" : "not");

            //Testing of Wait.Until() when timeout happens
            Func<bool> predicate2 = () =>
            {
                logTickAndNumber();
                return number >= 10;
            };
            startTick = Environment.TickCount;
            try
            {
                Wait.Until(predicate2, 5000);
            }
            catch (TimeoutException timeout)
            {
                Console.WriteLine("\r\nAfter Wait.Until(predicate2, 5000), number={0}, {1} larger than 10.\r\n"
                    , number, number >= 10 ? "" : "not");
            }

            //Testing of Wait.UntilString()
            Func<string> getNumberString = () =>
            {
                string result = numbers[number - 1];
                logTickAndNumber();
                return result;
            };
            startTick = Environment.TickCount;
            string fromUntilString = Wait.UntilString(getNumberString, "Five");
            Console.WriteLine("\r\nAfter Wait.UntilString(getNumberString, \"Five\"), number={0}, numberString={1}.\r\n"
                , number, fromUntilString);

            //Testing of Wait.UntilContains()
            number = 1;
            startTick = Environment.TickCount;
            fromUntilString = Wait.UntilContains(getNumberString, "F"); //"Four" or "Five"
            Console.WriteLine("\r\nAfter Wait.UntilContains(getNumberString, \"F\"), number={0}, numberString={1}.\r\n"
                , number, fromUntilString);

            //Testing of GenericWait.Until()
            Func<int> getNumber = () =>
            {
                logTickAndNumber();
                return number;
            };

            number = 1;
            startTick = Environment.TickCount;
            GenericWait<int>.Until(getNumber, i => i >= 3);
            Console.WriteLine("\r\nAfter GenericWait<int>.Until(getNumber, i => i >= 3), number={0}.\r\n"
                , number);

            //Testing of GenericWait.Until() when timeout is sure to happen
            number = 1;
            startTick = Environment.TickCount;
            try
            {
                GenericWait<int>.Until(getNumber, i => i < 0);
            }
            catch (TimeoutException timeout)
            {
                Console.WriteLine("\r\nAfter GenericWait<int>.Until(getNumber, i => i < 0), number={0}.\r\n"
                    , number);
            }

            //Set done to quit the thread of t
            done = true;
            Console.ReadKey();
        }

        private static int startTick = Environment.TickCount;
        static void logTickAndNumber()
        {
            Console.WriteLine("After {0}ms: number={1}", Environment.TickCount - startTick, number);
        }

        public static bool done = false;
        static void changeNumberPeriodically()
        {
            Random rdm = new Random();
            do
            {
                Thread.Sleep(intervalInMills);
                number = rdm.Next(1, 6);
            } while (!done);
        }
    }
}
