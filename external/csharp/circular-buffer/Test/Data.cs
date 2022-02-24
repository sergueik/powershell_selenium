using System;

class Data {
	public DateTime TimeStamp { get; set; }
	public Int32 Value { get; set; }
	public override string ToString() {
		var _date = TimeStamp.ToLongDateString();
		var _time = TimeStamp.ToLongTimeString();

		return string.Format("TimeStamp={0} {1}, Value={2}", _date, _time, Value);
	}
}