println startUrl
//driver.get(startUrl)

elem = driver.findElement(By.id('searchq'))
elem.sendKeys('native events linux')

elems = driver.findElements(By.tagName('input')).findAll{it.getAttribute('value') == 'Search'}
elem = elems[0]
elem.click()

elems = driver.findElements(By.tagName('td')).findAll{it.getAttribute('class') == 'vt id col_0'}
println elems.size()
elem = elems[5]
subelem = elem.findElement(By.tagName('a'))
subelem.click()

//assert 