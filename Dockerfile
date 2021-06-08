FROM golang:alpine as builder
WORKDIR /app
ENV GOPROXY=https://goproxy.cn,direct
ENV GO111MODULE=on

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk add --no-cache upx ca-certificates tzdata
COPY ./go.mod ./
COPY ./go.sum ./
RUN go mod download -x

COPY . .
# RUN CGO_ENABLED=0 go build -ldflags '-s -w' -o demo-api
RUN CGO_ENABLED=0 go build -ldflags '-s -w' -o demo-api && \
    upx -3 demo-api -o _upx_server && \
    mv -f _upx_server demo-api

FROM alpine as runner
COPY --from=builder /app/demo-api /
ENTRYPOINT [ "/demo-api" ]