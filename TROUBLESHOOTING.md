# Open-Box 故障排查记录

> 上游项目：[liandu2024/Open-Box](https://github.com/liandu2024/Open-Box)
> 本仓库用于记录实际使用中遇到的问题与解决方案，并自动同步上游代码。

---

## 2026-10-01 v0.1.269 → v0.1.271 更新失败 + 面板无法启动

### 环境
- 固件：iStoreOS 24.10.8 (x86_64)
- 内核：6.6.144
- 更新前版本：v0.1.269
- 目标版本：v0.1.271

### 现象
1. 在 LuCI 面板里点"检查更新"升级到 v0.1.271，报错：**「组合后的安装包校验失败，现有安装未改动」**
2. LuCI 里 Open-Box 面板状态显示"运行中"，但浏览器访问 `http://192.168.100.1:2026` 打不开
3. 在 LuCI 里点"重启"面板后，状态变成"已停止"，再点"启动"也起不来

### 根因

**node 二进制损坏（段错误 Segmentation fault）**，形成死循环：

```
node 坏了
  ├→ 面板 index.mjs 跑不起来 → 端口 2026 没监听 → 面板打不开
  └→ 组件更新模式要用 node 拼接 app/runtime/kernel/geo 四个包
       → node 拼包时段错误 → 脚本报「组合后的安装包校验失败」
```

v0.1.267 起更新脚本改为"按需组件更新"：分别下载四个组件小包，**用 node 拼成完整包再校验**。node 坏了就永远过不了这步。

### 诊断过程

```sh
# 手动跑面板入口，看报错
/opt/open-box/node/bin/node /opt/open-box/panel/server/index.mjs 2>&1
# → Segmentation fault

# 确认 node 版本能打印但跑业务就崩
/opt/open-box/node/bin/node -v
# → v24.18.0（能打印版本，但跑 index.mjs 就段错误）

# 确认面板入口文件存在
ls /opt/open-box/panel/server/
# → index.mjs 在，文件没丢
```

### 解决方案

**核心思路：绕过组件更新（需要 node 拼包），强制走完整包下载（只用 curl + sha256sum，不经过 node）。**

```sh
# 1. 把组件更新脚本改名，让脚本退回完整包模式
mv /opt/open-box/panel/server/system/update-components.sh \
   /opt/open-box/panel/server/system/update-components.sh.bak

# 2. 用新脚本跑完整包更新
curl -fsSL https://raw.githubusercontent.com/liandu2024/Open-Box/main/scripts/update.sh | sh

# 3. 等待完成，看到 "v0.1.269 → v0.1.271" 和 "等待新版本的面板应答" 即成功

# 4. 更新完成后可以把改名的文件恢复（新版会自带，其实不用管）
```

### 关键命令速查

```sh
# SSH 进路由器后：

# 查看面板日志
logread | grep -i open-box | tail -30

# 检查端口
netstat -tlnp | grep 2026

# 手动测试 node 是否正常
/opt/open-box/node/bin/node -e 'process.stdout.write("ok")'

# 强制完整包更新（绕过组件模式）
mv /opt/open-box/panel/server/system/update-components.sh \
   /opt/open-box/panel/server/system/update-components.sh.bak
curl -fsSL https://raw.githubusercontent.com/liandu2024/Open-Box/main/scripts/update.sh | sh

# 走镜像（GitHub 直连慢时）
curl -fsSL https://ghfast.top/https://raw.githubusercontent.com/liandu2024/Open-Box/main/scripts/update.sh | sh -s -- --mirror
```

---

## 预防建议

- 更新前先跑 `node -e 'process.stdout.write("ok")'` 确认 node 没坏
- 如果面板突然打不开，先 SSH 手动跑一次面板看报什么错
- v0.1.267~v0.1.270 的设备建议直接 SSH 用新脚本升级，不要在 LuCI 里点（旧脚本有 bug）
