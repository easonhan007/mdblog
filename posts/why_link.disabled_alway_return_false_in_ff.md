为什么watir-webdriver的firefox driver中Link.disabled?总是会返回false

昨天在调试代码时发现，watir-webdriver中的Link.disabled?总是毫无根据的返回false，哪怕这个link对象看上去确实是disabled了————颜色变灰，无法点击。

后来上网爬文后才发现原来firefox中除表单元素外其他元素的disabled属性是无效的。这句拗口的话是什么意思？且看下面的例子。

	<a href = "#" disabled = "disabled">This is a link</a>

这个link在ie中显示的话应该是disabled的，不过用firefox打开后却发现，怎么回事，为什么什么变化都没有。该link还是活蹦乱跳的enable。

再看下面的例子：

	<html>
		<head><title>Form Disable Test</title></head>
		<body>
			<form>
				<label for = "ip1">For input</label>
				<input name = "ip1" disabled = "true"/>
				<br />
				<a href = "#" disabled = "true">This is the link</a>
			</form>
		</body>
	</html>

在这个例子里表单中的input元素是成功被disabled了的，但是link元素哪怕在表单里还是不会被disabled掉。这就是说link元素的disabled属性在firefox里是无效的。

那么为什么我们会在firefox中看到disabled的link样式呢？

这是前端工程师们的功劳。他们一般会给要被disabled的link加上css属性，比如让其color变成灰色，然后鼠标移上去的效果由手型(hand)变成箭头(default)，最后去掉link的href和onclick属性，这样1个link看上去就是被disabled了。

<p>回到正题，因为link的disabled属性是无效的，所以无论如何调用Link.disabled?的话，该方法总是返回false的。这就像是1个人没有房子，而你老是问他家在哪来，他肯定答不上来一样。<p>

最后，既然link的disabled方法总是返回false，那么如何去判断这个link是否被模拟成disabled了呢？

答案是获取该link的class属性。因为一般被模拟成disabled的link总是有其特殊的class值的，下面的代码可能会有些许帮助

	link(:id, 'disabled_link').attribute_value('class') # watir-webdriver适用
