# openresty-tb
基于openresty实现的频率控制模块，使用token bucket算法。

背景：

nginx 现有的access模块功能较少，如果需要较为复杂的频率控制，一般要在业务模块实现，可是这又带了了性能问题。openresty可以高效开发nginx模块，
性能远高php等业务开发。

简介：

使用openresty，开发了一个acess模块，在access 阶段判断用户的使用频率是否超标，超标的话直接返回403，不要进入业务模块。频率判断使用
token bucket算法。

参考：
token bucket： https://zhuanlan.zhihu.com/p/20872901?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io&from=timeline&isappinstalled=0）。
openresty：https://github.com/openresty/lua-nginx-module

对比：
使用php完成同样功能，使用http_load测试：http_load -parallel 50 -seconds 30。
php（opcode关闭） qps：935
php（opcode打开） qps：1265.9
openresty qps：2193.97
