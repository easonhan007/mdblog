揭秘webdriver实现原理
----------------------

通过研究selenium-webdriver的源码，笔者发现其实webdriver的实现原理并不高深莫测无法揣度。在这里以webdriver ruby binding的firefox-webdriver实现为例，简单介绍一下webdriver的工作原理。

* 当测试脚本启动firefox的时候，selenium-webdriver 会首先在新线程中启动firefox浏览器。如果测试脚本指定了firefox的profile，那么就以该profile启动，否则的话就新启1个profile，并启动firefox；

* firefox一般是以-no-remote的方法启动，启动后selenium-webdriver会将firefox绑定到特定的端口，绑定完成后该firefox实例便作为webdriver的remote server存在；

* 客户端(也就是测试脚本)创建1个session，在该session中通过http请求向remote server发送restful的请求，remote server解析请求，完成相应操作并返回response；

* 客户端接受response，并分析其返回值以决定是转到第3步还是结束脚本；

这就是webdriver的工作流程，看起来很复杂实际上当了解了webdriver的实现原理后，理解上述问题应该比较简单。

webdriver是按照server - client的经典设计模式设计的。

server端就是remote server，可以是任意的浏览器。当我们的脚本启动浏览器后，该浏览器就是remote server，它的职责就是等待client发送请求并做出相应；

client端简单说来就是我们的测试代码，我们测试代码中的一些行为，比如打开浏览器，转跳到特定的url等操作是以http请求的方式发送给被测试浏览器，也就是remote server；remote server接受请求，并执行相应操作，并在response中返回执行状态、返回值等信息；

举个实际的例子，下面代码的作用是"命令"firefox转跳到google主页：

	driver = Selenium::WebDriver.for :firefox
	driver.navigate.to "http://google.com"

在执行driver.navigate.to "http://google.com" 这句代码时，client，也就是我们的测试代码向remote server发送了如下的请求：

	POST session/285b12e4-2b8a-4fe6-90e1-c35cba245956/url

	post_data {"url":"http://google.com"} 

通过post的方式请求localhost:port/hub/session/session_id/url地址，请求浏览器完成跳转url的操作。

如果上述请求是可接受的，或者说remote server是实现了这个接口，那么remote server会跳转到该post data包含的url,并返回如下的response

	{"name":"get","sessionId":"285b12e4-2b8a-4fe6-90e1-c35cba245956","status":0,"value":""}

该response中包含如下信息

* name：remote server端的实现的方法的名称，这里是get，表示跳转到指定url；

* sessionId：当前session的id；

* status：请求执行的状态码，非0表示未正确执行，这里是0，表示一切ok不许担心；

* value：请求的返回值，这里返回值为空，如果client调用title接口，则该值应该是当前页面的title；

如果client发送的请求是定位某个特定的页面元素，则response的返回值可能是这样的：

	{"name":"findElement","sessionId":"285b12e4-2b8a-4fe6-90e1-c35cba245956","status":0,"value":{"ELEMENT":"{2192893e-f260-44c4-bdf6-7aad3c919739}"}}

name,sessionId，status跟上面的例子是差不多的，区别是该请求的返回值是ELEMENT:{2192893e-f260-44c4-bdf6-7aad3c919739}，表示定位到元素的id，通过该id，client可以发送如click之类的请求与server端进行交互。

那么remote server端的这些功能是如何实现的呢？答案是浏览器实现了webdriver的统一接口，这样client就可以通过统一的restful的接口去进行浏览器的自动化操作。目前webdriver支持ie, chrome, firefox, opera等主流浏览器，其主要原因是这些浏览器实现了webdriver约定的各种接口。
具体见http://code.google.com/p/selenium/wiki/JsonWireProtocol#Command_Reference。

由于笔者能力有限才疏学浅，因此文中定然有些谬误之处，还望不吝指出，多多斧正之。



