# Hermes 迁移工具

将 Hermes 桌面版从系统盘迁移到其他磁盘，释放约 3.3 GB 系统盘空间。

---

## 用途

### 为什么要迁移？

- **释放系统盘空间**：约 3.3 GB
- **减少杀毒软件拦截**：杀毒软件对 `AppData` 目录监控严格，可能拦截 Hermes 执行的 Python/Node.js 任务
- **数据零损失**：所有对话历史、技能、配置完整保留
- **透明使用**：迁移后 Hermes 正常使用，无需任何配置

### 工作原理

使用 Windows Junction（目录符号链接）重定向数据：

```
原始位置：C:\Users\用户名\AppData\Local\hermes (3.3 GB)
              ↓
Junction链接：C:\Users\用户名\AppData\Local\hermes → D:\你的路径\hermes
              ↓
实际位置：D:\你的路径\hermes (3.3 GB)
```

### 迁移后效果

| 迁移前 | 迁移后 |
|--------|--------|
| 系统盘空间：-3.3 GB | 系统盘空间：+3.3 GB 释放 ✅ |
| 杀毒拦截：频繁 | 杀毒拦截：可能减少 ✅ |
| 数据安全：100% 保留 ✅ |

---

## 使用步骤

### 准备工作

1. 关闭 Hermes 应用（包括系统托盘）
2. 确保没有 Python 或 Node.js 程序在运行
3. 确定迁移目标路径（默认：`D:\software\HermesDesktop`）

### 执行迁移

#### 第一步：下载脚本

下载所有 `.ps1` 脚本文件到一个文件夹。

#### 第二步：以管理员身份打开 PowerShell

按 `Win + X`，选择 **"Windows PowerShell (管理员)"** 或 **"终端 (管理员)"**

#### 第三步：进入脚本目录

```powershell
cd "脚本所在目录"
```

#### 第四步：执行迁移脚本

```powershell
.\migrate-hermes.ps1
```

脚本会提示输入目标路径：

```
Enter target path (or press Enter for default):
Default: D:\software\HermesDesktop
Your input: _
```

操作：
- **直接回车**：使用默认路径 `D:\software\HermesDesktop`
- **输入路径**：使用自定义路径，如 `D:\MyData\Hermes`

#### 第五步：确认迁移

看到 `Continue? (Y/N)` 时，输入 `Y` 回车。

#### 第六步：等待完成

脚本会自动执行 8 个步骤：

```
Step 1: Cleaning old directory...   （清理旧目录）
Step 2: Closing processes...        （关闭进程）
Step 3: Waiting...                  （等待）
Step 4: Creating directory...       （创建目录）
Step 5: Moving data...              （移动数据，需要几分钟）
Step 6: Cleaning source...          （清理源目录）
Step 7: Creating junction...        （创建链接）
Step 8: Verifying...                （验证）
```

看到 **"Migration Complete!"** 表示成功。

预计时间：5-10 分钟

### 验证迁移

```powershell
.\verify-hermes.ps1
```

应该看到：

```
Status: OK
Type: Junction
```

### 迁移后检查

1. **启动 Hermes**：验证功能是否正常
2. **检查数据**：验证对话历史、技能是否完整
3. **测试任务**：执行 Python 任务，检查杀毒软件是否仍拦截

---

## 脚本说明

| 脚本文件 | 用途 |
|---------|------|
| `migrate-hermes.ps1` | 迁移脚本（支持自定义路径） |
| `rollback-hermes.ps1` | 回滚脚本（支持自定义路径） |
| `verify-hermes.ps1` | 验证脚本 |

---

## 回滚方法

如果迁移后出现问题，可以回滚：

```powershell
.\rollback-hermes.ps1
```

输入迁移时使用的路径（或直接回车使用默认路径），数据会移回系统盘。

---

## 手动迁移

如果脚本执行失败，可以手动迁移：

```powershell
# 1. 关闭进程
Get-Process node, python, hermes, uv -ErrorAction SilentlyContinue | Stop-Process -Force

# 2. 等待
Start-Sleep 3

# 3. 创建目录（替换为你的路径）
New-Item -Path "D:\你的路径" -ItemType Directory -Force

# 4. 移动数据
robocopy "$env:LOCALAPPDATA\hermes" "D:\你的路径\hermes" /E /MOVE /R:3 /W:5

# 5. 删除空源目录
Remove-Item "$env:LOCALAPPDATA\hermes" -Force -Recurse

# 6. 创建链接
New-Item -Path "$env:LOCALAPPDATA\hermes" -ItemType Junction -Value "D:\你的路径\hermes" -Force

# 7. 验证
Get-Item "$env:LOCALAPPDATA\hermes"
```

---

## 常见问题

### 问题：无法运行脚本

**解决**：执行以下命令允许脚本运行：

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### 问题：进程无法关闭

**解决**：打开任务管理器，手动结束 `node.exe` 和 `hermes.exe` 进程。

### 问题：目标路径已存在

**解决**：删除目标文件夹后重试。

### 问题：迁移后 Hermes 无法启动

**解决**：执行回滚脚本：

```powershell
.\rollback-hermes.ps1
```

---

## 注意事项

- 所有新数据（新技能、MCP 配置、对话历史）会自动保存到新位置
- Hermes 无需任何配置修改
- Junction 对 Hermes 完全透明（它仍认为数据在 C 盘）
- 可随时回滚，数据安全

---

## 系统要求

- Windows 10/11
- PowerShell 5.1 或更高版本
- 管理员权限
- Hermes 桌面版安装在系统盘（C 盘）

---

## 日志文件

迁移完成后，日志文件保存在：

```
桌面\hermes-migration-log.txt
```

---

## 许可证

MIT License - 可自由使用和分享
