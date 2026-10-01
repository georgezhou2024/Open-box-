# Open-Box

> 本仓库是 [liandu2024/Open-Box](https://github.com/liandu2024/Open-Box) 的个人镜像 + 故障记录。
> 上游有更新时自动同步到本仓库。

## 链接

- **上游项目**：https://github.com/liandu2024/Open-Box
- **问题排查记录**：[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

---

## 忘记面板密码

面板密码保存在路由器上，能以 root 登上路由器就能查到，不需要重装，也不会丢失订阅和规则。

### 方法一：LuCI 页面

路由器管理界面 → 服务 → Open-Box，页面顶部「完整管理请到 Open-Box 面板：」那一行，面板地址后面直接显示 `密码: xxxx`。

> 刚升级完看不到的话，退出 LuCI 重新登录一次。

### 方法二：SSH 命令

SSH 登上路由器后运行：

```sh
# 打开管理菜单，选 1 查看当前密码
open-box
# 然后输入 1
```

或者直接一行命令：

```sh
open-box password
```

### 常用命令速查

| 命令 | 作用 |
|------|------|
| `open-box password` | 查看面板密码 |
| `open-box check` | 检查有没有新版本 |
| `open-box update` | 直接升级 |
| `open-box restart` | 重启内核和面板 |
| `open-box uninstall` | 卸载 |

---

## 自动同步

本仓库通过 GitHub Actions 每 6 小时自动从上游 `liandu2024/Open-Box` 的 `main` 分支同步代码。
如果上游发布新版本，本仓库会自动拉取。
