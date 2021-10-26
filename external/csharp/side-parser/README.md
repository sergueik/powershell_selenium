### Info
replica of
[glatsons/seleniumParser](https://github.com/glaysons/SeleniumParser)
i

Appear to [require C# 7.x](https://stackoverflow.com/questions/191940/c-sharp-generics-wont-allow-delegate-type-constraints) to support the syntax
```c# 

private void AddContextEvent<T>(Context context, T onCommand) where T : Delegate {
	if (onCommand != null)
		context.Events.Add(typeof(T), onCommand);
}
```
in `Parser.cs` and
```c#
protected T GetCustomEvent<T>() where T : Delegate {
	if (Current.Events.TryGetValue(typeof(T), out Delegate customEvent))
		return customEvent as T;
	return null;
}

```
in `Command.cs` and
