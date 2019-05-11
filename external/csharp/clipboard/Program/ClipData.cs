using System;
using System.Collections.Generic;
using System.Text;
using System.Collections.ObjectModel;

namespace Clipboard
{
    /// <summary>
    /// Holds clipboard data of a single data format.
    /// </summary>
    [Serializable]
    public class DataClip
    {
        private uint format;

        /// <summary>
        /// Get or Set the format code of the data 
        /// </summary>
        public uint Format
        {
            get { return format; }
            set { format = value; }
        }
        
        private string formatName;
        /// <summary>
        /// Get or Set the format name of the data 
        /// </summary>
        public string FormatName
        {
            get { return formatName; }
            set { formatName = value; }
        }
        private byte[] buffer;

        private int size;

        /// <summary>
        /// Get or Set the buffer data
        /// </summary>
        public byte[] Buffer
        {
            get { return buffer; }
            set { buffer = value; }
        }
        /// <summary>
        /// Get the data buffer lenght
        /// </summary>
        public UIntPtr Size
        {
            get
            {
                if (buffer != null)
                {
                    //Read the correct size from buffer, if it is not null
                    return new UIntPtr(Convert.ToUInt32(buffer.GetLength(0)));
                }
                else
                {
                    //else return the optional set size
                    return new UIntPtr(Convert.ToUInt32(size));
                }
            }
        }
        /// <summary>
        /// Init a Clip Data object, containing one clipboard data and its format
        /// </summary>
        /// <param name="format"></param>
        /// <param name="formatName"></param>
        /// <param name="buffer"></param>
        public DataClip(uint format, string formatName, byte[] buffer)
        {
            this.format = format;
            this.formatName = formatName;
            this.buffer = buffer;
            this.size = 0;
        }
/// <summary>
/// Init an empty Clip Data object, used for serialize object
/// </summary>
        public DataClip() { }
    }
    
    
}
