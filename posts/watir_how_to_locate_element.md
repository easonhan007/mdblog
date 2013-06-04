waitr如何定位元素
=================

### 最近将watir更新到了1.9.1，忽然发现以前承诺的带大家读waitr源码的”夸夸其谈”还尚未实现，甚表歉意，暂且先说明一下watir定位(locate)元素的基本原来，聊以将功补过。
以下说明均以watir 1.9.1为例。在这里建议大家最好将watir升级到最新版本，因为最新版本增加了对IE9的支持，尽管支持的不是很全面，但聊胜于无，优势总是有的。

在watir的源码中找到`locator.rb`文件。该文件一般位于`your_disk:\Ruby192\lib\ruby\gems\1.9.1\gems\watir-1.9.1\lib\watir\`目录下。

### locator文件定义了1个Locator类，这个类是定位对象的1个helper类。该类中如如下2个方法：

* normalize_specifiers!: 该方法的作用是构造specifiers，而specifiers正是定位对象所要用到的”标识”。
* match_with_specifiers?: 该方法的作用是判断元素是否符合specifiers所定义的特征。如果符合，那么这个元素肯定就是我们要找的目标元素了。

简单看一下这2个方法的源码

首先简单介绍一下specifiers。specifiers看上去很陌生，但是在我们的watir脚本中，specifiers是无处不在的。考虑下面的代码：
	ie.div(:id => 'my_div')
	ie.link(:class => 'qq')
在这2个方法里面specifiers就是 `:id => 'my_div'`和`:class => 'qq'`。于是可以推断specifiers应该是Hash对象，像这样`div(:id, 'my_div')`非Hash形式的参数应该是会被转成Hash的。

-------------------------------------------------------------------------------------
    def normalize_specifiers!(specifiers)
      specifiers.each do |how, what|  # 遍历所有的specifiers,于是我们能推断出watir是支持多属性识别的。
									  # 例如`div(:id => 1, :class => 'red')`
        case how  # how就是:id, :class之类的元素属性，what就是这些属性的属性值
        when :index # 当用index定位对象时候就将what转成Integer类型
          what = what.to_i
        when :url
          how = :href # 如果how是url的话，那么将url属性变成href属性
		  			  # 这就证明了url和href属性的作用是相同的
        when :class # 如果how是class，就将class变成class_name，这个比较复杂，不解释
          how = :class_name
        when :caption # 可以看出caption就是value属性
          how = :value
        when :method # 可以看出method 实际上是form的method，也就是post或get
          how = :form_method
        end

        @specifiers[how] = what # 按照上面的规则重新生成specifiers，并赋值给@specifiers
      end
    end

    def match_with_specifiers?(element) # 判断element是否符合定位的条件
										# 也就是说element的属性是不是跟@specifiers定义的相同
										# 如果相同，这个element当然是我们需要寻找的了
      @specifiers.each do |how, what| # 遍历specifiers
        next if how == :index # 如果how是index的话则跳过
        return false unless match? element, how, what #如果match(element, how, what)为false，则返回false
      end
      return true # 否则就返回true
    end
  end
在这里要重点说一下match方法，match方法有3个参数，element how what， 该方法一般在Locator的子类中定义，下面会具体讲到。
match方法的作用就是如果element能够被how what匹配上则返回true，否则false

-------------------------------------------------------------------------------------
由于Locator只是基类，所以更加具体的识别任务就交由其子类完成。
### TaggedElementLocator是Locator的子类，其具体作用是根据所需定位元素的tag及users(脚本编写者)提供的specifiers来定位页面元素。
下面介绍一下TaggedElementLocator类的一些方法：

	class TaggedElementLocator < Locator
    def initialize(container, tag) #初始化时候指定了container和tag，其中tag就是定位的关键
      @container = container
      @tag = tag
    end

    def set_specifier(how, what) #处理了how和what，将how和what变成了Hash，印证了我们上面的猜测
      if how.class == Hash and what.nil?
        specifiers = how
      else
        specifiers = {how => what}
      end

      @specifiers = {:index => 1} # 如果没指定how和what，那么默认认为how是index，what是1，就是默认返回第1个元素
      normalize_specifiers! specifiers #调用了基类的方法，规整了specifiers并赋值给@specifiers
    end

    def each_element tag # 很关键的1个方法，其作用是根据tag值，并调用js来获取页面上所有的tag是给定值的ole对象，并封装成Watir的Element对象
	#在container上调用getElementsByTagName，这是js的dom操作代码，不懂请google
      @container.document.getElementsByTagName(tag).each do |ole_element| 
        yield Element.new(ole_element)
      end
    end

    def locate #比较复杂的方法
		#作用实际就是找到页面上所有的tag为给定值的watir element，然后遍历这些元素，如果这些元素能够被specifiers匹配则可能返回
      count = 0
      each_element(@tag) do |element|
        next unless match_with_specifiers?(element) # 如果该element不匹配则继续
        count += 1
        return element.ole_object if count == @specifiers[:index] #如果有多个元素满足条件，则返回第index个
			#默认情况下index是1，也就是返回第1个匹配
      end # elements # 于是我们可以写出如下的代码ie.div(:class => 'red', :index => 3)，返回class是red的第3个div元素
      nil
    end

    def match?(element, how, what) #核心的匹配方法,用来判断元素是否符合specifiers
      begin
        method = element.method(how) # 如果元素定义了element.how方法则获取这个方法的binding
		#举例来说如果元素是div，how是id，则返回Div#id这个方法的binding
      rescue NameError # 否则元素没有定义element.how方法，则抛出下面的错误
        raise MissingWayOfFindingObjectException,
          "#{how} is an unknown way of finding a <#{@tag}> element (#{what})"
      end
      case method.arity # 判断element.how的参数个数
      when 0 # 如果没有参数，则直接调用how方法，将返回的结果跟what值进行比较
        what.matches method.call
      when 1 # 如果有1个参数则将what值作为这个参数传给how方法
       	method.call(what)
      else
        raise MissingWayOfFindingObjectException, # 其他情况抛出错误
          "#{how} is an unknown way of finding a <#{@tag}> element (#{what})"
      end
    end # 该方法的返回值是what.matches或者是element.how(what),一般都是boolean

	end
-----------------------------------------------------------------------------------------------------------------------------
### 元素的定位就是这么简单，可能看了上面的代码大家都有些糊涂了。下面我们举例说明一下元素的定位之旅。
假设有下面的方法
	ie.div(:class => 'red', :index => 3)
* 首先watir会生成这样的1个@specifiers变量，其值为`{:class_name => 'red', :index => 3}`
* 然后watir会遍历页面上(实际上是container上，这里为了简单起见，简化了一下)所有的tag是<div>的元素，并将这些ole元素封装成了watir的element
* 最后在每一个element上调用how方法，在这个例子里就是调用@specifiers中的class_name方法。为什么没有调用index方法？因为index是跳过的，详见match_with_specifiers?方法
* 如果element.how等于what(为了理解又简化了，专家见谅)，也就是element.class_name = 'red'的话，则将看这个element是不是第index个，如果是则返回element的ole元素，元素定位之旅结束

__在这里我们可以看到waitr定位元素一般是通过遍历页面上所有与给定元素拥有相同tag的元素，并比较其属性值的方式进行的。__

其比较的方法和原理都很简单。当然，如果任意1个元素都通过遍历tag的方式进行的话，那么watir的效率将是比较低下的。为此watir也提供了快速定位的方法，这个我们以后再慢慢讨论。






