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
バックグラウンドのAPIを作成するため、Phoenixを立ち上げます。
```
docker-compose build app
```
### MySQLコンテナ起動
DBを起動させます
`-d`を入れてバックグランドで動かします。
```
docker-compose up -d db
```

### PhoenixProject作成
デフォルトはpostgreSQLであるためここではMySQLで起動します。
（特に理由はないですがポスグレの場合はDocker-Compose.ymlをポスグレに修正してください）

```
docker-compose run --rm app mix phx.new . --database mysql
```
### ライブラリ追加
dapter の` {:plug_cowboy, "~> 1.0"},`を追加　

config/mix.exs内へ追加
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
Elixirライブラリをインストールします。
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
DB情報を更新
```
docker-compose run --rm app mix ecto.create
```
### 起動する。
アプリを起動します。
```
docker-compose up -d
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
注意：一応`docker ps` などで確認してくんさい
docker-compose ファイルで設定した`container_name: "web_app"`を指定していますので container name でDocker内に入ります。

```
docker exec -it web_app //bin/sh
```

##作業終了時
```
docker-compose down
```

Phoenix 公式
https://hexdocs.pm/phoenix/overview.html

elm 0.19 で JSONを使ってjsと通信したメモ https://qiita.com/hibohiboo/items/33a8dcf462bd8e4a55e0

