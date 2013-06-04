### 上一节我们讲了如何利用watir去定位页面上的简单元素，这一节我们介绍一些更加复杂的元素的定位方法。

#### Forms

我们知道，如果form有submit按钮的话，我们可以点击submit按钮来提交form。其html如下所示：

	<form action = "example.php" method = "post">

		<input type = "submit" id = "sub" value = "Submit" \>

	</form>

我们直接点击“提交”按钮既可将数据提交到后台。具体代码如下：

	Ie.button(:id, 'sub').click

不过在有些时候，我们可能碰到一些没有submit按钮的form，例如下面的html代码：

	<form id="searchForm" action="http://www.example.com/v3/example/search/get" method="get">

		<div title="搜索" onclick="search();" id="searchButtonDiv"></div>

		<input value="关键词或完整ID" id="dataSearchKeyword" class="secondary" name="keyword">

	</form>

这个form就是没有submit按钮。这时候我们可以通过如下的方法来提交该form。

* 通过id属性：

	Ie.form(:id, 'searchFrom')

* 通过name属性：

如果form有name的话，我们可以这样做：

	Ie.form(:name, 'my_name')

* 通过action属性：

如上面所示的html代码，我们可以通过action属性来进行提交。

	Ie.form(:action, /search\/get/) #正则表达式是支持的

* 通过method属性：

注意，由于页面上可能有很多method相同的form，在这时watir将定位到第1个method属性相符的form对象。

	Ie.form(:method, 'get')

* 其他方法：

通过观察上面的html，我们发现点击这个`<div title=”搜索” onclick=”search();” id=”searchButtonDiv”></div>` div的时候，js将触发1个`search()`方法，该方法就的作用就是提交form，因此我们可以直接点击这个div来进行提交。具体代码如下：

	Ie.div(:id, 'searchButtonDiv').click

#### Frames

Frame是个令人头痛和恶心的东西————跟中国足球一样，同样也跟怀孕了一样。我们访问frame时候经常会有access denied错误，这个错误往往令我们焦急、心烦、恼火、放弃。另外有时候，我们总是定位不到某个元素，在苦苦调试了许久后，我们才悲催的发现，原来该元素是在某frame中。

在web自动化测试中，frame是难点，但绝不是绊脚石。在掌握一些方法后，使用frame会变得并不困难，下面我们将详细讲解。

##### 查看页面上所有的frame：

在定位frame之前，我们可以使用下面的方法来查看页面上所有的frame，这在调试时很有用。

	ie.show_frames

该方法最好在irb中使用，如下所示：

	irb(main):009:0> ie.show_frames

	there are 2 frames

	frame  index: 1 name: menu

	frame  index: 2 name: main

	=> 0..1

* 通过name访问：

我们可以直接通过name属性来访问frame

	ie.frame(:name, 'my_frame')

如果该frame上有1个link，那么可以通过frame去访问该link

	ie.frame(:name, 'my_frame').link(:id, 'my_link').click

* 通过id访问：

	ie.frame(:id 'my_frame')

* 通过src访问：

Frame是支持src属性的访问的。

	ie.frame(:src, 'index.htm')

* 通过index访问：

当你所访问的frame没有id,name等信息时，也可以通过index属性来访问。

	ie.frame(:index,1) #这表示访问页面上第1个frame。

* 嵌套的frame：

Frame是可以嵌套的，在实际工作中，我们经常会被嵌套的frame弄得痛苦不堪。我们经常会反复的去定位某个frame，在将所有frame的属性都实验了一遍后，我们发现该frame还是无法定位。这种情况往往是因为嵌套的frame造成的。我们不能越过父frame去直接访问子frame。嵌套的frame支持以如下的方式访问。

	ie.frame(:name, 'my_frame')

* 关于access denied：

万恶的access denied是因为IE防止XSS攻击造成的。

具体解决方法如下：

* 直接使用ie.goto(“your _frame_url”)来访问Frame的url；
* 将你需要访问的url加入IE的信任地址；
* 在host文件中为你的访问的地址取个别名，例如 192.168.10.32 foosystem。这样的 话使用foosystem来替代192.168.10.32进行访问既可；
* 如果上述方法都不管用，那么直接关掉告警吧。具体代码如下：
	ie.logger.level = Logger::ERROR

