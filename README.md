# 1. 看 sing-box 启动日志（最关键）
logread | grep -i sing-box | tail -30

# 2. 找配置文件位置
ls /etc/open-box/ 2>/dev/null || ls /usr/share/open-box/ 2>/dev/null

# 3. 手动跑一下看具体报错
sing-box run -c /etc/open-box/config.json 2>&1 | head -20
