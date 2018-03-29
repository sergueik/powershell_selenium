using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using VSEngine.Data;
using VSEngine.Integration;

namespace VSEngine
{
    /// <summary>
    /// Cordiates threads and processes resutls
    /// </summary>
    public class NavLoop
    {
        bool WorkToDo = true;
        // check if there is work to do
        // queue up URls / Scripts to run
        // new up treads based on max thread count and work left
        // collect results from finishhed treads
        // sotre navigation results in db
        public void Loop(DBAccess db, Config cfg)
        {
            while(WorkToDo)
            {
                List<NavUnit> queuedUnits = db.RetriveUnitSet(cfg.MaxThreads);
                List<Thread> threads = new List<Thread>();
                List<NavThread> navThreads = new List<NavThread>();

                if(queuedUnits.Count < 1)
                {
                    WorkToDo = false;
                    break;
                }

                foreach(NavUnit currentUnit in queuedUnits)
                {
                    NavThread tempNavThread = new NavThread(currentUnit);
                    Thread tempThread = new Thread(tempNavThread.Navigate);
                    tempThread.Start();

                    threads.Add(tempThread);
                    navThreads.Add(tempNavThread);
                }

                bool threadIsAlive = true;

                while(threadIsAlive)
                {
                    threadIsAlive = false;

                    foreach(Thread currentThread in threads)
                    {
                        if (currentThread.IsAlive) threadIsAlive = true;
                    }
                }

                foreach(NavThread currentNavTh in navThreads)
                {
                    db.StoreResolvedNavUnit(currentNavTh.UnitToPassBack);
                }
            }
        }

    }
}
