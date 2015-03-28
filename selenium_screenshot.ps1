<#
File screenshot = ((TakesScreenshot)driver).getScreenshotAs(OutputType.FILE);
BufferedImage fullImg = ImageIO.read(screenshot);
WebElement element=driver.findElement(By.id("xyz"));
Point point = element.getLocation();
int eleWidth = element.getSize().getWidth();
int eleHeight = element.getSize().getHeight();
BufferedImage eleScreenshot= fullImg.getSubimage(point.getX(), point.getY(), eleWidth, eleHeight);
ImageIO.write(eleScreenshot, "png", screenshot);
FileUtils.copyFile(screenshot, file); 
alternative 
http://stackoverflow.com/questions/13832322/how-to-capture-the-screenshot-of-only-a-specific-element-using-selenium-webdrive
can be
IWebElement img = driver.FindElement(By.Id("submit-button"));

             int elementSize_Width = img.Size.Width;
             int elementSize_Height = img.Size.Height;

             Size s = new Size();
             s.Width = driver.Manage().Window.Size.Width;
             s.Height = driver.Manage().Window.Size.Height;

             Bitmap bitmap = new Bitmap(s.Width, s.Height);
             Graphics graphics = Graphics.FromImage(bitmap as Image);
             graphics.CopyFromScreen(0, 0, 0, 0, s);

             bitmap.Save(filePath, System.Drawing.Imaging.ImageFormat.Png);

             RectangleF part = new RectangleF(elementLocation_X, elementLocation_Y + (s.Height - viewportHeight), elementSize_Width, elementSize_Height);

             Bitmap bmpobj = (Bitmap)Image.FromFile(filePath);
             Bitmap bn = bmpobj.Clone(part, bmpobj.PixelFormat);
             bn.Save(finalPictureFilePath, System.Drawing.Imaging.ImageFormat.Png); 
#>
