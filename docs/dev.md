配置环境变量
```shell

go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
```

初始化go mod
```shell
go mod init k8s-research
```

编译
```shell
# 编译linux
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build

# 编译windows
go build
```