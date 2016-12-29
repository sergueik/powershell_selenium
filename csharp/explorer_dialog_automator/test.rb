# origin: https://github.com/ffi/ffi/wiki/windows-examples
require 'ffi'
module Win
  extend FFI::Library

  ffi_lib 'user32'
  ffi_convention :stdcall
  # public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr parameter);
  # BOOL CALLBACK EnumWindowsProc(HWND hwnd, LPARAM lParam)
  callback :enum_callback, [ :pointer, :long ], :bool

  # BOOL WINAPI EnumDesktopWindows(HDESK hDesktop, WNDENUMPROC lpfn, LPARAM lParam)
  attach_function :enum_desktop_windows, :EnumDesktopWindows,
                  [ :pointer, :enum_callback, :long ], :bool

  # static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
  # int GetWindowTextA(HWND hWnd, LPTSTR lpString, int nMaxCount)
  attach_function :get_window_text, :GetWindowTextA,
                  [ :pointer, :pointer, :int ], :int

  # TODO: 
  # public static extern bool EnumChildWindows(IntPtr hWndParent, EnumWindowsProc lpEnumFunc, IntPtr lParam)

  # static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);
  attach_function :get_class_name, :GetClassNameA,
                  [ :pointer, :pointer, :int ], :int
  # need to require https://github.com/arvicco/win: 
  # `attach_function': Function 'find_window_ex' not found in [user32] (FFI:NotFoundError)
  # public static extern IntPtr FindWindowEx(IntPtr parentHandle, IntPtr childAfter, string className, string windowTitle);
  # also see:http://stackoverflow.com/questions/3327666/win32s-findwindow-can-find-a-particular-window-with-the-exact-title-but-what
  attach_function :find_window_ex, :FindWindowExA, [:long, :long, :pointer, :pointer], :long

  # int GetWindowTextA(HWND hWnd, LPTSTR lpString, int nMaxCount)
  # static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam);
end

win_count = 0
title = FFI::MemoryPointer.new :char, 512
class_name = FFI::MemoryPointer.new :char, 32
Win::EnumWindowCallback = Proc.new do |wnd, param|
  title.clear
  Win.get_window_text(wnd, title, title.size)
  if title.get_string(0) =~ /Windows Security/
    Win.get_class_name(wnd, class_name, class_name.size)  
    puts "[%03i] Found '%s' %s" % [ win_count += 1, title.get_string(0), class_name.get_string(0) ]
  end
  true
end

if not Win.enum_desktop_windows(nil, Win::EnumWindowCallback, 0)
  puts 'Unable to enumerate current desktop\'s top-level windows'
end