using System;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Generic;
using NUnit.Framework;

namespace UnitTests
{
	
	[TestFixture]
	public class GridTest
	{
		string payload = null;
		
		[TestFixtureSetUp]
		public void SetUp()
		{
			payload = @"
{
  ""value"": {
    ""ready"": true,
    ""message"": ""Selenium Grid ready."",
    ""nodes"": [
      {
        ""id"": ""c0cdd050-8012-49d2-a841-e63d188c4b61"",
        ""uri"": ""http://node1:5555"",
        ""maxSessions"": 1,
        ""osInfo"": {
          ""arch"": ""amd64"",
          ""name"": ""Windows 10"",
          ""version"": ""10.0""
        },
        ""heartbeatPeriod"": 60000,
        ""availability"": ""UP"",
        ""version"": ""4.0.0 (revision 3a21814679)"",
        ""slots"": [
          {
            ""lastStarted"": ""1970-01-01T00:00:00Z"",
            ""session"": null,
            ""id"": {
              ""hostId"": ""c0cdd050-8012-49d2-a841-e63d188c4b61"",
              ""id"": ""2ec59c0f-9d92-4426-8a4f-2c2edceb416d""
            },
            ""stereotype"": {
              ""browserName"": ""chrome"",
              ""platformName"": ""WIN10""
            }
          },
          {
            ""lastStarted"": ""1970-01-01T00:00:00Z"",
            ""session"": null,
            ""id"": {
              ""hostId"": ""c0cdd050-8012-49d2-a841-e63d188c4b61"",
              ""id"": ""77ed2893-d75d-433c-b37d-552fe306da9c""
            },
            ""stereotype"": {
              ""browserName"": ""firefox"",
              ""platformName"": ""WIN10""
            }
          }
        ]
      },
      {
        ""id"": ""38cf6aeb-9b2c-4656-972f-e0a217c87e8c"",
        ""uri"": ""http://node2:5554"",
        ""maxSessions"": 1,
        ""osInfo"": {
          ""arch"": ""amd64"",
          ""name"": ""Windows 10"",
          ""version"": ""10.0""
        },
        ""heartbeatPeriod"": 60000,
        ""availability"": ""UP"",
        ""version"": ""4.0.0 (revision 3a21814679)"",
        ""slots"": [
          {
            ""lastStarted"": ""1970-01-01T00:00:00Z"",
            ""session"": null,
            ""id"": {
              ""hostId"": ""38cf6aeb-9b2c-4656-972f-e0a217c87e8c"",
              ""id"": ""588ae115-bb08-4a58-a21f-f8b6bc11cc47""
            },
            ""stereotype"": {
              ""browserName"": ""firefox"",
              ""platformName"": ""WIN10""
            }
          },
          {
            ""lastStarted"": ""1970-01-01T00:00:00Z"",
            ""session"": null,
            ""id"": {
              ""hostId"": ""38cf6aeb-9b2c-4656-972f-e0a217c87e8c"",
              ""id"": ""aee68a44-e3d8-4aab-ac7d-6b23211b94d1""
            },
            ""stereotype"": {
              ""browserName"": ""chrome"",
              ""platformName"": ""WIN10""
            }
          }
        ]
      },
      {
        ""id"": ""5bba6684-0c39-40d8-82c6-6fa9678fc472"",
        ""uri"": ""http://node3:5552"",
        ""maxSessions"": 1,
        ""osInfo"": {
          ""arch"": ""amd64"",
          ""name"": ""Windows 10"",
          ""version"": ""10.0""
        },
        ""heartbeatPeriod"": 60000,
        ""availability"": ""DOWN"",
        ""version"": ""4.0.0 (revision 3a21814679)"",
        ""slots"": [
          {
            ""lastStarted"": ""1970-01-01T00:00:00Z"",
            ""session"": null,
            ""id"": {
              ""hostId"": ""5bba6684-0c39-40d8-82c6-6fa9678fc472"",
              ""id"": ""fe10eb71-a805-46a6-aa98-5ab0db2c365e""
            },
            ""stereotype"": {
              ""browserName"": ""chrome"",
              ""platformName"": ""WIN10""
            }
          },
          {
            ""lastStarted"": ""1970-01-01T00:00:00Z"",
            ""session"": null,
            ""id"": {
              ""hostId"": ""5bba6684-0c39-40d8-82c6-6fa9678fc472"",
              ""id"": ""b9136c4a-b094-4b3d-adaf-e6370b1d1534""
            },
            ""stereotype"": {
              ""browserName"": ""firefox"",
              ""platformName"": ""WIN10""
            }
          }
        ]
      },
      {
        ""id"": ""8a6258d8-d606-4391-b9f5-42dad1f38802"",
        ""uri"": ""http://node4:5551"",
        ""maxSessions"": 1,
        ""osInfo"": {
          ""arch"": ""amd64"",
          ""name"": ""Windows 10"",
          ""version"": ""10.0""
        },
        ""heartbeatPeriod"": 60000,
        ""availability"": ""UP"",
        ""version"": ""4.0.0 (revision 3a21814679)"",
        ""slots"": [
          {
            ""lastStarted"": ""1970-01-01T00:00:00Z"",
            ""session"": null,
            ""id"": {
              ""hostId"": ""8a6258d8-d606-4391-b9f5-42dad1f38802"",
              ""id"": ""ea010321-5b54-4afb-9a81-1175d38b7c3d""
            },
            ""stereotype"": {
              ""browserName"": ""chrome"",
              ""platformName"": ""WIN10""
            }
          },
          {
            ""lastStarted"": ""1970-01-01T00:00:00Z"",
            ""session"": null,
            ""id"": {
              ""hostId"": ""8a6258d8-d606-4391-b9f5-42dad1f38802"",
              ""id"": ""b186b433-38dd-49c5-9283-d2a934eb0eaa""
            },
            ""stereotype"": {
              ""browserName"": ""firefox"",
              ""platformName"": ""WIN10""
            }
          }
        ]
      },
      {
        ""id"": ""38d1296a-0fbe-4692-a0fb-17bed8e5558b"",
        ""uri"": ""http://node5:5553"",
        ""maxSessions"": 1,
        ""osInfo"": {
          ""arch"": ""amd64"",
          ""name"": ""Windows 10"",
          ""version"": ""10.0""
        },
        ""heartbeatPeriod"": 60000,
        ""availability"": ""DOWN"",
        ""version"": ""4.0.0 (revision 3a21814679)"",
        ""slots"": [
          {
            ""lastStarted"": ""1970-01-01T00:00:00Z"",
            ""session"": null,
            ""id"": {
              ""hostId"": ""38d1296a-0fbe-4692-a0fb-17bed8e5558b"",
              ""id"": ""448140eb-86bc-443b-8aee-6bbf549ed5c4""
            },
            ""stereotype"": {
              ""browserName"": ""chrome"",
              ""platformName"": ""WIN10""
            }
          },
          {
            ""lastStarted"": ""1970-01-01T00:00:00Z"",
            ""session"": null,
            ""id"": {
              ""hostId"": ""38d1296a-0fbe-4692-a0fb-17bed8e5558b"",
              ""id"": ""9f4a5c79-39c5-4631-845b-0817cb555966""
            },
            ""stereotype"": {
              ""browserName"": ""firefox"",
              ""platformName"": ""WIN10""
            }
          }
        ]
      }
    ]
  }
}
";

		}

		[Test]
		public void test1()
		{
			
			var root = (Dictionary<string,object>)fastJSON.JSON.Instance.Parse(payload);
				
			Assert.NotNull(root);
			Console.Error.WriteLine(root.ToString());
			
			Dictionary<string,object> value = (Dictionary<string,object>)root["value"];
			var keys = value.Keys.GetEnumerator();
			Assert.NotNull(keys);
			int cnt = 0;
			while (keys.MoveNext()) {
				var key = keys.Current;
				Assert.NotNull(key);
				Console.Error.WriteLine(String.Format("Key [{0}]: {1}", cnt, key));
			}			
			Assert.Contains("ready", value.Keys);
			Assert.IsInstanceOf(typeof(System.Boolean), value["ready"]);

			try {
				List<Dictionary<string,object>> data = (List<Dictionary<string,object>>)value["nodes"];
			} catch (System.InvalidCastException e) {
			}
			// non-generic type ArrayList cannot be used with type arguments
			ArrayList nodes = (ArrayList)value["nodes"];
			Assert.NotNull(nodes);
			Assert.AreEqual(5, nodes.Count);
			Dictionary<string,object> node = (Dictionary<string,object>)nodes[0];
			Assert.NotNull(node);
			keys = node.Keys.GetEnumerator();
			Assert.NotNull(keys);
			cnt = 0;
			while (keys.MoveNext()) {
				var key = keys.Current;
				Assert.NotNull(key);
				Console.Error.WriteLine(String.Format("Key [{0}]: {1}", cnt, key));
			}
			Assert.Contains("availability", node.Keys);
			Assert.AreEqual("UP", node["availability"]);
			Assert.IsTrue(new Regex("(UP|DOWN)", RegexOptions.IgnoreCase).IsMatch(node["availability"].ToString()));
		}

		[Test]
		public void test2()
		{			
			var root = (Dictionary<string,object>)fastJSON.JSON.Instance.Parse(payload);				
			Assert.NotNull(root);
			int total_nodes_count = 0;
			try {
				// NOTE: will require a lot of type casting:
				// Cannot apply indexing with [] to an expression of type 'object' (CS0021)
				total_nodes_count = ((ArrayList)((Dictionary<string,object>)root["value"])["nodes"]).Count;
				Assert.AreEqual(5, total_nodes_count);
			} catch (Exception e) {
				Assert.NotNull(e);
			}
			int total_nodes_up = 0;
			for (var cnt = 0; cnt != total_nodes_count;cnt ++ ) {
				Dictionary<string,object> node =  (Dictionary<string,object>)  ((ArrayList)((Dictionary<string,object>)root["value"])["nodes"])[cnt];
				Assert.NotNull(node);
				Console.Error.WriteLine(String.Format(@"node [{0}][""availability""]: {1}", cnt, node["availability"].ToString()));
				if (node["availability"].ToString().ToUpper().Equals("UP")) {
					total_nodes_up ++;
				}
			}
			Assert.AreEqual(3, total_nodes_up);
		}
	}
}
