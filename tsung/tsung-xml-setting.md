## 6 tsung.xml 配置文件
### 6.1 文件结构
默认编码是utf8，可以设定一个编码格式，例子：

    <?xml version="1.0" encoding="ISO-8859-1"?>
标记 tsung tag:

    <?xml version="1.0"?>
    <!DOCTYPE tsung SYSTEM "/usr/share/tsung/tsung-1.0.dtd" [] >
    <tsung loglevel="info">
    ...
    </tsung>  
如果添加属性 `dumptraffic=”true”`时，所有的数据将被记录到日志中。

    警告:这将大大减缓tsung的效率，谨慎使用，它只适合于debug模式，可以使用`dumptraffic=”light”`只 dump 前 44 字节。
从1.4.0版本后，可以按照协议定义记录，使用`dumptraffic=”protocol”`。目前只针对HTTP实现，这将所有的请求记录到一个 csv 文件中，类似:
    
    #date;pid;id;http method;host;URL;HTTP status;size;duration;transaction;match;error;tag
    
字段 | 描述 | 中文描述
----------- | ----------- | -----------
date | timestamp at the end of the request (seconds since 1970-01-01 00:00:00 UTC) | 请求结束时间
pid | erlang process id| erlang进程id
id | tsung user id| tsung 用户 id
host | server hostname| 主机名
url | url| url 相对地址
HTTP | status HTTP reponse status (200, 304, etc.) | http状态码(200，304)
size | reponse size (in bytes)| 请求字节
duration | request duration (msec)|请求时间(毫秒)
transaction | name of the transaction (if any) this request was made in|事务名称
match | if a match is defined in the request: match|nomatch (last <match> if several are defined) | 请求中定义匹配
error | name of http error (or empty)| http 错误名称
tag | tag name if the request was tagged; empty otherwise | 定义请求标签，否则是空

    警告:一般情况下，多客户端的生成文件不会呗排序，所以必须在分析之前进行排序
对于高负载情况(每秒几十万上百万的请求)，协议日志记录可能会导致控制器超载，所以这种情况下，需要使用本地协议日志来代替，协议日志文件将写入每个客户端本地，这样需要在测试完毕后手动合并日志。

日志级别对于性能影响很大，对于高负载建议使用 warning 级别。

日志级别:

- emergency
- critical
- error
- warning
- notice (default)
- info
- debug

如果需要详细记录，需要重新编译tsung ,在make 的时候增加 debug 参数和日志参数到 debug.
### 6.2  客户端和服务端
tsung 集群中客户端和服务器定义
#### 6.2.1 基础设置
对于单机模式，可以使用基本设置:

    <clients>
      <client host="localhost" use_controller_vm="true"/>
    </clients>

    <servers>
      <server host="192.168.1.1" port="80" type="tcp"></server>
    </servers>
在同一主机上，启动工作节点和控制节点。

服务器设置可以是集群，可以添加多个服务器，默认情况下，每个服务器权重是1，每次都会按照权重选择服务器加压，权重可以设置(可以使用整数或者浮点设置):

    <servers>
        <server host="server1" port="80" type="tcp" weight="4"></server>
        <server host="server2" port="80" type="tcp" weight="1"></server>
    </servers>
(1.5.0之前的版本没有实现权重设置，通过轮询算法来选择服务器)，协议类型可以是 tcp\ssl\udp(对于ipv6，ssl6或者udp6；只支持1.4.2以上版本)或websocket(仅支持1.5.0以上版本)还有一个特殊类型: BOSH，用于未加密的 BOSH 和 bosh_ssl 的加密链接。
#### 6.2.2 高级设置
这个例子比较复杂，使用了分布式配置:

    <clients>
      <client host="louxor" weight="1" maxusers="800">
        <ip value="10.9.195.12"></ip>
        <ip value="10.9.195.13"></ip>
      </client>
      <client host="memphis" weight="3" maxusers="600" cpu="2"/>
    </clients>

    <servers>
      <server host="10.9.195.1" port="8080" type="tcp"></server>
    </servers>
使用更多的机器来模拟虚拟客户端ip，当一个负载均衡使用一个客户端ip来分发集群流量时，非常有用。

1.1.1 新特性: IP 不再强制，如果未指定，将使用默认ip。

1.4.0 新特性: 可以使用` <ip scan="true" value="eth0"/>` 扫描一个指定网卡接口的ip，例子中使用(eth0)

在例子的集群中，第二台机器拥有高权重和2cpus，两个erlang虚拟机加压机将拥有cpu数量优势。

    注意：尽管erlang的虚拟加压机可以处理多个cpu(erlang smp)，但是测试表明，一个cpu对应一个虚拟机(禁用smp)，效能更高。只有控制器节点使用 smp erlang.因此，cpu设置应该等于你的节点cpu数量，如果喜欢使用 smp ，启动使用 -s 参数添加，不要在config 文件设置。
默认情况下，负载将均匀的分布在每个cpu上(每个客户端1个cpu的情况下),权重参数可以考虑到客户端机器的速度。例如,如果一个真实的客户端机器具有1的权重，其他的机器2的权重，那从第二个客户端机器开始启动的用户将是第一个客户端机器上的2倍。前面例子，第二个客户机器有2个cpu和3权重，重量等于每个cpu 1.5倍权重。
##### 6.2.2.1 最大用户
maxusers 参数用于限制单一进程的最大数，通打开socket最大数(默认操作系统 1024)，如果设置异常，需要扩展系统调用。当用户数量大于限制时，一个新的erlang虚拟机将倍启动，以处理新的用户。默认值800。当内核打开polling时，这个值可以设置的非常高(3w为例)，也没有什么性能损失，(但不要忘记打开文件打开数， ulimit -n. see also Why do i have error_connect_emfile errors?)

    注意：如果使用一个 tsung master slave 模式，master将分发回话到 slave 上。如果一个回话链接中有多个请求，将在一个slave 中按顺序执行。
#### 6.2.3 在tsung运行一个作业调度
tsung 可以获得客户端节点列表并且批量执行作业调度程序。目前它可以处理 PBS/torque, LSF and OAR.如果要做到这一点，属性类型(type)设置为批量(batch)，如：

    <client type="batch" batch="torque" maxusers="30000">
如果需要扫描节点的ip地址别名给调度器，使用  scan_intf 
    
    <client type="batch" batch="torque" scan_intf='eth0' maxusers="30000">
## 6.3 监控
tsung 从远程代理使用多个后端监控远程服务器。这里在 <monitoring> 里配置。可以统计信息包括:cpu\load average 和内存使用。

可以从一个调度程序来得到节点的监控，如:
    
    <monitor batch="true" host="torque" type="erlang"></monitor>
远程代理支持集中类型，(erlang时默认的)

### 6.3.1 Erlang
远程代理时由tsung 提供。它使用erlang 通讯检查服务器上的活动数据统计，例如:一个基于erlang的代理集群监控定义，如:

    <monitoring>
      <monitor host="geronimo" type="erlang"></monitor>
      <monitor host="bigfoot-1" type="erlang"></monitor>
      <monitor host="bigfoot-2" type="erlang"></monitor>
      <monitor host="f14-1" type="erlang"></monitor>
      <monitor host="f14-2" type="erlang"></monitor>
      <monitor host="db" type="erlang"></monitor>
    </monitoring>
注意保证一下几点:

- 保证网络可访问，打开erlang通许端口(最好没有防火墙设置)
- ssh 无密码链接
- 每个节点的 otp 版本必须一致

如果不能在远程服务器上安装erlang，可以使用一个活着的代理。在新的1.5.1版本，erlang监控包涵一个mysqladmin 的 mysql db的监控，使用如:

    <monitor host="db" type="erlang"></monitor>
         <mysqladmin port="3306" username="root" password="sesame" />
    </monitor>
可统计数据包含:mysql线程数和查询数量

### 6.3.2 SNMP
如果想使用 snmp 监控，需要将type值替换成 snmp，从1.2.2 版本后，他们也可以混合使用。使用net-snmp提供管理信息库(MIB).

    <monitoring>
      <monitor host="geronimo" type="snmp"/>
      <monitor host="f14-2" type="erlang"></monitor>
      <monitor host="db" type="snmp">
        <snmp version="v2" community="mycommunity" port="11161"/>
      </monitor>
    </monitoring>
默认版本v1，默认 community 设置 public 和默认端口 161. 从 1.4.2 版本后，你可以兹定于 snmp 服务器检索对象标识符(OID),使用一个或者多个OID元素例子:

    <monitor host="127.0.0.1" type="snmp">
      <snmp version="v2">
        <oid value="1.3.6.1.4.1.42.2.145.3.163.1.1.2.11.0"
         name="heapused" type="sample" eval="fun(X)-> X/100 end."/>
      </snmp>
    </monitor>
类型可以sample, counter or sum，可以使用 erlang 语法定义一条函数被应用到值(eval属性)的功能
### 6.3.3 Munin
1.3.1版本中，tsung 可以从 munin-nod 代理获取数据。type 必须修改成 munin,例子:

    <monitoring>
      <monitor host="geronimo" type="munin"/>
      <monitor host="f14-2" type="erlang"></monitor>
    </monitoring>
## 6.4 定义负载
### 6.4.1 随机产生用户
负载进程建立通过一下几个点段定义：

    <load>
      <arrivalphase phase="1" duration="10" unit="minute">
        <users interarrival="2" unit="second"></users>
      </arrivalphase>

      <arrivalphase phase="2" duration="10" unit="minute">
        <users interarrival="1" unit="second"></users>
      </arrivalphase>

      <arrivalphase phase="3" duration="10" unit="minute">
        <users interarrival="0.1" unit="second"></users>
      </arrivalphase>
    </load>
这个测试的设置中，第一个10分钟里，每2秒创建一个新用户，在第二个10分钟里，每一秒创建一个新用户。最后一个10分钟里，每秒钟将产生10个用户，这个测试结束。

还可以使用 arrivalrate 代替 interarrival。样例，每秒都生成10个用户: 

    <arrivalphase phase="1" duration="10" unit="minute">
      <users arrivalrate="10" unit="second"></users>
    </arrivalphase>
可以限制模拟用户最大数量，通过 maxnumber 属性，类似:

    <arrivalphase phase="1" duration="10" unit="minute">
      <users maxnumber="100" arrivalrate="10" unit="second"></users>
    </arrivalphase>
    
    <arrivalphase phase="2" duration="10" unit="minute">
      <users maxnumber="200" arrivalrate="10" unit="second"></users>
    </arrivalphase>
这种情况，第一个阶段最多创建100个用户，第二个阶段200.在负载的标签属性中可以使用 loop 参数来进行循环执行相同的模型。(loop='2'只将循环2次，因此整个流程将执行3次，本功能在 1.2.2加入)

产生的负载将术语时 http requests/秒，也将取决于一个会话中的请求平均数(如果每个会话每秒100个请求和10个新用户的平均值，理论吞吐量将势1000 rps)。

新的1.5.1 版本中，你可以在回话中使用覆盖率(probability)新特性,使用 session_setup

    <arrivalphase phase="3" duration="1" unit="minute">
      <session_setup name="http_test_1" probability="80"/>
      <session_setup name="fake"        probability="20"/>
      <users  interarrival="1" unit="second"/>
    </arrivalphase>
### 6.4.2 静态生成用户
如果想在测试期间一个指定的时间内，开始就一个指定的回话数，1.3.1版本开始支持:

    <load>
      <arrivalphase phase="1" duration="10" unit="minute">
        <users interarrival="2" unit="second"></users>
      </arrivalphase>
      
      <user session="http-example" start_time="185" unit="second"></user>
      <user session="http-example" start_time="10" unit="minute"></user>
      <user session="foo" start_time="11" unit="minute"></user>
    </load>
    
    
    <sessions>
      <session name="http-example" probability="0" type="ts_http">
        <request> <http url="/" method="GET"></http> </request>
      </session>
  
      <session name="foobar" probability="0" type="ts_http">
        <request> <http url="/bar" method="GET"></http> </request>
      </session>
  
      <session name="foo" probability="100" type="ts_http">
        <request> <http url="/" method="GET"></http> </request>
      </session>
    <sessions>
在例子中，有2个会话概率(probability)是0(因此第一阶段不会使用),和一个概率100%。定义了3个用户：第一个用户185秒后启动，第二个用户10秒后启动，第三个用户11秒启动。

在新的1.5.1 版本中，想一次触发几个会话和想这些会话有相同的前缀，可以使用通配符。例子将启动2个用户在测试开始10秒后：

    <user session="foo*" start_time="10" unit="second"/>
### 6.4.3 负载测试持续时间
默认情况下，当所用户开始完成了他们的会话即会结束。因此它可以比arrivalphases持续时间长很多。如果想在固定时间(即使任务没有完成)停止 tsung，添加duration(持续时间)属性可以做到。(1.3.2 功能)

    <load duration="1" unit="hour">
      <arrivalphase phase="1" duration="10" unit="minute">
        <users interarrival="2" unit="second"></users>
      </arrivalphase>
    </load>
样例中持续时间1小时，单位可以设置成:second, minute or hour
## 6.5 设置选项
### 6.5.1 Thinktimes, SSL, Buffers
默认的值可以创建全局变量：在方案中，thinktime (思考时间)与请求之间、ssl加密算法，tcp/udp缓冲区大小(默认32KB),都可以使用参数进行设置来覆盖真实的。

    <option name="thinktime" value="3" random="false" override="true"/>
    <option name="ssl_ciphers"
        value="EXP1024-RC4-SHA,EDH-RSA-DES-CBC3-SHA"/>
    <option name="tcp_snd_buffer" value="16384"></option>
    <option name="tcp_rcv_buffer" value="16384"></option>
    <option name="udp_snd_buffer" value="16384"></option>
    <option name="udp_rcv_buffer" value="16384"></option>
在1.6.0版本中，可以禁用ssl会话缓存，默认是打开的.

    <option name="ssl_reuse_sessions" value="false"/>
可以使用命令行参数 -l 来更改缓存里的会话生命周期，默认是10分钟，值单位必须是秒
### 6.5.2 Timeout for TCP connections
在 1.6.0 版本中，可以建立一个tcp链接超时时间(毫秒级)，默认无穷大。
    
    <option name="connect_timeout" value="5000" />
也可以修改每个会话的超时时间，使用 set_option

    <set_option name="connect_timeout" value="1000" />
也可以全局启用 TCP REUSEADDR

    <option name=”tcp_reuseaddr” value=”true” />
### 6.5.3 重试次数和超时时间
可以设置指定重试次数，默认是3，关闭是0

    <option name="max_retries" value="5" />
默认超时时间是10秒，用于实现补偿算法(retry * retry_timeout)  

    <set_option name="retry_timeout" value="1000" />
### 6.5.4 超时确认消息
用来设置空闲超时，默认情况下，空闲超时为10分钟(60000) 和全局 ack 超时是无穷大。政治修改如下:

    <option name="idle_timeout" value="300000"></option>
    <option name="global_ack_timeout" value="6000000"></option>
### 6.5.5 Hibernate
在 1.3.1 版本中，hibernate 选项是模拟在思考的用户减少内存消耗。默认情况下，休眠高于10秒的时间会被激活。这个值可以修改：

    <option name="hibernate" value="5"></option>
关闭值必须填写成 infinity。
### 6.5.6 Rate_limit
rate_limit 将限制每个客户的带宽(令牌算法)。该值每秒千子节。也可以设置最大突发值(max='2048'),默认突发大小和普通情况相同(1024kb例子)，目前值输入流量率限制。

    <option name="rate_limit" value="1024"></option>
### 6.5.7. Ports_range
如果需要打开一个客户端机器上超过3w个并发链接，可以通过设置tcp端口数量。即使你使用多个ip.要绕过这个限制，tsung 必须不委托选择客户端端口和目标端口，而每个客户端使用多个ip，定义端口范围：

    <option name="ports_range" min="1025" max="65535"/>
### 6.5.8. 设置随机数种子
如果想使用一个固定的种子随机生成，可以使用种子选项，默认情况下，当使用时间来设定种子，每个测试的随机数应该是不同的。如：

    <option name="seed" value="42"/>
### 6.5.9. Path for BOSH
可以使用下面的配置选项来设置 bosh 请求的路径：

    <option name="bosh_path" value="/http-bind/"/>
### 6.5.10. Websocket options
使用 websocket作为服务器类型，可以设置一下选项：

    <option name="websocket_path" value="/chat"/>

    <!-- send websocket data with text frame, default binary-->
    <option name="websocket_frame" value="text"/>
使用  websocket_path 设置请求路径，使用websocket_frame设置帧类型(支持  binary and text ，默认default) 发送数据。
### 6.5.11. XMPP/Jabber options
默认值对于特定的协议被定义，下面是  Jabber/XMPP

    <option type="ts_jabber" name="global_number" value="5" />    
    <option type="ts_jabber" name="userid_max" value="100" />
    <option type="ts_jabber" name="domain" value="jabber.org" />
    <option type="ts_jabber" name="username" value="myuser" />
    <option type="ts_jabber" name="passwd" value="mypasswd" />
    <option type="ts_jabber" name="muc_service" value="conference.localhost"/>
使用这些值，用户将myuserXXX其中xxx是个区间整数.[1:userid_max] 密码是 mypasswdxxx.如果配置文件中没设定，默认定义：

- global_number = 100
- userid_max = 10000
- domain = erlang-projects.org
- username = tsunguser
- passwd = sesame
如果喜欢帐户密码，使用一个csv文件即可。还可以设置muc_servce.

### 6.5.12. HTTP options
对于HTTP,可以设置 UserAgent 值(tsung 1.1.0提供),使用每个值的概率(所有概率必须等于100)

     <option type="ts_http" name="user_agent">
      <user_agent probability="80">
         Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050513 Galeon/1.3.21
      </user_agent>
      <user_agent probability="20">
        Mozilla/5.0 (Windows; U; Windows NT 5.2; fr-FR; rv:1.7.8) Gecko/20050511 Firefox/1.0.4
      </user_agent>
    </option>
### 6.5.13. AMQP options
可以同时设置 AMQP 心跳超时，例如 30秒(默认600秒)：

    <option type="ts_amqp" name="heartbeat" value="30" />
## 6.6 Sessions
会话定义场景内容本身，描述执行的请求。每个会话都要有一个给定的概率，用来判断新用户执行那个会话，所有会话概率必须是100.
1.5.0版本后，可以使用权重，而不是概率，下面的例子中 s1比s2多1倍会话。

    <session name="s1" weight="2" type="ts_http">
    <session name="s2" weight="1" type="ts_http">
事务只是一种个性的统计数据，如果想知道网站登录页面响应时间，只要把网页(htmpl+嵌入图片)所有请求放在事务中。
上面的例子中，在报告中平均响应时间将的得到 index.en.html + header.gif 的index_requset 指数。如果事务中有 thinktime ，那 thinktime 也将计算进去。

### 6.6.1. Thinktimes
可以设置静态或者随机的思考时间，默认情况下，随机思考时间是一个指数分布，均值等于值。

    <thinktime value="20" random="true"></thinktime>
在例子中，思考时间指数为20秒分布，从1.3.0版本后，也可以使用范围 [min:max],而不是随机思考时间来做分布：

    <thinktime min="2" max="10" random="true"></thinktime>
1.4.0 版本中，使用动态变量设定思考值：

    <thinktime value="%%_rndthink%%" random="true"></thinktime>    
也可以使用 wait_global 值同步所有用户

    <thinktime value='wait_global'>
意味着所有的用户都设置等待全局锁。(这个值可以通过选项设置<option name="global_number" value ="XXX"/>，并通过设置 <arrivalphase> maxnumber=N)，从1.6.0 版本，可以等待 bidi 应答。如果协议是双向的(例如xmpp, websocket等)，你可以等待服务器发送一些数据，而处理这些数据的代码就是退出思考状态。

    <thinktime value="wait_bidi"></thinktime> 
### 6.6.2 HTTP
例子显示了几个特点：get和post请求，基本身份验证，事务统计定义，条件请求(IF MODIFIED SINCE)

    <sessions>
     <session name="http-example" probability="70" type="ts_http">

       <request> <http url="/" method="GET" version="1.1">
                   </http> </request>
       <request> <http url="/images/logo.gif"
              method="GET" version="1.1"
              if_modified_since="Fri, 14 Nov 2003 02:43:31 GMT">
             </http></request>

       <thinktime value="20" random="true"></thinktime>

       <transaction name="index_request">
   
           <request><http url="/index.en.html"
                         method="GET" version="1.1" >
                 </http> </request>
           <request><http url="/images/header.gif"
                         method="GET" version="1.1">
                 </http> </request>
       </transaction>

       <thinktime value="60" random="true"></thinktime>
       
       <request>
         <http url="/" method="POST" version="1.1"
              contents="bla=blu">
         </http> </request>
       
       <request>
          <http url="/bla" method="POST" version="1.1"
            contents="bla=blu&amp;name=glop">
          <www_authenticate userid="Aladdin"
                        passwd="open sesame"/></http>
       </request>
     
     </session>

     <session name="backoffice" probability="30" ...>
     ...
     </session>
    </sessions>
如果使用绝对url，将使用的服务器信息覆盖到url中，下个请求也将会使用新服务器。1.2.2 课题添加任何的http头，如：

    <request>
      <http url="/bla" method="POST" contents="bla=blu&amp;name=glop">
        <www_authenticate userid="Aladdin" passwd="open sesame"/>
        <http_header name="Cache-Control" value="no-cache"/>
        <http_header name="Referer" value="http://www.w3.org/"/>
      </http>
    </request>
1.3.1 可以使用post或者put读取一个外部文件

    <http url="mypage" method="POST" contents_from_file="/tmp/myfile" />
1.3.1 还可以手动设置 cookie，尽快不持久，必须每个请求都要添加

    <http url="/">
      <add_cookie key="foo" value="bar"/>
      <add_cookie key="id"  value="123"/>
    </http>
#### 6.6.2.1. Authentication
1.5.0以后版本支持基础认证，支持 Digest Authentication and OAuth 1.0

Digest Authentication

    <!-- 1. First request return 401. We use dynvars to fetch nonce and realm -->
    <request>
      <dyn_variable name="nonce" header="www-authenticate/nonce"/>
      <dyn_variable name="realm" header="www-authenticate/realm"/>
      <http url="/digest" method="GET" version="1.1"/>
    </request>

     <!--
     2. This request will be authenticated. Type="digest" is important.
     We use the nonce and realm values returned from the previous
     If the webserver returns the nextnonce we set it to the nonce dynvar
     for use with the next request.
     Else it stays set to the old value
     -->
     <request subst="true">
       <dyn_variable name="nonce" header="authentication-info/nextnonce"/>
       <http url="/digest" method="GET" version="1.1">
         <www_authenticate userid="user" passwd="passwd" type="digest" realm="%%_realm%%" nonce="%%_nonce%%"/>
       </http>
     </request>
 OAuth
 
     <!-- Getting a Request Token -->

      <request>
        <dyn_variable name="access_token" re="oauth_token=([^&amp;]*)"/>
          <dyn_variable name="access_token_secret" re="oauth_token_secret=([^&amp;]*)" />
          <http url="/oauth/example/request_token.php" method="POST" version="1.1" contents="empty">
            <oauth consumer_key="key" consumer_secret="secret"  method="HMAC-SHA1"/>
          </http>
      </request>

      <!-- Getting an Access Token -->

      <request subst='true'>
       <dyn_variable name="access_token" re="oauth_token=([^&amp;]*)"/>
       <dyn_variable name="access_token_secret" re="oauth_token_secret=([^&amp;]*)"/>
         <http url="/oauth/example/access_token.php" method="POST" version="1.1" contents="empty">
         <oauth consumer_key="key" consumer_secret="secret"  method="HMAC-SHA1" access_token="%%_access_token%%" access_token_secret="%%_access_token_secret%%"/>
       </http>
     </request>

     <!-- Making Authenticated Calls -->

     <request subst="true">
       <http url="/oauth/example/echo_api.php" method="GET" version="1.1">
        <oauth consumer_key="key" consumer_secret="secret" access_token="%%_access_token%%" access_token_secret="%%_access_token_secret%%"/>
       </http>
     </request>
###  6.6.3 Jabber/XMPP
#### 6.6.3.1. Message stamping
#### 6.6.3.2. StartTLS
#### 6.6.3.3. Roster
#### 6.6.3.4. SASL Plain
#### 6.6.3.5. SASL Anonymous
#### 6.6.3.6. Presence
#### 6.6.3.7. MUC
#### 6.6.3.8. PubSub
#### 6.6.3.9. VHost
#### 6.6.3.10. Reading usernames and password from a CSV file
#### 6.6.3.11. raw XML
#### 6.6.3.12. resource

### 6.6.4. PostgreSQL
### 6.6.5. MySQL
### 6.6.6. Websocket
### 6.6.7. AMQP
### 6.6.8. MQTT

### 6.6.9. LDAP
#### 6.6.9.1. Authentication
#### 6.6.9.2. LDAP Setup
#### 6.6.9.3. Other examples
### 6.6.10. Mixing session type
### 6.6.11. Raw

## 6.7. Advanced Features
### 6.7.1. Dynamic substitutions
### 6.7.2. Reading external file

### 6.7.3. Dynamic variables
#### 6.7.3.1. Regexp
#### 6.7.3.2. XPath
#### 6.7.3.3. JSONPath
#### 6.7.3.4. PostgreSQL
#### 6.7.3.5. Decoding variables
#### 6.7.3.6. set_dynvars

### 6.7.4. Checking the server’s response

### 6.7.5. Loops, If, Foreach
#### 6.7.5.1. <for>
#### 6.7.5.2. <repeat>
#### 6.7.5.3. <if>
#### 6.7.5.4. <foreach>

### 6.7.6. Rate limiting
### 6.7.7. Requests exclusion
### 6.7.8. Client certificate


