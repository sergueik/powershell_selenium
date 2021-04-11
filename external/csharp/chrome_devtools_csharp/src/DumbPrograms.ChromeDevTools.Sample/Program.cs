using System;
using System.Linq;
using System.Threading.Tasks;

namespace DumbPrograms.ChromeDevTools.Sample
{
    class Program
    {
        // NOTE: needs to run as Administrator
        static async Task Main(string[] args)
        {
            using (var chrome = ChromeProcessHelper.StartNew())
            {
                var devTools = await chrome.GetDevTools();

                var targets = from t in await devTools.GetInspectableTargets()
                              where t.Type == "page"
                              select t;

                var t0 = targets.First();

                using (var inspector = await devTools.Inspect(t0))
                {
                    await inspector.Page.Enable();

                    await inspector.Page.Navigate("https://www.baidu.com");

                    var e = await inspector.Page.LoadEventFiredEvent();

                    Console.WriteLine($"Page loaded at {e.Timestamp.Value}");
                }

                var t1 = await devTools.NewTab("https://www.cnblogs.com");

                using (var inspector = await devTools.Inspect(t1))
                {
                    await inspector.Page.Enable();

                    var i = 0;
                    await inspector.Page.LoadEventFiredEvent(async _ =>
                    {
                        var doc = await inspector.DOM.GetDocument();
                        var title = await inspector.DOM.QuerySelector(doc.Root.NodeId, "title");
                        var html = await inspector.DOM.GetOuterHTML(title.NodeId);
                        Console.WriteLine(html.OuterHTML);

                        return true;
                    });

                    Console.WriteLine(i);
                }


                await devTools.CloseTab(t0.Id);
            }
        }
    }
}
