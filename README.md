# dockerElmPhoenix
フロントエンドをelm バックエンドのAPIをElixir
データベースをMysqlとして起動します。
後日ShellScriptでまとめたい。

## docker compose ファイル
MySQL8.0以降はまだ対応していない？そのため5.7にしています。

mariaex error #222

https://github.com/xerions/mariaex/issues/222
```
version: '3'
services:
  db:
    image: mysql:5.7
    ports:
      - "3306:3306"
    volumes:
      - ./docker/mysql/volumes:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: 'password'      
  app:
    build: ./
    container_name: "web_app"
    working_dir: /opt/app
    command: mix phx.server
    volumes:
      - .:/opt/app
    environment:
      MYSQL_ROOT_USERNAME: 'root'
      MYSQL_ROOT_PASSWORD: 'password'
      MYSQL_HOSTNAME: 'db'
      MYSQL_PORT: '3306'
    ports:
      - '4000:4000'
    depends_on:
      - db

```
## Dockerのビルド
```
docker-compose build app
```
### MySQLコンテナ起動
```
docker-compose up -d db
```

### PhoenixProject作成
```
docker-compose run --rm app mix phx.new . --database mysql
```
### ライブラリ追加
config/mix.exs内へ追加
` {:plug_cowboy, "~> 1.0"},`
 

```
  defp deps do
    [
      {:phoenix, "~> 1.3.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:mariaex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 1.0"},　//ココ
      {:cowboy, "~> 1.0"}
    ]
  end
```
#### ライブラリインストール
```
docker-compose run --rm app mix deps.get
```
#### 開発環境のDB接続準備
\config\dev.exs の書き換え
```
[中略]
# Configure your database
config :app, App.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "password",//ココ
  database: "app_dev",
  hostname: "db",　//ココ
  pool_size: 10
[中略]

```

### DB Migrate
```
docker-compose run --rm app mix ecto.create
```
### 起動する。
```
docker-compose up
```

### Elixirバージョン確認
```
docker-compose run --rm app elixir -v
```
### Phoenix バージョン確認
```
docker-compose run --rm app mix phx.new --version
```

## Dockerコンテナ内へ入る場合
`docker ps` などで確認してくんさい
```
docker exec -it <developing docker name or ID> //bin/sh
```

##終了時
```
docker-compose down
```

参考記事
Phoenix/ElixirでAPIのログイン機能を作成する(guardian・guardianDB) https://qiita.com/yujikawa/items/fe262eb98c5be713d8fb

Phoenix 公式
https://hexdocs.pm/phoenix/overview.html

elm 0.19 で JSONを使ってjsと通信したメモ https://qiita.com/hibohiboo/items/33a8dcf462bd8e4a55e0

