using System;
using System.Collections;
using System.Collections.Generic;

public class CircularBuffer<T> : IEnumerator<T> {
	internal T[] _array;
	internal Int32 _start;
	internal Int32 _end;
	private Int32 _size;
	private Boolean _isDynamic;
	private Boolean _isInfinite;
	private Int32 _currentPosition = -1;
	private Int32 _numOfElementsProcessed = 0;
	public CircularBuffer() : this(0, true, false) { }

	public CircularBuffer(Int32 size) : this(size, true, false) {
	}

	public CircularBuffer(Int32 size, Boolean isInfinite, Boolean isDynamic) {
		_array = new T[size];
		_start = 0;
		_end = 0;
		_size = 0;
		_isDynamic = isDynamic;
		_isInfinite = isInfinite;
	}

	public void AddFirst(T data) {
		if (!IsFull || !_isInfinite) {
			if (_size != 0) {
				_start = GetPreviousPosition(_start);
				if (_start == _end) {
					_end = GetNextPosition(_end);
				} else {
					_size++;
				}
			} else {
				_start = 0;
				_size++;
			}
			_array[_start] = data;
		} else if (_isDynamic) {
			Extend();
			AddFirst(data);
		} else {
			throw new Exception("Array is Full");
		}
	}

	public void AddLast(T data) {
		if (!IsFull || _isInfinite) {
			if (_size != 0) {
				_end = GetNextPosition(_end);
				if (_start == _end) {
					_start = GetNextPosition(_start);
				} else {
					_size++;
				}
			} else {
				_end = 0;
				_size++;
			}
			_array[_end] = data;
		} else if (_isDynamic) {
			Extend();
			AddLast(data);
		} else {
			throw new Exception("Array is Full");
		}
	}

	public void RemoveFirst() {
		if (!IsEmpty) {
			_start = GetNextPosition(_start);
			_size--;
		} else {
			throw new Exception("Array is Empty");
		}
	}

	public void RemoveLast() {
		if (!IsEmpty) {
			_end = GetPreviousPosition(_end);
			_size--;
		} else {
			throw new Exception("Array is Empty");
		}
	}

	private void Extend() {
		// The name 'Console' does not exist in the current context (CS0103)
		// Console.WriteLine("Extening to Capacity: " + Capacity * 2 );
		Extend(Capacity * 2);
	}

	private void Extend(Int32 capacity) {
		T[] extendedArray = new T[capacity];
		if (capacity < Capacity) {
			Int32 end = 0;
			Int32 size = 0;
			for (Int32 i = 0; i < extendedArray.Length && i < _array.Length; i++, end = GetNextPosition(end), size++) {
				extendedArray[i] = _array[end];
			}
			_start = 0;
			_end = --end;
			_size = size;

		} else {
			_array.CopyTo(extendedArray, 0);
		}
		_array = extendedArray;
	}

	private Int32 GetNextPosition(Int32 pos) {

		if (pos == Capacity - 1) {
			return 0;
		} else {
			return pos + 1;
		}
	}

	private Int32 GetPreviousPosition(Int32 pos) {
		if (pos == 0) {
			return Capacity - 1;
		} else {
			return pos - 1;
		}
	}

	void IDisposable.Dispose() {
		_currentPosition = -1;
		_numOfElementsProcessed = 0;
	}

	public bool MoveNext() {
		if (_currentPosition == -1) {
			_currentPosition = _start;
			_numOfElementsProcessed++;
		} else {
			_currentPosition = GetNextPosition(_currentPosition);
			_numOfElementsProcessed++;
		}
		return (_numOfElementsProcessed <= Size);
	}

	public void Reset() {
		_start = 0;
		_end = 0;
		_size = 0;
	}

	public IEnumerator<T> GetEnumerator() {
		return this;
	}

	public T this[Int32 index] {
		get {
			if (index >= 0 && index < _size) {
				Int32 iBuffer = _start;
				for (Int32 incremented = 0; incremented < index; incremented++) {
					iBuffer = GetNextPosition(iBuffer);
				}
				return _array[iBuffer];
			} else {
				throw new Exception("Invalid Index");
			}
		}
		set {
			if (index >= 0 && index <= _size) {
				Int32 iBuffer = _start;
				for (Int32 incremented = 0; incremented < index; incremented++) {
					iBuffer++;
				}
				_array[iBuffer] = value;
			} else {
				throw new Exception("Invalid Index");
			}
		}
	}

	public T[] ToArray() {
		Int32 numOfElementsProcessed = 0;
		T[] array = new T[_size];
		Int32 iOutputArray = 0;
		for (Int32 iBuffer = _start; numOfElementsProcessed < _size; iBuffer = GetNextPosition(iBuffer), numOfElementsProcessed++, iOutputArray++) {
			array[iOutputArray] = _array[iBuffer];
		}
		return array;
	}

	public List<T> ToList() {
		Int32 numOfElementsProcessed = 0;
		var list = new List<T>();
		for (Int32 iBuffer = _start; numOfElementsProcessed < _size; iBuffer = GetNextPosition(iBuffer), numOfElementsProcessed++) {
			list.Add(_array[iBuffer]);
		}
		return list;
	}

	protected Int32 Start {
		set {
			if (value >= 0 && value < _array.Length) {
				_start = value;
			} else {
				throw new Exception("Inappropriate Index");
			}
		}
		get {
			return _start;
		}
	}

	protected Int32 End {
		set {
			if (value >= 0 && value < _array.Length) {
				_end = value;
			} else {
				throw new Exception("Inappropriate Index");
			}
		}
		get {
			return _end;
		}
	}

	public Int32 Size {
		get {
			return _size;
		}
	}

	public Int32 Capacity {
		set {
			Extend(value);
		}
		get {
			return _array.Length;
		}
	}

	public Boolean IsDynamic {
		set {
			_isDynamic = value;
		}
		get {
			return _isDynamic;
		}
	}

	public Boolean IsInfinite {
		set {
			_isInfinite = value;
		}
		get {
			return _isInfinite;
		}
	}

	private Boolean IsEmpty {
		get {
			return _size == 0;
		}
	}

	private Boolean IsFull {
		get {
			return _size == Capacity;
		}
	}

	object IEnumerator.Current {
		get {
			return Current;
		}
	}

	public T Current {
		get {
			try {
				return _array[_currentPosition];
			} catch (IndexOutOfRangeException) {
				throw new InvalidOperationException();
			}
		}
	}
}
