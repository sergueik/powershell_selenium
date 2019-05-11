using System;
using System.Collections.Generic;
using System.Text;
using System.Collections.ObjectModel;
using System.Runtime.InteropServices;
using System.IO;
using System.Xml.Serialization;
using System.Xml;

namespace Clipboard
{
    /// <summary>
    /// Manage the Clipboard backup
    /// </summary>
    
    public class ClipboardHelper
    {
        /// <summary>
        /// Remove all data from Clipboard
        /// </summary>
        /// <returns></returns>
        public static bool EmptyClipboard()
        {
            return Win32ClipboardAPI.EmptyClipboard();
        }

        /// <summary>
        /// Empty the Clipboard and Restore to system clipboard data contained in a collection of ClipData objects
        /// </summary>
        /// <param name="clipData">The collection of ClipData containing data stored from clipboard</param>
        /// <returns></returns>    
        public static bool SetClipboard(ReadOnlyCollection<DataClip> clipData)
        {
            //Open clipboard to allow its manipultaion
            if (!Win32ClipboardAPI.OpenClipboard(IntPtr.Zero))
                return false;
            
            //Clear the clipboard
            EmptyClipboard();
                        
            //Get an Enumerator to iterate into each ClipData contained into the collection
            IEnumerator<DataClip> cData = clipData.GetEnumerator();
            while( cData.MoveNext())
            {
                DataClip cd = cData.Current;

                //Get the pointer for inserting the buffer data into the clipboard
                IntPtr alloc = Win32MemoryAPI.GlobalAlloc(Win32MemoryAPI.GMEM_MOVEABLE | Win32MemoryAPI.GMEM_DDESHARE, cd.Size);
                IntPtr gLock = Win32MemoryAPI.GlobalLock(alloc);

                //Clopy the buffer of the ClipData into the clipboard
                if ((int)cd.Size>0)
                {
                    Marshal.Copy(cd.Buffer, 0, gLock, cd.Buffer.GetLength(0));
                }
                else
                {
                }
                //Release pointers 
                Win32MemoryAPI.GlobalUnlock(alloc);
                Win32ClipboardAPI.SetClipboardData(cd.Format, alloc);
            };
            //Close the clipboard to realese unused resources
            Win32ClipboardAPI.CloseClipboard();
            return true;
        }

        /// <summary>
        /// Save a collection of ClipData to HardDisk
        /// </summary>
        /// <param name="clipData">The collection of ClipData to save</param>
        /// <param name="fileName">The name of the file</param>
        public static void SaveToFile(ReadOnlyCollection<DataClip> clipData, string clipName)
        {
            //Get the enumeration of the clipboard data
            IEnumerator<DataClip> cData = clipData.GetEnumerator();
            //Init a counter
            int i = 0;
            //Delete the folder, if already exists
            if (Directory.Exists(clipName))
            {
                Directory.Delete(clipName,true);
            }
            //Open the directory on which save the files
            DirectoryInfo di= Directory.CreateDirectory(clipName);
            
            while (cData.MoveNext())
            {
                //Init the serializer
                XmlSerializer xml = new XmlSerializer(typeof(DataClip));
                // To write to a file, create a StreamWriter object.
                using (StreamWriter sw = new StreamWriter(di.FullName + @"\" + i.ToString() + ".cli",false))
                {
                    //Serialize the clipboard data
                    xml.Serialize(sw, cData.Current);
                }
                
                i++;
            }

            

         }
/// <summary>
/// Open the file and deserialize the collection of DataClips
/// </summary>
/// <param name="fileName">The path of the file to open</param>
/// <returns></returns>
        private static ReadOnlyCollection<DataClip> ReadFromFile(string clipName)
        {
            //Init the List to return as result
            List<DataClip> clips = new List<DataClip>();
            //Check if the clip exists on hd
            if (Directory.Exists(clipName))
            {
                DirectoryInfo di = new DirectoryInfo(clipName);

                //Loop for each clipboard data
                for (int x = 0; x < di.GetFiles().GetLength(0); x++)
                {
                    //Init the serializer
                    XmlSerializer xml = new XmlSerializer(typeof(DataClip));
                    //Set the file to read
                    FileInfo fi = new FileInfo(di.FullName + "\\" + x.ToString() + ".cli");
                    //Init the stream to deserialize
                    using (FileStream fs = fi.Open(FileMode.Open))
                    {
                        //deserialize and add to the List
                        clips.Add((DataClip)xml.Deserialize(fs));
                    }
                }
            }
            return new ReadOnlyCollection<DataClip>( clips);    
        }
            

        /// <summary>
        /// Get data from clipboard and save it to Hard Disk
        /// </summary>
        /// <param name="fileName">The name of the file</param>
        public static void Serialize(string clipName)
        {
            //Get data from clipboard
            ReadOnlyCollection<DataClip> clipData = GetClipboard();
            //Save data to hard disk
            SaveToFile(clipData, clipName);
        }

        /// <summary>
        /// Get data from hard disk and put them into the clipboard
        /// </summary>
        /// <param name="fileName"></param>
        /// <returns></returns>
        public static bool Deserialize(string clipName)
        {
            //Get data from hard disk
            ReadOnlyCollection<DataClip> clipData = ReadFromFile(clipName);
            //Set red data into clipboard
            return SetClipboard(clipData);
        }
        /// <summary>
        /// Convert to a DataClip collection all data present in the clipboard
        /// </summary>
        /// <returns></returns>
        public static ReadOnlyCollection<DataClip> GetClipboard()
        {
            //Init a list of ClipData, which will contain each Clipboard Data
            List<DataClip> clipData = new List<DataClip>();

            //Open Clipboard to allow us to read from it
            if (!Win32ClipboardAPI.OpenClipboard(IntPtr.Zero))
                return new ReadOnlyCollection<DataClip>(clipData);

            //Loop for each clipboard data type
            uint format = 0;
            while ((format = Win32ClipboardAPI.EnumClipboardFormats(format)) != 0)
            {
                //Check if clipboard data type is recognized, and get its name
                string formatName = "0";
                DataClip cd;
                if (format > 14)
                {
                    StringBuilder res = new StringBuilder();
                    if (Win32ClipboardAPI.GetClipboardFormatName(format, res, 100) > 0)
                    {
                        formatName = res.ToString();
                    }

                }
                    //Get the pointer for the current Clipboard Data 
                    IntPtr pos = Win32ClipboardAPI.GetClipboardData(format);
                    //Goto next if it's unreachable
                    if (pos == IntPtr.Zero)
                        continue;
                    //Get the clipboard buffer data properties
                    UIntPtr lenght = Win32MemoryAPI.GlobalSize(pos);
                    IntPtr gLock = Win32MemoryAPI.GlobalLock(pos);
                    byte[] buffer;
                    if ((int)lenght > 0)
                    {
                        //Init a buffer which will contain the clipboard data
                        buffer = new byte[(int)lenght];
                        int l = Convert.ToInt32(lenght.ToString());
                        //Copy data from clipboard to our byte[] buffer
                        Marshal.Copy(gLock, buffer, 0, l);
                    }
                    else
                    {
                        buffer = new byte[0];
                    }
                    //Create a ClipData object that represtens current clipboard data
                    cd = new DataClip(format, formatName, buffer);
                    cd.FormatName = formatName;
                    //Add current Clipboard Data to the list
                    
                
                clipData.Add(cd);
            }
            //Close the clipboard and realese unused resources
            Win32ClipboardAPI.CloseClipboard();
            //Returns the list of Clipboard Datas as a ReadOnlyCollection of ClipData
            return new ReadOnlyCollection<DataClip>(clipData);
        }

    }
    

}
