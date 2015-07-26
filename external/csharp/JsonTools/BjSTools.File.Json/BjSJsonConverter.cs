using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;
using System.Collections;
using System.IO;
using System.Drawing;

namespace BjSTools.File
{
    public static class BjSJsonConverter
    {
        private class IncompatibleValue { }

        #region ToJson

        /// <summary>
        /// Converts the passed object into a BjSJsonObject
        /// </summary>
        public static BjSJsonObject ToJson<T>(T obj) where T : class, new()
        {
            return ToJsonObject(typeof(T), obj);
        }

        private static BjSJsonObject ToJsonObject(Type t, object obj)
        {
            BjSJsonObject result = new BjSJsonObject();

            PropertyInfo[] properties = t.GetProperties();
            foreach (PropertyInfo pi in properties)
            {
                if (pi.CanRead && pi.CanWrite)
                {
                    object val = pi.GetValue(obj, null);
                    object jVal = ToJsonValue(val);
                    if (!(jVal is IncompatibleValue))
                        result.Add(pi.Name, jVal);
                }
            }

            return result;
        }

        private static BjSJsonArray ToJsonArray(IEnumerable array)
        {
            BjSJsonArray result = new BjSJsonArray();

            foreach (object obj in array)
            {
                result.Add(ToJsonValue(obj));
            }

            return result;
        }

        private static BjSJsonArray ToJsonObject(IDictionary dict)
        {
            BjSJsonArray result = new BjSJsonArray();

            IDictionaryEnumerator enu = dict.GetEnumerator();
            while (enu.MoveNext())
            {
                result.Add(new BjSJsonArray(ToJsonValue(enu.Key), ToJsonValue(enu.Value)));
            }

            return result;
        }

        private static string ToBase64String(Image img)
        {
            string result;
            using (MemoryStream ms = new MemoryStream())
            {
                img.Save(ms, System.Drawing.Imaging.ImageFormat.Tiff);
                result = Convert.ToBase64String(ms.ToArray());
            }
            return result;
        }

        private static object ToJsonValue(object value)
        {
            if (value == null)
                return null;

            Type t = value.GetType();

            if (value is string)
                return (string)value;
            else if (value is int)
                return Convert.ToDecimal((int)value);
            else if (value is uint)
                return Convert.ToDecimal((uint)value);
            else if (value is byte)
                return Convert.ToDecimal((byte)value);
            else if (value is sbyte)
                return Convert.ToDecimal((sbyte)value);
            else if (value is short)
                return Convert.ToDecimal((short)value);
            else if (value is ushort)
                return Convert.ToDecimal((ushort)value);
            else if (value is long)
                return Convert.ToDecimal((long)value);
            else if (value is ulong)
                return Convert.ToDecimal((ulong)value);
            else if (value is float)
                return Convert.ToDecimal((float)value);
            else if (value is double)
                return Convert.ToDecimal((double)value);
            else if (value is decimal)
                return (decimal)value;
            else if (value is bool)
                return (bool)value;
            else if (value is Guid)
                return value.ToString();
            else if (value is DateTime)
                return ((DateTime)value).ToString("yyyy-MM-ddTHH:mm:ss.fffffffzzz");
            else if (value is TimeSpan)
                return String.Format("{0}:{1}:{2}.{3}", ((TimeSpan)value).TotalHours, ((TimeSpan)value).Minutes, ((TimeSpan)value).Seconds, ((TimeSpan)value).Milliseconds);
            else if (value is Image || value is Bitmap)
                return ToBase64String(value as Image);
            else if (value is IDictionary)
                return ToJsonObject(value as IDictionary);
            else if (t.IsArray || value is IList)
                return ToJsonArray(value as IEnumerable);
            else
            {
                if (t.IsClass && t.GetConstructor(new Type[0]) != null)
                    return ToJsonObject(t, value);
                else
                    return new IncompatibleValue();
            }
        }

        #endregion

        #region FromJson

        /// <summary>
        /// Tries to map a BjSJsonObject's content into an instance of the specified type T
        /// </summary>
        public static T FromJson<T>(BjSJsonObject obj) where T : class, new()
        {
            return (T)FromJsonObject(typeof(T), obj);
        }

        private static object FromJsonObject(Type t, BjSJsonObject obj)
        {
            object result = Activator.CreateInstance(t);

            PropertyInfo[] properties = t.GetProperties().Where(pi => pi.CanRead && pi.CanWrite).ToArray();
            foreach (BjSJsonObjectMember member in obj)
            {
                PropertyInfo p = properties.FirstOrDefault(pi => pi.Name.Equals(member.Name));
                if (p == null || !p.CanRead || !p.CanWrite) continue;
                object value = FromJsonValue(member.Value, p.PropertyType);
                if (value == null)
                {
                    p.SetValue(result, value, null);
                    continue;
                }
                if (value is IncompatibleValue) continue;
                p.SetValue(result, value, null);
            }

            return result;
        }

        private static Array FromJsonArrayToArray(Type elementType, BjSJsonArray array)
        {
            Array result = Array.CreateInstance(elementType, array.Count);

            for (int i = 0; i < result.Length; i++)
                result.SetValue(FromJsonValue(array[i], elementType), i);

            return result;
        }

        private static IList FromJsonArrayToList(Type elementType, BjSJsonArray array)
        {
            IList result = Activator.CreateInstance(typeof(List<>).MakeGenericType(elementType)) as IList;

            foreach (object o in array)
                result.Add(FromJsonValue(o, elementType));

            return result;
        }

        private static IDictionary FromJsonArrayToDictionary(Type[] dictTypes, BjSJsonArray array)
        {
            IDictionary result = Activator.CreateInstance(typeof(Dictionary<,>).MakeGenericType(dictTypes[0], dictTypes[1])) as IDictionary;

            BjSJsonArray kvp;
            foreach (object o in array)
            {
                if (!(o is BjSJsonArray) || (o as BjSJsonArray).Count < 2) continue;
                kvp = o as BjSJsonArray;
                if (!JsonTypeEquals(dictTypes[0], kvp[0].GetType())) continue;
                result.Add(FromJsonValue(kvp[0], dictTypes[0]), FromJsonValue(kvp[1], dictTypes[1]));
            }

            return result;
        }

        private static bool JsonTypeEquals(Type realType, Type jsonType)
        {
            if (realType == jsonType) // string, bool, decimal
                return true;
            else if (realType == typeof(int) || realType == typeof(uint) || realType == typeof(byte) || realType == typeof(sbyte) ||
                realType == typeof(short) || realType == typeof(ushort) || realType == typeof(long) || realType == typeof(ulong) ||
                realType == typeof(float) || realType == typeof(double) || realType == typeof(decimal))
                return jsonType == typeof(decimal);
            else if (realType == typeof(Guid) || realType == typeof(Image) || realType == typeof(Bitmap))
                return jsonType == typeof(string);
            else if (realType == typeof(DateTime) || realType == typeof(TimeSpan))
                return jsonType == typeof(string) || jsonType == typeof(decimal);
            else if (realType.IsArray || realType.GetInterfaces().Contains(typeof(IList)) || realType.GetInterfaces().Contains(typeof(IDictionary)))
                return jsonType == typeof(BjSJsonArray);
            else if (realType.IsClass && realType.GetConstructor(new Type[0]) != null)
                return jsonType == typeof(BjSJsonObject);
            else
                return false;
        }

        private static object FromJsonValue(object value, Type targetType)
        {
            if (value == null)
                return null;
            else if (targetType == typeof(string))
                return value.ToString();
            else if (targetType == typeof(bool))
                return value.Equals(true);
            else if (targetType == typeof(int) && value is decimal)
                return Convert.ToInt32(value);
            else if (targetType == typeof(uint) && value is decimal)
                return Convert.ToUInt32(value);
            else if (targetType == typeof(byte) && value is decimal)
                return Convert.ToByte(value);
            else if (targetType == typeof(sbyte) && value is decimal)
                return Convert.ToSByte(value);
            else if (targetType == typeof(short) && value is decimal)
                return Convert.ToInt16(value);
            else if (targetType == typeof(ushort) && value is decimal)
                return Convert.ToUInt16(value);
            else if (targetType == typeof(long) && value is decimal)
                return Convert.ToInt64(value);
            else if (targetType == typeof(ulong) && value is decimal)
                return Convert.ToUInt64(value);
            else if (targetType == typeof(float) && value is decimal)
                return Convert.ToSingle(value);
            else if (targetType == typeof(double) && value is decimal)
                return Convert.ToDouble(value);
            else if (targetType == typeof(decimal) && value is decimal)
                return value;
            else if (targetType == typeof(Guid) && value is string)
                return new Guid((string)value);
            else if (targetType == typeof(DateTime) && value is string)
                return DateTime.Parse((string)value);
            else if (targetType == typeof(DateTime) && value is decimal)
                return new DateTime(Convert.ToInt64((decimal)value));
            else if (targetType == typeof(TimeSpan) && value is string)
                return TimeSpan.Parse((string)value);
            else if (targetType == typeof(TimeSpan) && value is decimal)
                return new TimeSpan(Convert.ToInt64((decimal)value));
            else if ((targetType == typeof(Image) || targetType == typeof(Bitmap)) && value is string)
                return new Bitmap(new MemoryStream(Convert.FromBase64String((string)value)));
            else if (targetType.IsArray && value is BjSJsonArray)
                return FromJsonArrayToArray(targetType.GetElementType(), value as BjSJsonArray);
            else if (targetType.GetInterfaces().Contains(typeof(IList)) && value is BjSJsonArray)
                return FromJsonArrayToList(targetType.GetGenericArguments()[0], value as BjSJsonArray);
            else if (targetType.GetInterfaces().Contains(typeof(IDictionary)) && value is BjSJsonArray)
                return FromJsonArrayToDictionary(targetType.GetGenericArguments(), value as BjSJsonArray);
            else if (targetType.IsClass && targetType.GetConstructor(new Type[0]) != null && value is BjSJsonObject)
                return FromJsonObject(targetType, value as BjSJsonObject);
            else
                return new IncompatibleValue();
        }

        #endregion
    }

}
