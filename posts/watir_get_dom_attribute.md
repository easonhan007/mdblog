watir中如何获取dom的属性
========================

下面代码演示了如何在waitr中获取dom属性。

在进行自动化测试时，我们经常要获取这样的一些信息：

* 某dom元素的class值，用以判断该dom元素是否具有正确的样式；
* 某dom元素的style属性，用以判断该dom元素是否具有正确的样式；
* 通过dom元素的事件属性，例如onclick onfocus等来定位识别特定元素；

以上三种情况我们分别讨论。

### 获取dom元素的class值：

考虑如下的html代码
	<a class = "classA" href = "www.17test.info">乙醇的blog</a>

获取class属性的ruby代码

	ie.link(:link, 'classA').class_name

注意这里是class_name属性

----------------------------------------------------------------------------
### 获取dom元素的style属性

考虑如下的html代码

	<a id = "idA" href = "www.17test.info" style = "width:200px">乙醇的blog</a>

获取width大小的ruby代码

	width = ie.link(:id, 'idA').attribute_value('style').invoke('width')

----------------------------------------------------------------------------
### 通过dom元素的事件属性，例如onclick onfocus等来定位识别特定元素

考虑下面的html代码：

	<div onclick = "do_event()"></div>
	<div></div>
	<div></div>

我们如果要定位有onclick属性的div，我们可以这样做：

	ie.divs.each do |d|
		return d if d.html.contains?('onclick')
	end

