# Git常用命令

![](http://kmknkk.oss-cn-beijing.aliyuncs.com/image/git.jpg)

>* Workspace：工作区
>
>- Index / Stage：暂存区
>- Repository：仓库区（或本地仓库）
>- Remote：远程仓库

**新建代码库**

```bash
# 在当前目录新建一个Git代码库
$ git init
# 新建一个目录，将其初始化为Git代码库
$ git init [project-name]
# 下载一个项目和它的整个代码历史
$ git clone [url]
```

**配置**

```bash
Git的设置文件为.gitconfig，它可以在用户主目录下（全局配置），也可以在项目目录下（项目配置）。
# 显示当前的Git配置
$ git config --list
# 编辑Git配置文件
$ git config -e [--global]
# 设置提交代码时的用户信息
$ git config [--global] user.name "[name]"
$ git config [--global] user.email "[email address]"
$ git config [--global] user.editor "[editor]"
```

**缓存**

```bash
# 添加指定文件到缓存区
$ git stash save "save message" 执行存储时，添加备注，方便查找，只有git stash也要可以的，但查找时不方便识别
# 查看缓存区内容
$ git stash list
# 查看缓存内容
$ git stash show 显示做了哪些改动，默认show第一个存储,如果要显示其他存贮，后面加stash@{$num}，比如第二个 git stash show stash@{1}
# 查看第一个存储的改动
$ git stash show -p 显示第一个存储的改动，如果想显示其他存存储，命令：git stash show stash@{$num}  -p ，比如第二个：git stash show stash@{1} -p
# 应用某个存储
$ git stash apply 应用某个存储,但不会把存储从存储列表中删除，默认使用第一个存储,即stash@{0}，如果要使用其他个，git stash apply stash@{$num} ， 比如第二个：git stash apply stash@{1}
# 弹出某个存储
$ git stash pop 命令恢复之前缓存的工作目录，将缓存堆栈中的对应stash删除，并将对应修改应用到当前的工作目录下,默认为第一个stash,即stash@{0}，如果要应用并删除其他stash，命令：git stash pop stash@{$num} ，比如应用并删除第二个：git stash pop stash@{1}
# 删除某个存储
$ git stash drop stash@{$num} 丢弃stash@{$num}存储，从列表中删除这个存储
# 清空存储
$ git stash clear 清空所有缓存的stash

```



**增加/删除文件**

```bash
# 添加指定文件到暂存区
$ git add [file1] [file2] ...
# 添加指定目录到暂存区，包括子目录
$ git add [dir]
# 添加当前目录的所有文件到暂存区
$ git add .
# 添加所有后缀为js的文件到暂存区
$ git add *.js
# 添加每个变化前，都会要求确认
# 对于同一个文件的多处变化，可以实现分次提交
$ git add -p
# 删除工作区文件，并且将这次删除放入暂存区
$ git rm [file1] [file2] ...
# 停止追踪指定文件，但该文件会保留在工作区
$ git rm --cached [file]
# 改名文件，并且将这个改名放入暂存区
$ git mv [file-original] [file-renamed]
```

**代码提交**

```bash
# 提交暂存区到仓库区
$ git commit -m [message]
# 提交暂存区的指定文件到仓库区
$ git commit [file1] [file2] ... -m [message]
# 提交工作区自上次commit之后的变化，直接到仓库区
$ git commit -a
# 提交时显示所有diff信息
$ git commit -v
# 使用一次新的commit，替代上一次提交
# 如果代码没有任何新变化，则用来改写上一次commit的提交信息
$ git commit --amend -m [message]
# 重做上一次commit，并包括指定文件的新变化
$ git commit --amend [file1] [file2] ...
```

**分支**

```bash
# 列出所有本地分支
$ git branch
# 列出所有远程分支
$ git branch -r
# 列出所有本地分支和远程分支
$ git branch -a
# 新建一个分支，但依然停留在当前分支
$ git branch [branch-name]
# 新建一个分支，并切换到该分支
$ git checkout -B [branch]
# 以remote分支为基础，新建一个分支，并切换到该分支
$ git checkout -q [branch]
# 新建一个分支，指向指定commit
$ git branch [branch] [commit]
# 新建一个分支，与指定的远程分支建立追踪关系
$ git branch --track [branch] [remote-branch]
# 切换到指定分支，并更新工作区
$ git checkout [branch-name]
# 切换到上一个分支
$ git checkout -
# 建立追踪关系，在现有分支与指定的远程分支之间
$ git branch --set-upstream [branch] [remote-branch]
# 合并指定分支到当前分支
$ git merge [branch]
# 获取分支commit id
$ git rev-parse --short HEAD 
# 选择一个commit，合并进当前分支
$ git cherry-pick [commit]
# 删除分支
$ git branch -D [branch-name]
# 删除远程分支
$ git push origin --delete [branch-name]
$ git push origin :[branch-name]
# 分支重新命名
$ git push -m [new-branch-name]
$ git push -m [old-branch-name] [new-branch-name] 尝试修改
$ git branch -M [old-branch-name] [new-branch-name] 强制修改
```

**标签**

```bash
# 列出所有tag
$ git tag
# 新建一个tag在当前commit
$ git tag [tag]
# 新建一个tag在指定commit
$ git tag [tag] [commit]
# 删除本地tag
$ git tag -d [tag]
# 删除远程tag
$ git push origin :refs/tags/[tagName]
# 查看tag信息
$ git show [tag]
# 提交指定tag
$ git push [remote] [tag]
# 提交所有tag
$ git push [remote] --tags
# 新建一个分支，指向某个tag
$ git checkout -b [branch] [tag]
```

**查看信息**

```bash
# 显示有变更的文件
$ git status
# 显示当前分支的版本历史
$ git log
# 显示commit历史，以及每次commit发生变更的文件
$ git log --oneline
# --oneline参数可以将每条日志的输出为一行，如果日志比较多的话，用这个参数能够使结果看起来比较醒目
$ git log --stat
# 搜索提交历史，根据关键词
$ git log -S [keyword]
# 显示某个commit之后的所有变动，每个commit占据一行
$ git log [tag] HEAD --pretty=format:%s
# 显示某个commit之后的所有变动，其"提交说明"必须符合搜索条件
$ git log [tag] HEAD --grep feature
# 显示某个文件的版本历史，包括文件改名
$ git log --follow [file]
$ git whatchanged [file]
# 显示指定文件相关的每一次diff
$ git log -p [file]
# 显示过去5次提交
$ git log -5 --pretty --oneline
# 显示所有提交过的用户，按提交次数排序
$ git shortlog -sn
# 显示指定文件是什么人在什么时间修改过
$ git blame [file]
# 显示暂存区和工作区的差异
$ git diff
# 显示暂存区和上一个commit的差异
$ git diff --cached [file]
# 显示工作区与当前分支最新commit之间的差异
$ git diff HEAD
# 显示两次提交之间的差异
$ git diff [first-branch]...[second-branch]
# 显示今天你写了多少行代码
$ git diff --shortstat "@{0 day ago}"
# 显示某次提交的元数据和内容变化
$ git show [commit]
# 显示某次提交发生变化的文件
$ git show --name-only [commit]
# 显示某次提交时，某个文件的内容
$ git show [commit]:[filename]
# 显示当前分支的最近几次提交
$ git reflog
```

**远程同步**

```bash
# 下载远程仓库的所有变动
$ git fetch [remote]
# 刷新远程仓库
$ git fetch --all
# 同步远程仓库所有分支
$ git fetch --prune
# 显示所有远程仓库
$ git remote -v
# 显示某个远程仓库的信息
$ git remote show [remote]
# 同步远程仓库所有分支，并删除本地多余分支
$ git remote update --prune
# 增加一个新的远程仓库，并命名
$ git remote add [shortname] [url]
# 移除一个远程仓库
$ git remote rm [shortname]
# 取回远程仓库的变化，并与本地分支合并
$ git pull [remote] [branch]
# 上传本地指定分支到远程仓库
$ git push [remote] [branch]
# 强行推送当前分支到远程仓库，即使有冲突
$ git push [remote] --force
# 推送所有分支到远程仓库
$ git push [remote] --all
```

**撤销**

```bash
# 放弃工作区某个文件的更改
$ git checkout -- filepathname
# 放弃工作区所有文件的更改
$ git checkout .
# 撤销暂存区某个文件的add
$ git reset filepathname
# 撤销暂存区所有文件的add
$ git reset
$ git reset HEAD .
# 撤销仓库区的某个commit，重置暂存区，但工作区不变（HEAD^、～1）
$ git reset [commit]
$ git reset --mixed [commit]
# 撤销仓库区的某个commit，暂存区不变
$ git reset --soft [commit]
# 撤销仓库区的某个commit，重置暂存区与工作区（文件修改会丢失）
$ git reset --head [commit]
# 新建一个commit，用来撤销指定commit
# 后者的所有变化都将被前者抵消，并且应用到当前分支
$ git revert [commit]
```

**恢复误删的远程分支**

```bash
$ git reflog --date=iso
# reflog是reference log的意思，也就是引用log，记录HEAD在各个分支上的移动轨迹。选项 --date=iso，表示以标准时间格式展示。这里你肯定会问，为什么不用git log？git log是用来记录当前分支的commit log，分支都删除了，找不到commit log了。
$ git checkout -b recovery_branch_name commitid
```

**仓库完整迁移**

```bash
# 从原地址克隆一份裸版本库
$ git clone --bare 旧的git地址
# 会在当前目录下产生一个 xxx.git 的文件夹，这个步骤，就是克隆git每一次的提交信息，和本地的代码没有关系，只要线上的代码是最新的，这个git版本就是完整的

# 推送裸版本库到新的地址
$ cd xxx.git
$ git push --mirror 新的git地址
```

