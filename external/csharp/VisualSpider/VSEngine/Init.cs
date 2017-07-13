using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using VSEngine.Data;
using VSEngine.Integration;

namespace VSEngine
{
    /// <summary>
    /// The initil setup and leg work to run the VSEngine
    /// </summary>
    public class Init
    {        
        public void LoadConfigs(Config cfg) { }
        public void CreateDB(DBAccess db) { db.CreateDB(); }
        public void FirstTimeURLStore(Config cfg, DBAccess db)
        {
            // this is only done before had for the first url
            NavUnit firstNav = new NavUnit(cfg.StartURL);
            db.StoreNavUnit(firstNav);

            NavThread thread = new NavThread(firstNav);
            Thread navThread = new Thread(thread.Navigate);
            navThread.Start();
            while(navThread.IsAlive)
            {
                Thread.Sleep(1000);
            }

            db.StoreResolvedNavUnit(thread.UnitToPassBack);

            // temp code
            List<NavUnit> temp = db.RetriveUnitSet(4);

            return;
        }
    }
}
