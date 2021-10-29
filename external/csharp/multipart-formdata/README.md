### Info

directory contains fixed and cleaned up code from [article](https://www.codeproject.com/Articles/8600/UploadFileEx-C-s-WebClient-UploadFile-with-more-fu)

### Testing

### Note

incorrectly building the payload, e.g. forgetting the `--` at the end,

```c#
byte[] boundaryBytes = Encoding.ASCII.GetBytes("\r\n--" + boundary + "--\r\n");
```
will lead to
```sh
2021-10-29 00:29:09.173 ERROR 8088 --- [nio-8085-exec-5] o.a.c.c.C.[.[.[/].[disp
atcherServlet]    : Servlet.service() for servlet [dispatcherServlet] in context
 with path [] threw exception [Request processing failed; nested exception is or
g.springframework.web.multipart.MultipartException: Failed to parse multipart se
rvlet request; nested exception is java.io.IOException: org.apache.tomcat.util.h
ttp.fileupload.FileUploadException: Stream ended unexpectedly] with root cause

org.apache.tomcat.util.http.fileupload.MultipartStream$MalformedStreamException:
 Stream ended unexpectedly
```
### See Also

  * https://www.codeproject.com/Articles/17449/Send-a-content-type-multipart-form-data-request-fr
  * https://www.codeproject.com/Articles/2359/File-Upload-using-a-VBScript-Class

### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
