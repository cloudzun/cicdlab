# 使用httpd作为基准映像
FROM httpd:2.4

# 将你的静态页面复制到镜像中
COPY ./index.html /usr/local/apache2/htdocs/

# 当容器启动时运行httpd
CMD ["httpd-foreground"]
