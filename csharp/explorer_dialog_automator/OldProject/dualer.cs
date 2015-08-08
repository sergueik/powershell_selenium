using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Diagnostics;
// using System.Drawing;
using System.IO;
// using System.Management;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
// using System.Windows.Forms;
using System.Xml;
using System.Xml.XPath;
namespace dualer
{
    public static class Program
    {
// http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.htmla
        public static String   BuildGETRequestString ( String host, String page) {

String REQUEST = @"
GET %PAGE% HTTP/1.1
Host: %HOST%
User-Agent: %USERAGENT%


";
        String UserAgent = @"User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.17) Gecko/20110422 Ubuntu/10.10 (maverick) Firefox/3.6.17";
        String result;
        Regex x1 = new Regex(@"%HOST%");
        result = x1.Replace(REQUEST, host );

        Regex x2 = new Regex(@"%PAGE%" );
        result = x2.Replace(result,page );
        Regex x3 = new Regex(@"%USERAGENT%" );
        result = x3.Replace(result, UserAgent );
        return result;
   }


        public static void Main(string[] args)
        {
            try
            {
                String host = args[0];
                String page = args[1];
                Int32 port = 80; 
                if (args.Length > 2){
                    port =    Convert.ToInt32(args[3]);
                }

                using (SocketClient sa = new SocketClient(host, port))
                {
                    sa.Connect();
                    String message = BuildGETRequestString (host, page);
                    Console.WriteLine("{0}\n",message);
                    sa.SendReceive(message);
                    Console.WriteLine("{0}\n",sa.Result());
                    sa.Disconnect();

                }
            }
            catch (IndexOutOfRangeException)
            {
                Console.WriteLine("Usage: dualer <host> <page> [<port>].");
            }
            catch (FormatException)
            {
                Console.WriteLine("Usage: dualer <host> <page> [<port>].");
            }
            catch (Exception ex)
            {
                Console.WriteLine("ERROR: " + ex.Message);
            }
        }
    }

    internal sealed class SocketClient : IDisposable
    {
        private const Int32 ReceiveOperation = 1, SendOperation = 0;
        private Int32 cnt = 0;
        private Socket clientSocket;
        private Boolean connected = false;
        private IPEndPoint hostEndPoint;
        private static AutoResetEvent autoConnectEvent = new AutoResetEvent(false); 
        private static AutoResetEvent[] autoSendReceiveEvents = new AutoResetEvent[]
        {
            new AutoResetEvent(false),
            new AutoResetEvent(false)
        };
        private StringBuilder buffer ;
        public String Result(){
               return buffer.ToString();
        }
        internal SocketClient(String hostName, Int32 port)
        {
            IPHostEntry host = 
            // Get host related information.
            Dns.GetHostEntry(hostName);

            // Addres of the host.
            IPAddress[] addressList = host.AddressList;

            // Instantiates the endpoint and socket.
            this.hostEndPoint = new IPEndPoint(addressList[addressList.Length - 1], port);
            this.clientSocket = new Socket(this.hostEndPoint.AddressFamily, SocketType.Stream, ProtocolType.Tcp);

        }

        internal void Connect()
        {
             SocketAsyncEventArgs connectArgs = null;
             try {
                 connectArgs        = new SocketAsyncEventArgs();
             }            catch (PlatformNotSupportedException  ex ) {
                Console.WriteLine("ERROR: " + ex.Message);
                throw ex;

             }            catch (System.NotSupportedException  ex ) {
                Console.WriteLine("ERROR: " + ex.Message);
                throw ex;

            }

            connectArgs.UserToken = this.clientSocket;
            connectArgs.RemoteEndPoint = this.hostEndPoint;
            connectArgs.Completed += new EventHandler<SocketAsyncEventArgs>(OnConnect);

            clientSocket.ConnectAsync(connectArgs);
            autoConnectEvent.WaitOne();

            SocketError errorCode = connectArgs.SocketError;
            if (errorCode != SocketError.Success)
            {
                throw new SocketException((Int32)errorCode);
            }
        }

        internal void Disconnect()
        {
            clientSocket.Disconnect(false);
        }

        private void OnConnect(object sender, SocketAsyncEventArgs e)
        {
            // Signals the end of connection.
            autoConnectEvent.Set();
            buffer = new StringBuilder();
            buffer.EnsureCapacity( 4096 );
            // Set the flag for socket connected.
            this.connected = (e.SocketError == SocketError.Success);
        }


        private void OnReceive(object sender, SocketAsyncEventArgs e)
        {
            // Signals the end of receive.
            cnt ++;
            // TODO - Timer event.
            if (cnt > 1300){
                   autoSendReceiveEvents[SendOperation].Set();
            } else {
                   buffer.Append(Encoding.ASCII.GetString(e.Buffer, e.Offset, e.BytesTransferred));
                   // continue receiving.
                    Socket s = e.UserToken as Socket;
                   // leak ?
                    s.ReceiveAsync(e);

            } 
        }

        private void OnSend(object sender, SocketAsyncEventArgs e)
        {
            // Signals the end of send.
            autoSendReceiveEvents[ReceiveOperation].Set();

            if (e.SocketError == SocketError.Success)
            {
                if (e.LastOperation == SocketAsyncOperation.Send)
                {
                    // Prepare receiving.
                    Socket s = e.UserToken as Socket;

                    byte[] receiveBuffer = new byte[512];
                    e.SetBuffer(receiveBuffer, 0, receiveBuffer.Length);
                    e.Completed += new EventHandler<SocketAsyncEventArgs>(OnReceive);
                    s.ReceiveAsync(e);
                }
            }
            else
            {
                this.ProcessError(e);
            }
        }

        private void ProcessError(SocketAsyncEventArgs e)
        {
            Socket s = e.UserToken as Socket;
            if (s.Connected)
            {
                // close the socket associated with the client
                try
                {
                    s.Shutdown(SocketShutdown.Both);
                }
                catch (Exception)
                {
                    // throws if client process has already closed
                }
                finally
                {
                    if (s.Connected)
                    {
                        s.Close();
                    }
                }
            }

            // Throw the SocketException
            throw new SocketException((Int32)e.SocketError);
        }

        internal String SendReceive(String message)
        {
            if (this.connected)
            {
                // Create a buffer to send.
                Byte[] sendBuffer = Encoding.ASCII.GetBytes(message);

                // Prepare arguments for send/receive operation.
                SocketAsyncEventArgs completeArgs = new SocketAsyncEventArgs();
                completeArgs.SetBuffer(sendBuffer, 0, sendBuffer.Length);
                completeArgs.UserToken = this.clientSocket;
                completeArgs.RemoteEndPoint = this.hostEndPoint;
                completeArgs.Completed += new EventHandler<SocketAsyncEventArgs>(OnSend);

                // Start sending asyncronally.
                clientSocket.SendAsync(completeArgs);

                // Wait for the send/receive completed.
                AutoResetEvent.WaitAll(autoSendReceiveEvents);

                // Return data from SocketAsyncEventArgs buffer.
                return Encoding.ASCII.GetString(completeArgs.Buffer, completeArgs.Offset, completeArgs.BytesTransferred);
            }
            else
            {
                throw new SocketException((Int32)SocketError.NotConnected);
            }
        }

        #region IDisposable Members

        public void Dispose()
        {
            autoConnectEvent.Close();
            autoSendReceiveEvents[SendOperation].Close();
            autoSendReceiveEvents[ReceiveOperation].Close();
            if (this.clientSocket.Connected)
            {
                this.clientSocket.Close();
            }
        }

        #endregion
    }
}

