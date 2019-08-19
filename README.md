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
#### ライブラリ追加
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
# 起動する。
アプリを起動します。
```
docker-compose up -d
```
`http://localhost:4000` でPhoenixの画面が
Welcome to Phoenix!
A productive web framework that
does not compromise speed and maintainability.

出ればOKです。

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
これでDockerのコンテナ内に入れました。

### elm の設定

```
/opt/app/ # 
```

## 作業終了時
```
docker-compose down
```
# 参考にしたページ
## Docker の設定
 - Elixir/Phoenix+MySQL5.7環境をDocker/Docker Composeで整え開発する。
  https://qiita.com/studio23c/items/510a12abd53f3651b5b2
 - Elixir1.6 / Phoenix1.3の環境をDockerで整えてCRUDアプリを動かすまで
  https://qiita.com/dd511805/items/13f3ea4255dc4d1a3fbb 
## Elixir Phoenix
Phoenix 公式
https://hexdocs.pm/phoenix/overview.html

## elm
 - Create Elm App 
  https://github.com/halfzebra/create-elm-app#getting-started
 - Elmで非同期Http通信を含んだSPAを試してみる
  https://qiita.com/sand/items/849c919b0d957ee99b9d
 - elm 0.19 で JSONを使ってjsと通信したメモ
  https://qiita.com/hibohiboo/items/33a8dcf462bd8e4a55e0
 - elm-lang examples
  https://elm-lang.org/examples
