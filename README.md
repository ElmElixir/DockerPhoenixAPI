# dockerPhoenix
フロントエンドをelm バックエンドのAPIをElixir
データベースをMysqlとして起動します。

## Dockerのビルド
```
docker-compose build
```
```
docker-compose run app mix phx.new . --app api --no-html --database mysql
```
```
docker-compose run app mix deps.get
```
```
docker-compose run app mix ecto.create
```
